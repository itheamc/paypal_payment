import '../../../../utils/extension_functions.dart';

class ShippingAddress {
  ShippingAddress({
    required this.recipientName,
    this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.phone,
    required this.postalCode,
    required this.countryCode,
  });

  final String recipientName;
  final String? line1;
  final String? line2;
  final String city;
  final String state;
  final String phone;
  final String postalCode;
  final String countryCode;

  ShippingAddress copy({
    String? recipientName,
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? phone,
    String? postalCode,
    String? countryCode,
  }) {
    return ShippingAddress(
      recipientName: recipientName ?? this.recipientName,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      phone: phone ?? this.phone,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      recipientName: json["recipient_name"] ?? "",
      line1: json["line1"],
      line2: json["line2"],
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      phone: json["phone"] ?? "",
      postalCode: json["postal_code"] ?? "",
      countryCode: json["country_code"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "recipient_name": recipientName,
    "line1": line1,
    "line2": line2,
    "city": city,
    "state": state,
    "phone": phone,
    "postal_code": postalCode,
    "country_code": countryCode,
  }.filterNotNull();
}
