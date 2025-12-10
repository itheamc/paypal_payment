import '../../../../utils/extension_functions.dart';
import 'shipping_address.dart';

class Payer {
  Payer({required this.paymentMethod, this.fundingInstruments, this.payerInfo});

  final String paymentMethod;
  final List<dynamic>? fundingInstruments;
  final PayerInfo? payerInfo;

  Payer copy({
    String? paymentMethod,
    List<dynamic>? fundingInstruments,
    PayerInfo? payerInfo,
  }) {
    return Payer(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      fundingInstruments: fundingInstruments ?? this.fundingInstruments,
      payerInfo: payerInfo ?? this.payerInfo,
    );
  }

  factory Payer.fromJson(Map<String, dynamic> json) {
    return Payer(
      paymentMethod: json["payment_method"] ?? "paypal",
      fundingInstruments: json["funding_instruments"],
      payerInfo: json["payer_info"] != null
          ? PayerInfo.fromJson(json["payer_info"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "payment_method": paymentMethod,
    "funding_instruments": fundingInstruments,
    "payer_info": payerInfo?.toJson(),
  }.filterNotNull();
}

class PayerInfo {
  PayerInfo({
    this.email,
    this.firstName,
    this.lastName,
    this.payerId,
    this.shippingAddress,
  });

  final String? email;
  final String? firstName;
  final String? lastName;
  final String? payerId;
  final ShippingAddress? shippingAddress;

  PayerInfo copy({
    String? email,
    String? firstName,
    String? lastName,
    String? payerId,
    ShippingAddress? shippingAddress,
  }) {
    return PayerInfo(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      payerId: payerId ?? this.payerId,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }

  factory PayerInfo.fromJson(Map<String, dynamic> json) {
    return PayerInfo(
      email: json["email"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      payerId: json["payer_id"],
      shippingAddress: json["shipping_address"] == null
          ? null
          : ShippingAddress.fromJson(json["shipping_address"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "payer_id": payerId,
    "shipping_address": shippingAddress?.toJson(),
  }.filterNotNull();
}
