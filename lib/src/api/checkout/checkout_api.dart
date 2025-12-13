import 'package:flutter/material.dart';

import '../../utils/logger.dart';
import '../../widgets/paypal_checkout_page.dart';
import '../orders/models/order_intent.dart';
import '../orders/models/purchase_unit.dart';
import '../orders/orders_api.dart';
import '../payments/models/payment_intent.dart';
import '../payments/payments_api.dart';
import '../payments/v1/models/payer.dart';
import '../payments/v1/models/redirect_urls.dart';
import '../payments/v1/models/transaction.dart';

/// Manages operations related to the overall checkout process.
///
/// This class provides methods to streamline the payment as a whole by combining
/// all the required API requests into a cohesive workflow. It acts as a facade,
/// simplifying the interaction with the underlying [OrdersApi] and [PaymentsApi].
///
/// It follows the singleton pattern to ensure a single, consistent instance
/// throughout the application.
///
/// To use this class, access the singleton instance via `CheckoutApi.instance`:
///
class CheckoutApi {
  /// An instance of the [PaymentsApi] to handle payment-related operations.
  final PaymentsApi _payments;

  /// An instance of the [OrdersApi] to handle order-related operations.
  final OrdersApi _orders;

  /// A private constructor to prevent external instantiation.
  ///
  /// This is a key part of the singleton pattern. It initializes the
  /// [_payments] and [_orders] API instances.
  CheckoutApi._()
    : _payments = PaymentsApi.instance,
      _orders = OrdersApi.instance;

  /// The internal, static, and private instance of the [CheckoutApi] class.
  ///
  /// This variable holds the single instance of the class once it's created.
  ///
  static CheckoutApi? _instance;

  /// Provides a lazy-loaded singleton instance of the [CheckoutApi] class.
  ///
  /// The first time this getter is accessed, it creates and initializes a new
  /// instance. On subsequent accesses, it returns the already created instance,
  /// ensuring that only one object of this type exists in the application.
  ///
  /// A log message is printed to the console when the instance is first
  /// initialized.
  ///
  static CheckoutApi get instance {
    if (_instance == null) {
      Logger.logMessage("CheckoutApi is initialized!");
    }
    _instance ??= CheckoutApi._();
    return _instance!;
  }

  /// Handles the complete PayPal Checkout flow from:
  /// 1. Creating an order
  /// 2. Starting native checkout (PayPal UI)
  /// 3. Capturing or Authorizing the order after approval
  ///
  /// This method abstracts the entire PayPal ORDER → CHECKOUT → CAPTURE/AUTHORIZE flow.
  ///
  /// Parameters:
  /// - [intent]: Whether the payment should be captured immediately (.capture)
  ///             or only authorized (.authorize).
  /// - [purchaseUnits]: The list of purchase units associated with the order.
  /// - [onInitiated]: Called immediately when the process starts (loading state).
  /// - [onSuccess]: Called when the order is successfully completed (captured/authorized).
  /// - [onError]: Called when any step of the flow fails.
  ///
  /// PayPal Flow Steps:
  /// ------------------
  /// 1️⃣ Create Order (server or PayPal SDK)
  /// 2️⃣ Launch PayPal Native Checkout (user approves payment)
  /// 3️⃣ User returns:
  ///       - success → capture / authorize order
  ///       - cancel  → call onError("Checkout canceled")
  ///       - failure → call onError(reason)
  /// 4️⃣ Capture / Authorize order
  /// 5️⃣ Return success or error
  ///
  Future<void> checkoutOrder({
    OrderIntent intent = .capture,
    required List<PurchaseUnit> purchaseUnits,
    void Function()? onInitiated,
    void Function(String orderId)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      // STEP 1: Notify that checkout has started (useful for showing loading)
      onInitiated?.call();

      // STEP 2: Create the PayPal Order
      await _orders.createOrder(
        intent: intent,
        purchaseUnits: purchaseUnits,
        onError: onError,

        // When order creation succeeds:
        onSuccess: (order) async {
          final orderId = order.id;

          // If no orderId is returned, fail early.
          if (orderId == null) {
            onError?.call(
              "Order creation succeeded but no orderId was returned.",
            );
            return;
          }

          // STEP 3: Start PayPal Native Checkout UI
          _orders.startNativeCheckout(
            orderId: orderId,
            onError: onError,

            // When the checkout UI returns a failure
            onFailure: (orderId, reason, code, correlationId) {
              onError?.call(reason);
            },

            // When user cancels the checkout
            onCancel: (orderId) {
              onError?.call(
                "Checkout canceled${orderId != null ? " | orderId: $orderId" : ""}",
              );
            },

            // When user approves payment successfully
            onSuccess: (orderId, payerId) async {
              // Ensure required ids exist
              if (orderId == null || payerId == null) {
                onError?.call(
                  "Checkout succeeded but missing required data:"
                  " orderId=$orderId, payerId=$payerId",
                );
                return;
              }

              // STEP 4A: Capture order (if intent == capture)
              if (intent == .capture) {
                await _orders.captureOrder(
                  orderId: orderId,
                  onError: (err) {
                    onError?.call("Capture error for $orderId: $err");
                  },
                  onSuccess: (capture) {
                    // PayPal returns status "COMPLETED" when fully captured
                    if (capture.status?.toLowerCase() == 'completed') {
                      onSuccess?.call(orderId);
                      return;
                    }

                    onError?.call(
                      "Capture did not complete (status: ${capture.status})",
                    );
                  },
                );

                return;
              }

              // STEP 4B: Authorize order (if intent == authorize)
              await _orders.authorizeOrder(
                orderId: orderId,
                onError: (err) {
                  onError?.call("Authorization error for $orderId: $err");
                },
                onSuccess: (authorize) {
                  if (authorize.status?.toLowerCase() == 'completed') {
                    onSuccess?.call(orderId);
                    return;
                  }

                  onError?.call(
                    "Authorization did not complete (status: ${authorize.status})",
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      onError?.call("Unexpected exception: $e");
    }
  }

  /// Handles the complete PayPal v1 payment checkout flow:
  /// 1. Create payment
  /// 2. Redirect user to approval page
  /// 3. Execute payment after approval
  /// 4. Optionally capture authorized or order-based payments
  ///
  /// This wrapper ensures proper callback routing and meaningful error reporting.
  ///
  /// Parameters:
  /// - [context]: Flutter UI build context.
  /// - [intent]: The PayPal payment intent (`sale`, `authorize`, or `order`).
  /// - [payer]: Payer information for the payment.
  /// - [transactions]: List of PayPal transactions to be processed.
  /// - [redirectUrls]: URLs used for success/cancel return during approval.
  /// - [noteToPayer]: Optional note shown on PayPal.
  /// - [experienceProfileId]: Optional PayPal checkout experience profile.
  /// - [onInitiated]: Triggered immediately when checkout begins (e.g., show loader).
  /// - [onSuccess]: Called when payment is fully completed.
  /// - [onError]: Called when any step fails, with a descriptive and meaningful reason.
  ///
  Future<void> checkoutPayment(
    BuildContext context, {
    PaymentIntent intent = .sale,
    required Payer payer,
    required List<Transaction> transactions,
    required RedirectUrls redirectUrls,
    String? noteToPayer,
    String? experienceProfileId,
    void Function()? onInitiated,
    void Function(String paymentId)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      // STEP 1: Notify UI that checkout has started (trigger loading indicator)
      onInitiated?.call();

      // STEP 2: Create the PayPal Payment
      await _payments.v1.createPayment(
        intent: intent,
        payer: payer,
        transactions: transactions,
        redirectUrls: redirectUrls,
        noteToPayer: noteToPayer,
        experienceProfileId: experienceProfileId,
        onError: onError,

        // When payment creation succeeds:
        onSuccess: (payment) async {
          // Extract approval URL
          final approvalUrl = payment.approvalLink?.href;

          if (approvalUrl == null) {
            onError?.call(
              "PayPal did not provide an approval URL. Cannot continue the checkout process.",
            );
            return;
          }

          // STEP 3: Open PayPal Approval Page (WebView)
          final response = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (context) => PaypalCheckoutPage(
                approvalUrl: approvalUrl,
                redirectUrls: redirectUrls,
              ),
            ),
          );

          // Extract success status from response
          final success = response?['success'] == true;

          // If user cancels or something unexpected occurs
          if (!success) {
            onError?.call(
              "The user canceled the PayPal checkout or the approval process failed.",
            );
            return;
          }

          // Extract query parameters from response
          final queryParams = response?['queryParams'];

          // Getting payer id and payment id from query parameters
          final paymentId = queryParams?['paymentId'];
          final payerId = queryParams?['PayerID'];

          // If payer id or payment id is null
          if (payerId == null || paymentId == null) {
            onError?.call(
              "PayPal returned invalid approval data. Missing paymentId or payerId.",
            );
            return;
          }

          // STEP 4: Execute Payment
          _payments.v1.executePayment(
            paymentId: paymentId,
            payerId: payerId,
            onError: onError,
            onSuccess: (executeResponse) async {
              // If intent is SALE → Payment is completed after execution
              if (intent == .sale) {
                onSuccess?.call(paymentId);
                return;
              }

              // STEP 5B: If intent is AUTHORIZE → Capture authorization
              if (intent == .authorize) {
                // Getting authorization id from the response
                final authorizationId = executeResponse
                    .transactions
                    .firstOrNull
                    ?.relatedResources
                    ?.firstOrNull
                    ?.authorization?['id'];

                // If authorization id is null, fail early.
                if (authorizationId == null) {
                  onError?.call(
                    "Execution succeeded, but no authorization ID was returned. Cannot capture authorization.",
                  );
                  return;
                }

                await _payments.v1.captureAuthorizedPayment(
                  authorizationId: authorizationId,
                  amount: executeResponse.transactions.firstOrNull!.amount!,
                  onError: onError,
                  onSuccess: (capture) {
                    // PayPal returns status "COMPLETED" when fully captured
                    if (capture.state?.toLowerCase() == 'completed') {
                      onSuccess?.call(paymentId);
                      return;
                    }

                    onError?.call(
                      "Authorization capture was not completed. Status: ${capture.state}",
                    );
                  },
                );

                return;
              }

              // STEP 5C: If intent is ORDER → Capture order payment
              // Getting order id from the response
              final orderId = executeResponse
                  .transactions
                  .firstOrNull
                  ?.relatedResources
                  ?.firstOrNull
                  ?.order?['id'];

              // If order id is null, fail early.
              if (orderId == null) {
                onError?.call(
                  "Execution succeeded, but no order ID was returned. Cannot capture order payment.",
                );
                return;
              }

              await _payments.v1.captureOrderPayment(
                orderId: orderId,
                amount: executeResponse.transactions.firstOrNull!.amount!,
                onError: onError,
                onSuccess: (capture) {
                  // PayPal returns status "COMPLETED" when fully captured
                  if (capture.state?.toLowerCase() == 'completed') {
                    onSuccess?.call(paymentId);
                    return;
                  }

                  onError?.call(
                    "Order capture failed. PayPal returned status: ${capture.state}",
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      // Any unexpected exception is handled here
      onError?.call(e.toString());
    }
  }
}
