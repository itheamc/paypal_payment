import '../../../../models/link.dart';
import '../../../../../utils/extension_functions.dart';
import '../transaction.dart';

class RefundCapturedPaymentResponseV1 {
  RefundCapturedPaymentResponseV1({
    this.id,
    this.createTime,
    this.updateTime,
    this.state,
    this.amount,
    this.captureId,
    this.parentPayment,
    this.links = const [],
  });

  final String? id;
  final DateTime? createTime;
  final DateTime? updateTime;
  final String? state;
  final TransactionAmount? amount;
  final String? captureId;
  final String? parentPayment;
  final List<Link> links;

  RefundCapturedPaymentResponseV1 copy({
    String? id,
    DateTime? createTime,
    DateTime? updateTime,
    String? state,
    TransactionAmount? amount,
    String? captureId,
    String? parentPayment,
    List<Link>? links,
  }) {
    return RefundCapturedPaymentResponseV1(
      id: id ?? this.id,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      state: state ?? this.state,
      amount: amount ?? this.amount,
      captureId: captureId ?? this.captureId,
      parentPayment: parentPayment ?? this.parentPayment,
      links: links ?? this.links,
    );
  }

  factory RefundCapturedPaymentResponseV1.fromJson(Map<String, dynamic> json) {
    return RefundCapturedPaymentResponseV1(
      id: json["id"],
      createTime: DateTime.tryParse(json["create_time"] ?? ""),
      updateTime: DateTime.tryParse(json["update_time"] ?? ""),
      state: json["state"],
      amount: json["amount"] == null
          ? null
          : TransactionAmount.fromJson(json["amount"]),
      captureId: json["capture_id"],
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
    "capture_id": captureId,
    "parent_payment": parentPayment,
    "links": links.map((x) => x.toJson()).toList(),
  }.filterNotNull();
}

/*
{
	"id": "0P209507D6694645N",
	"create_time": "2017-05-06T22:11:51Z",
	"update_time": "2017-05-06T22:11:51Z",
	"state": "COMPLETED",
	"amount": {
		"total": "110.54",
		"currency": "USD"
	},
	"capture_id": "8F148933LY9388354",
	"parent_payment": "PAY-8PT597110X687430LKGECATA",
	"links": [
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/refund/0P209507D6694645N",
			"rel": "self",
			"method": "GET"
		},
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/payment/PAY-8PT597110X687430LKGECATA",
			"rel": "parent_payment",
			"method": "GET"
		},
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/capture/8F148933LY9388354",
			"rel": "capture",
			"method": "GET"
		}
	]
}*/
