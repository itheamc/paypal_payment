/// Represents a monetary amount, including the currency code and value.
class Amount {
  /// Creates an instance of [Amount].
  ///
  /// [currencyCode] is the three-letter ISO 4217 currency code.
  /// [value] is the amount, as a string.
  Amount({required this.currencyCode, required this.value});

  /// The three-letter ISO 4217 currency code.
  final String currencyCode;

  /// The amount, as a string.
  final String value;

  /// Creates a copy of this [Amount] with the given fields replaced with new values.
  Amount copy({String? currencyCode, String? value}) {
    return Amount(
      currencyCode: currencyCode ?? this.currencyCode,
      value: value ?? this.value,
    );
  }

  /// Creates an [Amount] from a JSON object.
  ///
  /// This factory can handle both `currency_code` and `currency` keys for the
  /// currency code.
  factory Amount.fromJson(Map<String, dynamic> json) {
    return Amount(
      currencyCode: json["currency_code"] ?? json['currency'],
      value: json["value"].toString(),
    );
  }

  /// Converts this [Amount] object to a JSON object.
  Map<String, dynamic> toJson() => {
    "currency_code": currencyCode,
    "value": value,
  };
}
