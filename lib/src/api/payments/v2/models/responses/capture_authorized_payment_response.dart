import '../../../../models/amount.dart';
import '../../../../models/link.dart';
import '../seller_protection.dart';

class CaptureAuthorizedPaymentResponseV2 {
  CaptureAuthorizedPaymentResponseV2({
    this.id,
    this.amount,
    this.finalCapture,
    this.sellerProtection,
    this.sellerReceivableBreakdown,
    this.invoiceId,
    this.status,
    this.statusDetails,
    this.createTime,
    this.updateTime,
    this.links = const [],
  });

  final String? id;
  final Amount? amount;
  final bool? finalCapture;
  final SellerProtection? sellerProtection;
  final SellerReceivableBreakdown? sellerReceivableBreakdown;
  final String? invoiceId;
  final String? status;
  final StatusDetails? statusDetails;
  final DateTime? createTime;
  final DateTime? updateTime;
  final List<Link> links;

  CaptureAuthorizedPaymentResponseV2 copy({
    String? id,
    Amount? amount,
    bool? finalCapture,
    SellerProtection? sellerProtection,
    SellerReceivableBreakdown? sellerReceivableBreakdown,
    String? invoiceId,
    String? status,
    StatusDetails? statusDetails,
    DateTime? createTime,
    DateTime? updateTime,
    List<Link>? links,
  }) {
    return CaptureAuthorizedPaymentResponseV2(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      finalCapture: finalCapture ?? this.finalCapture,
      sellerProtection: sellerProtection ?? this.sellerProtection,
      sellerReceivableBreakdown:
          sellerReceivableBreakdown ?? this.sellerReceivableBreakdown,
      invoiceId: invoiceId ?? this.invoiceId,
      status: status ?? this.status,
      statusDetails: statusDetails ?? this.statusDetails,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      links: links ?? this.links,
    );
  }

  factory CaptureAuthorizedPaymentResponseV2.fromJson(
    Map<String, dynamic> json,
  ) {
    return CaptureAuthorizedPaymentResponseV2(
      id: json["id"],
      amount: json["amount"] == null ? null : Amount.fromJson(json["amount"]),
      finalCapture: json["final_capture"],
      sellerProtection: json["seller_protection"] == null
          ? null
          : SellerProtection.fromJson(json["seller_protection"]),
      sellerReceivableBreakdown: json["seller_receivable_breakdown"] == null
          ? null
          : SellerReceivableBreakdown.fromJson(
              json["seller_receivable_breakdown"],
            ),
      invoiceId: json["invoice_id"],
      status: json["status"],
      statusDetails: json["status_details"] == null
          ? null
          : StatusDetails.fromJson(json["status_details"]),
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
    "final_capture": finalCapture,
    "seller_protection": sellerProtection?.toJson(),
    "seller_receivable_breakdown": sellerReceivableBreakdown?.toJson(),
    "invoice_id": invoiceId,
    "status": status,
    "status_details": statusDetails?.toJson(),
    "create_time": createTime?.toIso8601String(),
    "update_time": updateTime?.toIso8601String(),
    "links": links.map((x) => x.toJson()).toList(),
  };
}

class SellerReceivableBreakdown {
  SellerReceivableBreakdown({
    this.grossAmount,
    this.paypalFee,
    this.netAmount,
    this.exchangeRate,
  });

  final Amount? grossAmount;
  final Amount? paypalFee;
  final Amount? netAmount;
  final ExchangeRate? exchangeRate;

  SellerReceivableBreakdown copy({
    Amount? grossAmount,
    Amount? paypalFee,
    Amount? netAmount,
    ExchangeRate? exchangeRate,
  }) {
    return SellerReceivableBreakdown(
      grossAmount: grossAmount ?? this.grossAmount,
      paypalFee: paypalFee ?? this.paypalFee,
      netAmount: netAmount ?? this.netAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }

  factory SellerReceivableBreakdown.fromJson(Map<String, dynamic> json) {
    return SellerReceivableBreakdown(
      grossAmount: json["gross_amount"] == null
          ? null
          : Amount.fromJson(json["gross_amount"]),
      paypalFee: json["paypal_fee"] == null
          ? null
          : Amount.fromJson(json["paypal_fee"]),
      netAmount: json["net_amount"] == null
          ? null
          : Amount.fromJson(json["net_amount"]),
      exchangeRate: json["exchange_rate"] == null
          ? null
          : ExchangeRate.fromJson(json["exchange_rate"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "gross_amount": grossAmount?.toJson(),
    "paypal_fee": paypalFee?.toJson(),
    "net_amount": netAmount?.toJson(),
    "exchange_rate": exchangeRate?.toJson(),
  };
}

class ExchangeRate {
  ExchangeRate({this.json});

  final Map<String, dynamic>? json;

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(json: json);
  }

  Map<String, dynamic> toJson() => {};
}

class StatusDetails {
  StatusDetails({this.reason});

  final String? reason;

  StatusDetails copy({String? reason}) {
    return StatusDetails(reason: reason ?? this.reason);
  }

  factory StatusDetails.fromJson(Map<String, dynamic> json) {
    return StatusDetails(reason: json["reason"]);
  }

  Map<String, dynamic> toJson() => {"reason": reason};
}

/*
{
	"id": "7TK53561YB803214S",
	"amount": {
		"currency_code": "USD",
		"value": "100.00"
	},
	"final_capture": true,
	"seller_protection": {
		"status": "ELIGIBLE",
		"dispute_categories": [
			"ITEM_NOT_RECEIVED",
			"UNAUTHORIZED_TRANSACTION"
		]
	},
	"seller_receivable_breakdown": {
		"gross_amount": {
			"currency_code": "USD",
			"value": "100.00"
		},
		"paypal_fee": {
			"currency_code": "USD",
			"value": "3.98"
		},
		"net_amount": {
			"currency_code": "USD",
			"value": "96.02"
		},
		"exchange_rate": {}
	},
	"invoice_id": "OrderInvoice-10_10_2024_12_58_20_pm",
	"status": "PENDING",
	"status_details": {
		"reason": "OTHER"
	},
	"create_time": "2024-10-14T21:37:10Z",
	"update_time": "2024-10-14T21:37:10Z",
	"links": [
		{
			"href": "https://api.msmaster.qa.paypal.com/v2/payments/captures/7TK53561YB803214S",
			"rel": "self",
			"method": "GET"
		},
		{
			"href": "https://api.msmaster.qa.paypal.com/v2/payments/captures/7TK53561YB803214S/refund",
			"rel": "refund",
			"method": "POST"
		},
		{
			"href": "https://api.msmaster.qa.paypal.com/v2/payments/authorizations/6DR965477U7140544",
			"rel": "up",
			"method": "GET"
		}
	]
}*/
