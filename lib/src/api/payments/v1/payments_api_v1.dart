import 'dart:convert';

import 'models/payer.dart';
import 'models/redirect_urls.dart';
import 'models/responses/capture_order_payment_response.dart';
import 'models/responses/payment_details_response.dart';
import 'models/transaction.dart';
import 'models/responses/create_payment_response.dart';
import 'models/responses/execute_payment_response.dart';
import 'models/responses/capture_authorized_payment_response.dart';
import 'models/responses/void_authorized_payment_response.dart';
import 'models/responses/refund_captured_payment_response.dart';
import 'models/responses/refund_sale_response.dart';
import '../models/payment_intent.dart';
import '../../../utils/extension_functions.dart';
import '../../../utils/logger.dart';
import '../../../network/http_exception.dart';
import '../../../network/http_response_validator.dart';
import '../../../network/paypal_http_service.dart';

/// Provides access to version 1 of the PayPal Payments API.
///
/// This class is a singleton and provides methods for interacting with
/// PayPal's REST API v1 endpoints, such as creating and managing orders.
class PaymentsApiV1 {
  /// A reference to the shared [PaypalHttpService] instance used for all
  /// network requests.
  ///
  final PaypalHttpService _httpService;

  /// Private internal constructor to enforce the singleton pattern.
  ///
  PaymentsApiV1._() : _httpService = PaypalHttpService.instance;

  /// The static, private instance of the [PaymentsApiV1].
  ///
  static PaymentsApiV1? _instance;

  /// Provides a lazy-loaded, singleton instance of the [PaymentsApiV1].
  ///
  /// This ensures that only one instance of the V2 API handler exists
  /// throughout the application's lifecycle.
  ///
  static PaymentsApiV1 get instance {
    if (_instance == null) {
      Logger.logMessage("PaymentsApiV1 is initialized!");
    }
    _instance ??= PaymentsApiV1._();
    return _instance!;
  }

  /// Creates a payment.
  /// https://developer.paypal.com/docs/api/payments/v1/#payment_create
  ///
  /// [intent] The payment intent.
  /// [payer] The source of the funds for this payment.
  /// [transactions] A list of payment transactions.
  /// [redirectUrls] A set of redirect URLs.
  /// [noteToPayer] A note to the payer.
  /// [experienceProfileId] The PayPal-generated ID for a web experience profile.
  /// [onInitiated] A callback function that is invoked when the request is initiated.
  /// [onPreRequest] A callback that provides the endpoint and payload just before the HTTP request is made. Useful for debugging.
  /// [onSuccess] A callback function that is invoked when the payment is successfully created.
  /// [onError] A callback function that is invoked when an error occurs.
  ///
  Future<void> createPayment({
    PaymentIntent intent = .sale,
    required Payer payer,
    required List<Transaction> transactions,
    required RedirectUrls redirectUrls,
    String? noteToPayer,
    String? experienceProfileId,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(CreatePaymentResponse)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v1/payments/payment';

      final payload = {
        "intent": intent.name,
        "payer": payer.toJson(),
        "transactions": transactions.map((e) => e.toJson()).toList(),
        "redirect_urls": redirectUrls.toJson(),
        "note_to_payer": noteToPayer,
        "experience_profile_id": experienceProfileId,
      }.filterNotNull();

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(CreatePaymentResponse.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Executes a payment that has been previously created.
  /// https://developer.paypal.com/docs/api/payments/v1/#payment_execute
  ///
  /// After the buyer approves the payment, you can use this method to execute it.
  ///
  /// [paymentId] The ID of the payment to execute, as provided by the `createPayment` response.
  /// [payerId] The ID of the payer, as provided by the redirect from PayPal after buyer approval.
  /// [onInitiated] A callback function that is invoked when the request is initiated.
  /// [onPreRequest] A callback that provides the endpoint and payload just before the HTTP request is made. Useful for debugging.
  /// [onSuccess] A callback function that is invoked when the payment is successfully executed.
  /// [onError] A callback function that is invoked when an error occurs.
  ///
  Future<void> executePayment({
    required String paymentId,
    required String payerId,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(PaymentExecuteResponse)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v1/payments/payment/$paymentId/execute';

      final payload = {"payer_id": payerId};

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(PaymentExecuteResponse.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Captures an authorized payment.
  /// https://developer.paypal.com/docs/api/payments/v1/#authorization_capture
  ///
  /// This can be used to capture a previously authorized payment, either partially or in full.
  ///
  /// [authorizationId] The ID of the authorization to capture.
  /// [amount] The amount to capture. The `total` and `currency` fields are required.
  /// [finalCapture] Indicates whether this is the final capture for the authorization. Defaults to `true`.
  /// [onInitiated] A callback that fires when the request is initiated.
  /// [onPreRequest] A callback that provides the endpoint and payload just before the HTTP request is made. Useful for debugging.
  /// [onSuccess] A callback that fires with the response upon a successful capture.
  /// [onError] A callback that fires when an error occurs during the process.
  ///
  Future<void> captureAuthorizedPayment({
    required String authorizationId,
    required TransactionAmount amount,
    bool finalCapture = true,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(CaptureAuthorizedPaymentResponseV1)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v1/payments/authorization/$authorizationId/capture';

      final payload = {
        "amount": amount.toJson()..removeWhere((k, v) => k == "details"),
        "is_final_capture": finalCapture,
      };

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(CaptureAuthorizedPaymentResponseV1.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Voids, or cancels, a previously authorized payment.
  /// https://developer.paypal.com/docs/api/payments/v1/#authorization_void
  ///
  /// A voided authorization cannot be captured.
  ///
  /// [authorizationId] The ID of the authorization to void.
  /// [onInitiated] A callback that fires when the request is initiated.
  /// [onPreRequest] A callback that provides the endpoint and payload just before the HTTP request is made. Useful for debugging.
  /// [onSuccess] A callback that fires with the response upon a successful void.
  /// [onError] A callback that fires when an error occurs during the process.
  ///
  Future<void> voidAuthorizedPayment({
    required String authorizationId,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(VoidAuthorizedPaymentResponseV1)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v1/payments/authorization/$authorizationId/void';

      final payload = <String, dynamic>{};

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(VoidAuthorizedPaymentResponseV1.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Captures a payment for an order.
  /// https://developer.paypal.com/docs/api/payments/v1/#order_capture
  ///
  /// To use this method, the original payment must have been created with an
  /// `intent` of `order`.
  ///
  /// [orderId] The ID of the order to capture a payment for.
  /// [amount] The amount to capture.
  /// [finalCapture] Whether this is the final capture for the order. Defaults to `true`.
  /// [onInitiated] A callback that fires when the request is initiated.
  /// [onPreRequest] A callback that provides the endpoint and payload just before the HTTP request is made. Useful for debugging.
  /// [onSuccess] A callback that fires with the response upon a successful capture.
  /// [onError] A callback that fires when an error occurs during the process.
  ///
  Future<void> captureOrderPayment({
    required String orderId,
    required TransactionAmount amount,
    bool finalCapture = true,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(CaptureOrderPaymentResponseV1)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v1/payments/orders/$orderId/capture';

      final payload = {
        "amount": amount.toJson()..removeWhere((k, v) => k == "details"),
        "is_final_capture": finalCapture,
      };

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(CaptureOrderPaymentResponseV1.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Refunds a captured payment, either partially or fully.
  /// https://developer.paypal.com/docs/api/payments/v1/#capture_refund
  ///
  /// You can use this to refund a payment that has been previously captured.
  ///
  /// [captureId] The ID of the captured payment to refund.
  /// [amount] The amount to refund.
  /// [description] A description of the refund.
  /// [reason] The reason for the refund.
  /// [invoiceNumber] The invoice number for the refund.
  /// [onInitiated] A callback that fires when the request is initiated.
  /// [onPreRequest] A callback that provides the endpoint and payload just before the HTTP request is made. Useful for debugging.
  /// [onSuccess] A callback that fires with the response upon a successful refund.
  /// [onError] A callback that fires when an error occurs during the process.
  ///
  Future<void> refundCapturedPayment({
    required String captureId,
    required TransactionAmount amount,
    String? description,
    String? reason,
    String? invoiceNumber,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(RefundCapturedPaymentResponseV1)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v1/payments/capture/$captureId/refund';

      final payload = <String, dynamic>{
        "amount": amount.toJson(),
        "description": description,
        "reason": reason,
        "invoice_number": invoiceNumber,
      }.filterNotNull();

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(RefundCapturedPaymentResponseV1.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Refunds a captured payment, either partially or fully.
  /// https://developer.paypal.com/docs/api/payments/v1/#sale_refund
  ///
  /// You can use this to refund a payment that has been previously captured.
  ///
  /// [saleId] The ID of the sale to refund.
  /// [amount] The amount to refund.
  /// [description] A description of the refund.
  /// [reason] The reason for the refund.
  /// [invoiceNumber] The invoice number for the refund.
  /// [onInitiated] A callback that fires when the request is initiated.
  /// [onPreRequest] A callback that provides the endpoint and payload just before the HTTP request is made. Useful for debugging.
  /// [onSuccess] A callback that fires with the response upon a successful refund.
  /// [onError] A callback that fires when an error occurs during the process.
  ///
  Future<void> refundSale({
    required String saleId,
    required TransactionAmount amount,
    String? description,
    String? reason,
    String? invoiceNumber,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(RefundSaleResponse)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v1/payments/sale/$saleId/refund';

      final payload = <String, dynamic>{
        "amount": amount.toJson(),
        "description": description,
        "reason": reason,
        "invoice_number": invoiceNumber,
      }.filterNotNull();

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(RefundSaleResponse.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Shows details for a payment, by ID.
  /// https://developer.paypal.com/docs/api/payments/v1/#payment_get
  ///
  /// This can be used to retrieve the current state of a payment.
  ///
  /// [paymentId] The ID of the payment for which to show details.
  /// [onInitiated] A callback that fires when the request is initiated.
  /// [onPreRequest] A callback that provides the endpoint just before the HTTP request is made. Useful for debugging.
  /// [onSuccess] A callback that fires with the detailed payment information upon success.
  /// [onError] A callback that fires when an error occurs during the process.
  ///
  Future<void> getPaymentDetails({
    required String paymentId,
    void Function()? onInitiated,
    void Function(String endpoint)? onPreRequest,
    void Function(PaymentDetailsResponse)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v1/payments/payment/$paymentId';

      onPreRequest?.call(endpoint);

      final response = await _httpService.get(endpoint, isAuthenticated: true);

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(PaymentDetailsResponse.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }
}
