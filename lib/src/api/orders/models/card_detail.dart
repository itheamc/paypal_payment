import 'package:paypal_payment_flutter/src/pigeon_generated.dart';

/// Encapsulates all information required to represent a payment card.
///
/// This model is typically used for:
/// - Tokenization of card details
/// - Payment authorization
/// - Card verification flows
///
/// ⚠️ **Security Notice**
/// Sensitive fields such as [number] and [securityCode] should **never**
/// be logged, stored in plaintext, or persisted beyond the scope of the
/// payment request.
///
/// This class does not perform validation by itself.
/// Validation (Luhn check, expiry date validation, etc.) should be handled
/// by the consuming layer.
class CardDetail {
  /// The Primary Account Number (PAN) of the card.
  ///
  /// Must contain only numeric characters and typically ranges
  /// between 13 and 19 digits depending on the card network.
  ///
  /// Examples:
  /// - Visa: `4111111111111111`
  /// - MasterCard: `5555555555554444`
  ///
  /// ⚠️ Highly sensitive information.
  final String number;

  /// The card expiration month.
  ///
  /// Expected format is **two digits** (`MM`), ranging from `01` to `12`.
  ///
  /// Example:
  /// ```dart
  /// expirationMonth: '09'
  /// ```
  final String expirationMonth;

  /// The card expiration year.
  ///
  /// Expected format is **four digits** (`YYYY`).
  /// The value must represent a year that is not in the past.
  ///
  /// Example:
  /// ```dart
  /// expirationYear: '2030'
  /// ```
  final String expirationYear;

  /// The card security code.
  ///
  /// Also known as:
  /// - CVV (Visa)
  /// - CVC (Mastercard)
  /// - CID (American Express)
  ///
  /// Typically:
  /// - 3 digits for Visa/Mastercard
  /// - 4 digits for American Express
  ///
  /// ⚠️ Must never be stored or logged.
  final String securityCode;

  /// The full name of the cardholder.
  ///
  /// This should match the name printed on the card
  /// and may be required for address verification (AVS).
  ///
  /// Example:
  /// ```dart
  /// cardholderName: 'John Doe'
  /// ```
  final String cardholderName;

  /// The billing address associated with the card.
  ///
  /// This information is commonly used for:
  /// - Address Verification Service (AVS)
  /// - Fraud prevention
  /// - Regulatory compliance
  ///
  /// Some payment gateways may only require [BillingAddress.countryCode].
  final BillingAddress billingAddress;

  /// Creates a new immutable instance of [CardDetail].
  ///
  /// All fields are required to ensure a complete representation
  /// of the card, even if some nested address fields are nullable.
  const CardDetail({
    required this.number,
    required this.expirationMonth,
    required this.expirationYear,
    required this.securityCode,
    required this.cardholderName,
    required this.billingAddress,
  });
}

/// Represents the billing address tied to a payment card.
///
/// This address is used primarily for verification and fraud checks.
/// Not all fields are mandatory, depending on the payment provider
/// or country-specific regulations.
class BillingAddress {
  /// The ISO 3166-1 alpha-2 country code.
  ///
  /// Must be a two-letter uppercase country identifier.
  ///
  /// Examples:
  /// - `US` (United States)
  /// - `IN` (India)
  /// - `GB` (United Kingdom)
  final String countryCode;

  /// The primary street address (house number and street name).
  ///
  /// Example:
  /// ```dart
  /// streetAddress: '123 Main Street'
  /// ```
  ///
  /// May be null if the payment processor does not require it.
  final String? streetAddress;

  /// Additional address information.
  ///
  /// Commonly used for:
  /// - Apartment number
  /// - Suite
  /// - Floor or building name
  ///
  /// Example:
  /// ```dart
  /// extendedAddress: 'Apt 4B'
  /// ```
  final String? extendedAddress;

  /// The city, town, or locality.
  ///
  /// Example:
  /// ```dart
  /// locality: 'San Francisco'
  /// ```
  final String? locality;

  /// The state, province, or administrative region.
  ///
  /// Examples:
  /// - `CA` (California)
  /// - `MH` (Maharashtra)
  ///
  /// This field may be required for AVS in certain countries.
  final String? region;

  /// The postal or ZIP code.
  ///
  /// Examples:
  /// - `94105`
  /// - `400001`
  ///
  /// Used for address verification and fraud checks.
  final String? postalCode;

  /// Creates a new immutable instance of [BillingAddress].
  ///
  /// Only [countryCode] is mandatory, allowing flexibility
  /// across different regions and gateway requirements.
  const BillingAddress({
    required this.countryCode,
    this.streetAddress,
    this.extendedAddress,
    this.locality,
    this.region,
    this.postalCode,
  });
}

/// Extension utilities for converting [CardDetail] into
/// data-layer specific models.
///
/// ⚠️ **Security Notice**
/// This transformation contains highly sensitive payment information.
/// The resulting [CardData] object must:
/// - Be used only for immediate payment or tokenization requests
/// - Never be logged
/// - Never be cached or persisted
///
/// No validation or formatting is performed during this conversion.
/// All fields are copied as-is.
extension CardDetailExt on CardDetail {
  /// Converts this [CardDetail] instance into a [CardData] object.
  ///
  /// This getter performs a **field-to-field mapping** without mutation
  /// or transformation.
  ///
  /// ⚠️ The returned object contains sensitive cardholder data and
  /// must be handled according to PCI-DSS guidelines.
  CardData get toCardData => CardData(
    number: number,
    expirationMonth: expirationMonth,
    expirationYear: expirationYear,
    securityCode: securityCode,
    cardholderName: cardholderName,
    billingAddress: BillingAddressData(
      countryCode: billingAddress.countryCode,
      streetAddress: billingAddress.streetAddress,
      extendedAddress: billingAddress.extendedAddress,
      locality: billingAddress.locality,
      region: billingAddress.region,
      postalCode: billingAddress.postalCode,
    ),
  );
}
