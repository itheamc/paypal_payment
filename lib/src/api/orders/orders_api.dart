import 'dart:convert';

import 'models/funding_source.dart';
import 'models/order_intent.dart';
import '../../network/http_exception.dart';
import '../../network/http_response_validator.dart';
import '../../network/paypal_http_service.dart';
import '../../pigeon_generated.dart';
import '../../utils/logger.dart';
import 'models/responses/authorize_order_response.dart' hide PurchaseUnit;
import 'models/responses/capture_order_response.dart' hide PurchaseUnit;
import 'models/responses/order_create_response.dart';
import 'models/purchase_unit.dart';

/// Manages operations related to PayPal orders.
///
/// This class provides methods to create and manage PayPal orders.
/// It follows the singleton pattern to ensure a single, consistent instance
/// throughout the application. Access the instance via `OrdersApi.instance`.
class OrdersApi {
  /// An instance of [PaypalHttpService] to handle network requests.
  ///
  /// This service is responsible for all HTTP communication with the PayPal API.
  ///
  final PaypalHttpService _httpService;

  /// An instance of the host API for native PayPal web checkout functionality.
  ///
  /// This is used to communicate with the native platform (iOS/Android)
  /// to initiate the web-based payment flow.
  ///
  final PayPalPaymentWebCheckoutHostApi _webCheckoutHostApi;

  /// A private constructor to prevent direct instantiation from outside the class.
  ///
  /// This is a core part of the singleton pattern implementation. It initializes
  /// the required service instances.
  ///
  OrdersApi._()
    : _httpService = PaypalHttpService.instance,
      _webCheckoutHostApi = PayPalPaymentWebCheckoutHostApi();

  /// The internal, static instance of the [OrdersApi] class.
  ///
  static OrdersApi? _instance;

  /// Provides a lazy-loaded singleton instance of the [OrdersApi] class.
  ///
  /// The first time this getter is accessed, it creates and initializes a new
  /// instance. On subsequent accesses, it returns the already created instance,
  /// ensuring that only one object of this type exists.
  ///
  static OrdersApi get instance {
    if (_instance == null) {
      Logger.logMessage("OrdersApi is initialized!");
    }
    _instance ??= OrdersApi._();
    return _instance!;
  }

  /// Creates a PayPal order.
  /// https://developer.paypal.com/docs/api/orders/v2/#orders_create
  ///
  /// The order is created with the provided [intent] and [purchaseUnits].
  ///
  /// [intent] The intent for the order, such as capturing payment immediately or authorizing it for later capture. Defaults to `.capture`.
  /// [purchaseUnits] A list of purchase units, which describe the details of the transaction, including the amount.
  /// [onInitiated] A callback that fires when the request is initiated.
  /// [onPreRequest] A callback that provides the endpoint and payload just before the HTTP request is made. Useful for debugging.
  /// [onSuccess] A callback that fires with the response upon successful order creation.
  /// [onError] A callback that fires when an error occurs during the process.
  ///
  Future<void> createOrder({
    OrderIntent intent = .capture,
    required List<PurchaseUnit> purchaseUnits,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(OrderCreateResponse)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v2/checkout/orders';
      final payload = {
        "intent": intent.name.toUpperCase(),
        "purchase_units": purchaseUnits.map((e) => e.toJson()).toList(),
      };

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(OrderCreateResponse.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Captures payment for a previously created order.
  ///  /// This should be called after a user has approved the payment. It finalizes
  /// the transaction and captures the funds from the buyer's account.
  /// See: https://developer.paypal.com/docs/api/orders/v2/#orders_capture
  ///
  /// - [orderId]: The ID of the order to capture the payment for. This is required.
  /// - [onInitiated]: A callback that is invoked when the capture process begins.
  /// - [onPreRequest]: A callback that provides the endpoint and payload for debugging,
  ///   just before the network request is sent.
  /// - [onSuccess]: A callback invoked upon a successful capture, providing a
  ///   [CaptureOrderResponse] object with details of the transaction.
  /// - [onError]: A callback invoked if an error occurs during the capture process,
  ///   providing an error message.
  ///
  Future<void> captureOrder({
    required String orderId,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(CaptureOrderResponse)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v2/checkout/orders/$orderId/capture';
      final payload = <String, dynamic>{};

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(CaptureOrderResponse.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Authorizes payment for a previously created order.
  ///
  /// This action establishes a payment authorization that can be captured later.
  /// It should be called after a user has approved the payment but before the
  /// funds are to be captured. This is typically used when an order is not
  /// fulfilled immediately.
  /// See: https://developer.paypal.com/docs/api/orders/v2/#orders_authorize
  ///
  /// - [orderId] The ID of the order for which to authorize payment. This is required.
  /// - [onInitiated] A callback that is invoked when the authorization process begins.
  /// - [onPreRequest] A callback that provides the endpoint and payload for debugging,
  ///   just before the network request is sent.
  /// - [onSuccess] A callback invoked upon a successful authorization, providing an
  ///   [AuthorizeOrderResponse] object with authorization details.
  /// - [onError] A callback invoked if an error occurs during the authorization
  ///   process, providing an error message.
  ///
  Future<void> authorizeOrder({
    required String orderId,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(AuthorizeOrderResponse)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v2/checkout/orders/$orderId/authorize';
      final payload = <String, dynamic>{};

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(AuthorizeOrderResponse.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Initiates the PayPal web checkout flow for a given order.
  ///
  /// This method starts the web-based payment process on the native side.
  /// It takes an [orderId] and provides callback functions to handle the
  /// different outcomes of the checkout process.
  ///
  /// - [orderId]: The ID of the order to be processed. This is required.
  /// - [fundingSource]: The source of the funds for the payment (e.g., PayPal, Card).
  ///   Defaults to [FundingSource.paypal].
  /// - [onSuccess]: A callback function invoked when the checkout is successfully
  ///   completed. It receives the `orderId` and the resulting `payerId`.
  /// - [onFailure]: A callback function invoked when the checkout fails on PayPal's
  ///   end. It receives the `orderId`, a failure `reason`, an error `code`, and
  ///   a `correlationId` for debugging.
  /// - [onCancel]: A callback function invoked when the user cancels the checkout
  ///   flow. It receives the `orderId`.
  /// - [onError]: A callback function invoked when a local or unexpected error
  ///   occurs within the SDK during the process. It receives an `error` message.
  Future<void> startNativeCheckout({
    required String orderId,
    FundingSource fundingSource = .paypal,
    void Function(String? orderId, String? payerId)? onSuccess,
    void Function(
      String? orderId,
      String reason,
      int code,
      String? correlationId,
    )?
    onFailure,
    void Function(String? orderId)? onCancel,
    void Function(String? error)? onError,
  }) async {
    try {
      // Calls the native side to start the web checkout UI.
      await _webCheckoutHostApi.startCheckout(orderId, fundingSource.name);

      // Retrieves the stream of events from the native checkout flow.
      final event = payPalWebCheckoutResultEvent();

      // Listen for events from the native side to determine the outcome.
      event.listen(
        (event) {
          switch (event) {
            case PayPalWebCheckoutSuccessResultEvent():
              onSuccess?.call(event.orderId, event.payerId);
            case PayPalWebCheckoutFailureResultEvent():
              onFailure?.call(
                event.orderId,
                event.reason,
                event.code,
                event.correlationId,
              );
            case PayPalWebCheckoutCanceledResultEvent():
              onCancel?.call(event.orderId);
            case PayPalWebCheckoutErrorResultEvent():
              onError?.call(event.error);
          }
        },
        onError: (error) {
          // Handle any errors that occur on the event stream itself.
          onError?.call(error.toString());
        },
      );
    } catch (e) {
      // Catches any initial errors thrown when trying to start the checkout.
      onError?.call(e.toString());
    }
  }
}
