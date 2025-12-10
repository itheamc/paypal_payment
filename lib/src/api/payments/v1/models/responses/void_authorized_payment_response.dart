import '../../../../../utils/extension_functions.dart';
import '../../../../models/link.dart';
import '../transaction.dart';

class VoidAuthorizedPaymentResponseV1 {
  VoidAuthorizedPaymentResponseV1({
    this.id,
    this.createTime,
    this.updateTime,
    this.state,
    this.amount,
    this.parentPayment,
    this.links = const [],
  });

  final String? id;
  final DateTime? createTime;
  final DateTime? updateTime;
  final String? state;
  final TransactionAmount? amount;
  final String? parentPayment;
  final List<Link> links;

  VoidAuthorizedPaymentResponseV1 copy({
    String? id,
    DateTime? createTime,
    DateTime? updateTime,
    String? state,
    TransactionAmount? amount,
    String? parentPayment,
    List<Link>? links,
  }) {
    return VoidAuthorizedPaymentResponseV1(
      id: id ?? this.id,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      state: state ?? this.state,
      amount: amount ?? this.amount,
      parentPayment: parentPayment ?? this.parentPayment,
      links: links ?? this.links,
    );
  }

  factory VoidAuthorizedPaymentResponseV1.fromJson(Map<String, dynamic> json) {
    return VoidAuthorizedPaymentResponseV1(
      id: json["id"],
      createTime: DateTime.tryParse(json["create_time"] ?? ""),
      updateTime: DateTime.tryParse(json["update_time"] ?? ""),
      state: json["state"],
      amount: json["amount"] == null
          ? null
          : TransactionAmount.fromJson(json["amount"]),
      parentPayment: json["parent_payment"],
      links: json["links"] is! List
          ? []
          : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "create_time": createTime?.toIso8601String(),
    "update_time": updateTime?.toIso8601String(),
    "state": state,
    "amount": amount?.toJson(),
    "parent_payment": parentPayment,
    "links": links.map((x) => x.toJson()).toList(),
  }.filterNotNull();
}

/*
{
	"id": "6CR34526N64144512",
	"create_time": "2017-05-06T21:56:50Z",
	"update_time": "2017-05-06T21:57:51Z",
	"state": "VOIDED",
	"amount": {
		"total": "110.54",
		"currency": "USD",
		"details": {
			"subtotal": "110.54"
		}
	},
	"parent_payment": "PAY-0PL82432AD7432233KGECOIQ",
	"links": [
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/authorization/6CR34526N64144512",
			"rel": "self",
			"method": "GET"
		},
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/payment/PAY-0PL82432AD7432233KGECOIQ",
			"rel": "parent_payment",
			"method": "GET"
		}
	]
}*/
