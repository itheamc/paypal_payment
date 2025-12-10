import '../../../../models/link.dart';
import '../transaction.dart';

class CaptureOrderPaymentResponseV1 {
  CaptureOrderPaymentResponseV1({
    this.id,
    this.createTime,
    this.updateTime,
    this.amount,
    this.isFinalCapture,
    this.state,
    this.parentPayment,
    this.links = const [],
  });

  final String? id;
  final DateTime? createTime;
  final DateTime? updateTime;
  final TransactionAmount? amount;
  final bool? isFinalCapture;
  final String? state;
  final String? parentPayment;
  final List<Link> links;

  CaptureOrderPaymentResponseV1 copy({
    String? id,
    DateTime? createTime,
    DateTime? updateTime,
    TransactionAmount? amount,
    bool? isFinalCapture,
    String? state,
    String? parentPayment,
    List<Link>? links,
  }) {
    return CaptureOrderPaymentResponseV1(
      id: id ?? this.id,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      amount: amount ?? this.amount,
      isFinalCapture: isFinalCapture ?? this.isFinalCapture,
      state: state ?? this.state,
      parentPayment: parentPayment ?? this.parentPayment,
      links: links ?? this.links,
    );
  }

  factory CaptureOrderPaymentResponseV1.fromJson(Map<String, dynamic> json) {
    return CaptureOrderPaymentResponseV1(
      id: json["id"],
      createTime: DateTime.tryParse(json["create_time"] ?? ""),
      updateTime: DateTime.tryParse(json["update_time"] ?? ""),
      amount: json["amount"] == null
          ? null
          : TransactionAmount.fromJson(json["amount"]),
      isFinalCapture: json["is_final_capture"],
      state: json["state"],
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
    "amount": amount?.toJson(),
    "is_final_capture": isFinalCapture,
    "state": state,
    "parent_payment": parentPayment,
    "links": links.map((x) => x.toJson()).toList(),
  };
}

/*
{
	"id": "51366113MA710110S",
	"create_time": "2017-07-01T17:13:45Z",
	"update_time": "2017-07-01T17:13:47Z",
	"amount": {
		"total": "7.00",
		"currency": "USD"
	},
	"is_final_capture": false,
	"state": "COMPLETED",
	"parent_payment": "PAY-9N9834337A9191208KOZOQWI",
	"links": [
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/capture/51366113MA710110S",
			"rel": "self",
			"method": "GET"
		},
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/capture/51366113MA710110S/refund",
			"rel": "refund",
			"method": "POST"
		},
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/orders/O-3SP845109F051535C",
			"rel": "order",
			"method": "GET"
		},
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/payment/PAY-9N9834337A9191208KOZOQWI",
			"rel": "parent_payment",
			"method": "GET"
		}
	]
}*/
