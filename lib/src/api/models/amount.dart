class Amount {
  Amount({required this.currencyCode, required this.value});

  final String currencyCode;
  final String value;

  Amount copy({String? currencyCode, String? value}) {
    return Amount(
      currencyCode: currencyCode ?? this.currencyCode,
      value: value ?? this.value,
    );
  }

  factory Amount.fromJson(Map<String, dynamic> json) {
    return Amount(
      currencyCode: json["currency_code"] ?? json['currency'],
      value: json["value"].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "currency_code": currencyCode,
    "value": value,
  };
}
