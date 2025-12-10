import 'dart:convert';

import '../../../network/http_exception.dart';
import '../../../network/http_response_validator.dart';
import '../../../network/paypal_http_service.dart';
import '../../../utils/extension_functions.dart';
import '../../../utils/logger.dart';
import '../../models/amount.dart';
import 'models/responses/capture_authorized_payment_response.dart';
import 'models/responses/refund_captured_payment_response.dart';
import 'models/responses/void_authorized_payment_response.dart';

/// Provides access to version 2 of the PayPal Payments API.
///
/// This class is a singleton and provides methods for interacting with
/// PayPal's REST API v2 endpoints, such as creating and managing orders.
class PaymentsApiV2 {
  /// A reference to the shared [PaypalHttpService] instance used for all
  /// network requests.
  ///
  final PaypalHttpService _httpService;

  /// Private internal constructor to enforce the singleton pattern.
  ///
  PaymentsApiV2._() : _httpService = PaypalHttpService.instance;

  /// The static, private instance of the [PaymentsApiV2].
  ///
  static PaymentsApiV2? _instance;

  /// Provides a lazy-loaded, singleton instance of the [PaymentsApiV2].
  ///
  /// This ensures that only one instance of the V2 API handler exists
  /// throughout the application's lifecycle.
  ///
  static PaymentsApiV2 get instance {
    if (_instance == null) {
      Logger.logMessage("PaymentsApiV2 is initialized!");
    }
    _instance ??= PaymentsApiV2._();
    return _instance!;
  }

  /// Captures an authorized payment.
  ///
  /// This method finalizes a previously authorized payment by capturing a
  /// specific amount. It requires the [authorizationId] of the original
  /// authorized payment. Callbacks are provided to handle the different
  /// outcomes of the API call.
  ///
  /// - [authorizationId]: The ID of the payment authorization to capture.
  ///   This is a required parameter.
  /// - [amount]: The amount to capture. This can be the full or a partial
  ///   amount of the original authorization. This is required.
  /// - [invoiceId]: Optional. The API caller-provided external invoice number
  ///   for this order.
  /// - [noteToPayer]: Optional. A note to the payer.
  /// - [softDescriptor]: Optional. A description that appears on the payer's
  ///   credit card statement.
  /// - [finalCapture]: Optional. Indicates whether this is the final capture
  ///   for the authorization. Defaults to `false`. Set to `true` if you do not
  ///   intend to capture additional funds later.
  /// - [onInitiated]: A callback function that is invoked when the process begins.
  /// - [onPreRequest]: A callback providing the constructed endpoint and payload,
  ///   useful for debugging just before the network request is sent.
  /// - [onSuccess]: A callback function that is invoked upon a successful capture,
  ///   providing a [CaptureAuthorizedPaymentResponseV2] object.
  /// - [onError]: A callback function that is invoked if an error occurs,
  ///   providing an error message.
  ///
  Future<void> captureAuthorizedPayment({
    required String authorizationId,
    required Amount amount,
    String? invoiceId,
    String? noteToPayer,
    String? softDescriptor,
    bool finalCapture = false,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(CaptureAuthorizedPaymentResponseV2)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v2/payments/authorizations/$authorizationId/capture';

      final payload = {
        "amount": amount.toJson(),
        "final_capture": finalCapture,
        "invoice_id": invoiceId,
        "note_to_payer": noteToPayer,
        "soft_descriptor": softDescriptor,
      }.filterNotNull();

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(CaptureAuthorizedPaymentResponseV2.fromJson(decoded));
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
  /// https://developer.paypal.com/docs/api/payments/v2/#authorizations_void
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
    void Function(VoidAuthorizedPaymentResponseV2)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v2/payments/authorizations/$authorizationId/void';

      final payload = <String, dynamic>{};

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(VoidAuthorizedPaymentResponseV2.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  /// Refunds a previously captured payment.
  ///
  /// This method is used to issue a full or partial refund for a payment  /// that has already been captured. It requires the [captureId] of the
  /// original transaction. Callbacks are provided to handle the different
  /// outcomes of the API call.
  ///
  /// - [captureId]: The ID of the captured payment to refund. This is required.
  /// - [amount]: The amount to be refunded. This is required.
  /// - [customId]: Optional. The API caller-provided external ID. Used to
  ///   reconcile API calls with external systems.
  /// - [invoiceId]: Optional. The API caller-provided external invoice number
  ///   for this refund.
  /// - [noteToPayer]: Optional. A note to the payer explaining the reason for
  ///   the refund.
  /// - [onInitiated]: A callback function that is invoked when the process begins.
  /// - [onPreRequest]: A callback providing the constructed endpoint and payload,
  ///   useful for debugging just before the network request is sent.
  /// - [onSuccess]: A callback function that is invoked upon a successful refund,
  ///   providing a [RefundCapturedPaymentResponseV2] object.
  /// - [onError]: A callback function that is invoked if an error occurs,
  ///   providing an error message.
  Future<void> refundCapturedPayment({
    required String captureId,
    required Amount amount,
    String? customId,
    String? invoiceId,
    String? noteToPayer,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> payload)? onPreRequest,
    void Function(RefundCapturedPaymentResponseV2)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final endpoint = '/v2/payments/captures/$captureId/refund';

      final payload = <String, dynamic>{
        "amount": amount.toJson(),
        "custom_id": customId,
        "invoice_id": invoiceId,
        "note_to_payer": noteToPayer,
      }.filterNotNull();

      onPreRequest?.call(endpoint, payload);

      final response = await _httpService.post(
        endpoint,
        payload,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(RefundCapturedPaymentResponseV2.fromJson(decoded));
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
