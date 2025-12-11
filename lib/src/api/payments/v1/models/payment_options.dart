import '../../../../utils/extension_functions.dart';

class PaymentOptions {
  PaymentOptions({this.allowedPaymentMethod});

  final String? allowedPaymentMethod;

  PaymentOptions copyWith({String? allowedPaymentMethod}) {
    return PaymentOptions(
      allowedPaymentMethod: allowedPaymentMethod ?? this.allowedPaymentMethod,
    );
  }

  factory PaymentOptions.fromJson(Map<String, dynamic> json) {
    return PaymentOptions(allowedPaymentMethod: json["allowed_payment_method"]);
  }

  Map<String, dynamic> toJson() =>
      {"allowed_payment_method": allowedPaymentMethod}.filterNotNull();
}
