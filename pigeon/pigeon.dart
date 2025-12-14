import 'package:pigeon/pigeon.dart';

// Configures Pigeon's code generation options. This block specifies the output
// paths and package names for the generated Dart, Kotlin, and Swift files.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon_generated.dart',
    dartPackageName: 'paypal_payment_flutter',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/itheamc/paypal_payment_flutter/pigeon/PigeonGenerated.kt',
    kotlinOptions: KotlinOptions(),
    swiftOut: 'ios/Classes/Pigeon/PigeonGenerated.swift',
    swiftOptions: SwiftOptions(),
  ),
)
// Marks the interface as a Host API, meaning Dart will call these methods,
// and they must be implemented on the host platform (Android/iOS).
@HostApi()
abstract class PaypalPaymentHostApi {
  /// Initializes the PayPal SDK with the provided client ID and environment.
  ///
  /// [clientId]: The unique client ID for the PayPal application.
  /// [environment]: The environment (e.g., 'live', 'sandbox').
  void initialize(String clientId, String environment);
}

/// Host API for handling PayPal Web/App-based payments (e.g., "Pay with PayPal").
@HostApi()
abstract class PaypalWebPaymentHostApi {
  /// Initiates a PayPal web-based payment request.
  ///
  /// [orderId] The ID of the order created on the server-side.
  /// [fundingSource] The preferred funding source (e.g., 'paypal', 'paylater').
  void initiatePaymentRequest(String orderId, String fundingSource);
}

/// Host API for handling PayPal card payments.
@HostApi()
abstract class PaypalCardPaymentHostApi {
  /// Initiates a PayPal payment using card details.
  ///
  /// [orderId] The ID of the order created on the server-side.
  /// [card] The structured data for the payment card.
  /// [sca] A string indicating the desired Strong Customer Authentication flow (e.g., 'SCA_ALWAYS').
  void initiatePaymentRequest(String orderId, CardData card, String sca);
}

/// --- Result Event Structures ---

/// For Paypal Web Payment Request Result
///
/// Base sealed class for all possible outcomes of a PayPal Web Payment request.
/// Sealed classes help ensure all result types are handled in Dart.
sealed class PaypalWebPaymentRequestResultEvent {}

/// Represents a successful completion of the PayPal Web Payment flow.
class PaypalWebPaymentRequestSuccessResultEvent
    extends PaypalWebPaymentRequestResultEvent {
  /// Constructs a success result event.
  PaypalWebPaymentRequestSuccessResultEvent(this.orderId, this.payerId);

  /// The ID of the successfully completed order.
  final String? orderId;

  /// The ID of the payer provided by PayPal.
  final String? payerId;
}

/// Represents a failure during the PayPal Web Payment process.
class PaypalWebPaymentRequestFailureResultEvent
    extends PaypalWebPaymentRequestResultEvent {
  /// Constructs a failure result event.
  PaypalWebPaymentRequestFailureResultEvent(
    this.orderId,
    this.reason,
    this.code,
    this.correlationId,
  );

  /// The ID of the order that failed.
  final String? orderId;

  /// A human-readable description of the failure.
  final String reason;

  /// A numeric error code associated with the failure.
  final int code;

  /// A unique ID that can be used to correlate the failure with server logs.
  final String? correlationId;
}

/// Represents the case where the user cancels the PayPal Web Payment flow.
class PaypalWebPaymentRequestCanceledResultEvent
    extends PaypalWebPaymentRequestResultEvent {
  /// Constructs a canceled result event.
  PaypalWebPaymentRequestCanceledResultEvent(this.orderId);

  /// The ID of the order that was cancelled.
  final String? orderId;
}

/// Represents a critical error in the host platform's logic or SDK communication.
class PaypalWebPaymentRequestErrorResultEvent
    extends PaypalWebPaymentRequestResultEvent {
  /// Constructs an error result event.
  PaypalWebPaymentRequestErrorResultEvent(this.error);

  /// A detailed error message string.
  final String? error;
}

/// For Paypal Card Payment Request Result
///
/// Base sealed class for all possible outcomes of a PayPal Card Payment request.
sealed class PaypalCardPaymentRequestResultEvent {}

/// Represents a successful completion of the PayPal Card Payment flow.
class PaypalCardPaymentRequestSuccessResultEvent
    extends PaypalCardPaymentRequestResultEvent {
  /// Constructs a success result event.
  PaypalCardPaymentRequestSuccessResultEvent(
    this.orderId,
    this.status,
    this.didAttemptThreeDSecureAuthentication,
  );

  /// The ID of the successfully completed order.
  final String? orderId;

  /// The status of the card payment transaction.
  final String? status;

  /// Indicates whether 3D Secure Authentication was attempted for the transaction.
  final bool didAttemptThreeDSecureAuthentication;
}

/// Represents a failure during the PayPal Card Payment process.
class PaypalCardPaymentRequestFailureResultEvent
    extends PaypalCardPaymentRequestResultEvent {
  /// Constructs a failure result event.
  PaypalCardPaymentRequestFailureResultEvent(
    this.orderId,
    this.reason,
    this.code,
    this.correlationId,
  );

  /// The ID of the order that failed.
  final String? orderId;

  /// A human-readable description of the failure.
  final String reason;

  /// A numeric error code associated with the failure.
  final int code;

  /// A unique ID that can be used to correlate the failure with server logs.
  final String? correlationId;
}

/// Represents the case where the user cancels the PayPal Card Payment flow (e.g., during 3DS challenge).
class PaypalCardPaymentRequestCanceledResultEvent
    extends PaypalCardPaymentRequestResultEvent {
  /// Constructs a canceled result event.
  PaypalCardPaymentRequestCanceledResultEvent(this.orderId);

  /// The ID of the order that was cancelled.
  final String? orderId;
}

/// Represents a critical error in the host platform's logic or SDK communication for card payments.
class PaypalCardPaymentRequestErrorResultEvent
    extends PaypalCardPaymentRequestResultEvent {
  /// Constructs an error result event.
  PaypalCardPaymentRequestErrorResultEvent(this.error);

  /// A detailed error message string.
  final String? error;
}

// Marks the interface as an Event Channel API, meaning the host platform (Android/iOS)
// will call these methods to send events back to Dart.
@EventChannelApi()
abstract class PaypalPaymentRequestResultEventChannelApi {
  /// The channel method for transmitting the result of a PayPal Web Payment request back to Dart.
  PaypalWebPaymentRequestResultEvent paypalWebPaymentRequestResultEvent();

  /// The channel method for transmitting the result of a PayPal Card Payment request back to Dart.
  PaypalCardPaymentRequestResultEvent paypalCardPaymentRequestResultEvent();
}

/// Data structure representing the details of a payment card.
class CardData {
  /// The card's primary account number.
  final String number;

  /// The expiration month of the card (e.g., '08').
  final String expirationMonth;

  /// The expiration year of the card (e.g., '2025').
  final String expirationYear;

  /// The 3- or 4-digit security code (CVV/CVC).
  final String securityCode;

  /// The name of the cardholder as it appears on the card.
  final String cardholderName;

  /// The billing address associated with the card.
  final BillingAddressData billingAddress;

  /// Constructs a CardData object.
  CardData(
    this.number,
    this.expirationMonth,
    this.expirationYear,
    this.securityCode,
    this.cardholderName,
    this.billingAddress,
  );
}

/// Data structure representing the billing address for a payment card.
class BillingAddressData {
  /// The two-letter country code (e.g., 'US', 'GB'). (Required)
  final String countryCode;

  /// The first line of the street address. (Optional)
  final String? streetAddress;

  /// The second line of the street address, if any. (Optional)
  final String? extendedAddress;

  /// The city or locality. (Optional)
  final String? locality;

  /// The state, province, or region. (Optional)
  final String? region;

  /// The postal or ZIP code. (Optional)
  final String? postalCode;

  /// Constructs a BillingAddressData object.
  BillingAddressData(
    this.countryCode,
    this.streetAddress,
    this.extendedAddress,
    this.locality,
    this.region,
    this.postalCode,
  );
}
