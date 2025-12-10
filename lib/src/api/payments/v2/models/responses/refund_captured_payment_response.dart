import '../../../../models/amount.dart';
import '../../../../models/link.dart';

class RefundCapturedPaymentResponseV2 {
  RefundCapturedPaymentResponseV2({
    this.id,
    this.amount,
    this.sellerPayableBreakdown,
    this.invoiceId,
    this.status,
    this.createTime,
    this.updateTime,
    this.links = const [],
  });

  final String? id;
  final Amount? amount;
  final SellerPayableBreakdown? sellerPayableBreakdown;
  final String? invoiceId;
  final String? status;
  final DateTime? createTime;
  final DateTime? updateTime;
  final List<Link> links;

  RefundCapturedPaymentResponseV2 copy({
    String? id,
    Amount? amount,
    SellerPayableBreakdown? sellerPayableBreakdown,
    String? invoiceId,
    String? status,
    DateTime? createTime,
    DateTime? updateTime,
    List<Link>? links,
  }) {
    return RefundCapturedPaymentResponseV2(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      sellerPayableBreakdown:
          sellerPayableBreakdown ?? this.sellerPayableBreakdown,
      invoiceId: invoiceId ?? this.invoiceId,
      status: status ?? this.status,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      links: links ?? this.links,
    );
  }

  factory RefundCapturedPaymentResponseV2.fromJson(Map<String, dynamic> json) {
    return RefundCapturedPaymentResponseV2(
      id: json["id"],
      amount: json["amount"] == null ? null : Amount.fromJson(json["amount"]),
      sellerPayableBreakdown: json["seller_payable_breakdown"] == null
          ? null
          : SellerPayableBreakdown.fromJson(json["seller_payable_breakdown"]),
      invoiceId: json["invoice_id"],
      status: json["status"],
      createTime: DateTime.tryParse(json["create_time"] ?? ""),
      updateTime: DateTime.tryParse(json["update_time"] ?? ""),
      links: json["links"] is! List
          ? []
          : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "amount": amount?.toJson(),
    "seller_payable_breakdown": sellerPayableBreakdown?.toJson(),
    "invoice_id": invoiceId,
    "status": status,
    "create_time": createTime?.toIso8601String(),
    "update_time": updateTime?.toIso8601String(),
    "links": links.map((x) => x.toJson()).toList(),
  };
}

class SellerPayableBreakdown {
  SellerPayableBreakdown({
    this.grossAmount,
    this.paypalFee,
    this.netAmount,
    this.totalRefundedAmount,
  });

  final Amount? grossAmount;
  final Amount? paypalFee;
  final Amount? netAmount;
  final Amount? totalRefundedAmount;

  SellerPayableBreakdown copy({
    Amount? grossAmount,
    Amount? paypalFee,
    Amount? netAmount,
    Amount? totalRefundedAmount,
  }) {
    return SellerPayableBreakdown(
      grossAmount: grossAmount ?? this.grossAmount,
      paypalFee: paypalFee ?? this.paypalFee,
      netAmount: netAmount ?? this.netAmount,
      totalRefundedAmount: totalRefundedAmount ?? this.totalRefundedAmount,
    );
  }

  factory SellerPayableBreakdown.fromJson(Map<String, dynamic> json) {
    return SellerPayableBreakdown(
      grossAmount: json["gross_amount"] == null
          ? null
          : Amount.fromJson(json["gross_amount"]),
      paypalFee: json["paypal_fee"] == null
          ? null
          : Amount.fromJson(json["paypal_fee"]),
      netAmount: json["net_amount"] == null
          ? null
          : Amount.fromJson(json["net_amount"]),
      totalRefundedAmount: json["total_refunded_amount"] == null
          ? null
          : Amount.fromJson(json["total_refunded_amount"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "gross_amount": grossAmount?.toJson(),
    "paypal_fee": paypalFee?.toJson(),
    "net_amount": netAmount?.toJson(),
    "total_refunded_amount": totalRefundedAmount?.toJson(),
  };
}

/*
{
	"id": "58K15806CS993444T",
	"amount": {
		"currency_code": "USD",
		"value": "89.00"
	},
	"seller_payable_breakdown": {
		"gross_amount": {
			"currency_code": "USD",
			"value": "89.00"
		},
		"paypal_fee": {
			"currency_code": "USD",
			"value": "0.00"
		},
		"net_amount": {
			"currency_code": "USD",
			"value": "89.00"
		},
		"total_refunded_amount": {
			"currency_code": "USD",
			"value": "100.00"
		}
	},
	"invoice_id": "OrderInvoice-10_10_2024_12_58_20_pm",
	"status": "COMPLETED",
	"create_time": "2024-10-14T15:03:29-07:00",
	"update_time": "2024-10-14T15:03:29-07:00",
	"links": [
		{
			"href": "https://api.msmaster.qa.paypal.com/v2/payments/refunds/58K15806CS993444T",
			"rel": "self",
			"method": "GET"
		},
		{
			"href": "https://api.msmaster.qa.paypal.com/v2/payments/captures/7TK53561YB803214S",
			"rel": "up",
			"method": "GET"
		}
	]
}*/
