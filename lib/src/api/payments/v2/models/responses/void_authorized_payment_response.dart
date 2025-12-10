import '../../../../models/amount.dart';
import '../../../../models/link.dart';
import '../../../../models/seller_protection.dart';

class VoidAuthorizedPaymentResponseV2 {
  VoidAuthorizedPaymentResponseV2({
    this.id,
    this.status,
    this.amount,
    this.invoiceId,
    this.sellerProtection,
    this.expirationTime,
    this.createTime,
    this.updateTime,
    this.links = const [],
  });

  final String? id;
  final String? status;
  final Amount? amount;
  final String? invoiceId;
  final SellerProtection? sellerProtection;
  final DateTime? expirationTime;
  final DateTime? createTime;
  final DateTime? updateTime;
  final List<Link> links;

  VoidAuthorizedPaymentResponseV2 copy({
    String? id,
    String? status,
    Amount? amount,
    String? invoiceId,
    SellerProtection? sellerProtection,
    DateTime? expirationTime,
    DateTime? createTime,
    DateTime? updateTime,
    List<Link>? links,
  }) {
    return VoidAuthorizedPaymentResponseV2(
      id: id ?? this.id,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      invoiceId: invoiceId ?? this.invoiceId,
      sellerProtection: sellerProtection ?? this.sellerProtection,
      expirationTime: expirationTime ?? this.expirationTime,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      links: links ?? this.links,
    );
  }

  factory VoidAuthorizedPaymentResponseV2.fromJson(Map<String, dynamic> json) {
    return VoidAuthorizedPaymentResponseV2(
      id: json["id"],
      status: json["status"],
      amount: json["amount"] == null ? null : Amount.fromJson(json["amount"]),
      invoiceId: json["invoice_id"],
      sellerProtection: json["seller_protection"] == null
          ? null
          : SellerProtection.fromJson(json["seller_protection"]),
      expirationTime: DateTime.tryParse(json["expiration_time"] ?? ""),
      createTime: DateTime.tryParse(json["create_time"] ?? ""),
      updateTime: DateTime.tryParse(json["update_time"] ?? ""),
      links: json["links"] is! List
          ? []
          : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "amount": amount?.toJson(),
    "invoice_id": invoiceId,
    "seller_protection": sellerProtection?.toJson(),
    "expiration_time": expirationTime?.toIso8601String(),
    "create_time": createTime?.toIso8601String(),
    "update_time": updateTime?.toIso8601String(),
    "links": links.map((x) => x.toJson()).toList(),
  };
}

/*
{
	"id": "5C908745JK343851U",
	"status": "VOIDED",
	"amount": {
		"currency_code": "USD",
		"value": "100.00"
	},
	"invoice_id": "OrderInvoice-10_10_2024_12_06_00_pm",
	"seller_protection": {
		"status": "ELIGIBLE",
		"dispute_categories": [
			"ITEM_NOT_RECEIVED",
			"UNAUTHORIZED_TRANSACTION"
		]
	},
	"expiration_time": "2024-11-08T09:06:03-08:00",
	"create_time": "2024-10-10T10:06:03-07:00",
	"update_time": "2024-10-10T10:06:19-07:00",
	"links": [
		{
			"href": "https://api.paypal.com/v2/payments/authorizations/5C908745JK343851U",
			"rel": "self",
			"method": "GET"
		}
	]
}*/
