import '../../../models/amount.dart';
import '../../../models/link.dart';
import '../../../models/seller_protection.dart';
import 'capture_order_payment_response.dart'
    hide
        CaptureOrderPaymentResponse,
        PurchaseUnit,
        Payments,
        Capture,
        SellerReceivableBreakdown,
        Shipping,
        Address,
        Paypal;

class AuthorizeOrderPaymentResponse {
  AuthorizeOrderPaymentResponse({
    this.id,
    this.status,
    this.paymentSource,
    this.purchaseUnits = const [],
    this.payer,
    this.links = const [],
  });

  final String? id;
  final String? status;
  final PaymentSource? paymentSource;
  final List<PurchaseUnit> purchaseUnits;
  final Payer? payer;
  final List<Link> links;

  AuthorizeOrderPaymentResponse copy({
    String? id,
    String? status,
    PaymentSource? paymentSource,
    List<PurchaseUnit>? purchaseUnits,
    Payer? payer,
    List<Link>? links,
  }) {
    return AuthorizeOrderPaymentResponse(
      id: id ?? this.id,
      status: status ?? this.status,
      paymentSource: paymentSource ?? this.paymentSource,
      purchaseUnits: purchaseUnits ?? this.purchaseUnits,
      payer: payer ?? this.payer,
      links: links ?? this.links,
    );
  }

  factory AuthorizeOrderPaymentResponse.fromJson(Map<String, dynamic> json) {
    return AuthorizeOrderPaymentResponse(
      id: json["id"],
      status: json["status"],
      paymentSource: json["payment_source"] == null
          ? null
          : PaymentSource.fromJson(json["payment_source"]),
      purchaseUnits: json["purchase_units"] is! List
          ? []
          : List<PurchaseUnit>.from(
              json["purchase_units"]!.map((x) => PurchaseUnit.fromJson(x)),
            ),
      payer: json["payer"] == null ? null : Payer.fromJson(json["payer"]),
      links: json["links"] is! List
          ? []
          : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "payment_source": paymentSource?.toJson(),
    "purchase_units": purchaseUnits.map((x) => x.toJson()).toList(),
    "payer": payer?.toJson(),
    "links": links.map((x) => x.toJson()).toList(),
  };
}

class PurchaseUnit {
  PurchaseUnit({this.referenceId, this.payments});

  final String? referenceId;
  final Payments? payments;

  PurchaseUnit copy({String? referenceId, Payments? payments}) {
    return PurchaseUnit(
      referenceId: referenceId ?? this.referenceId,
      payments: payments ?? this.payments,
    );
  }

  factory PurchaseUnit.fromJson(Map<String, dynamic> json) {
    return PurchaseUnit(
      referenceId: json["reference_id"],
      payments: json["payments"] == null
          ? null
          : Payments.fromJson(json["payments"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "reference_id": referenceId,
    "payments": payments?.toJson(),
  };
}

class Payments {
  Payments({this.authorizations = const []});

  final List<Authorization> authorizations;

  Payments copy({List<Authorization>? authorizations}) {
    return Payments(authorizations: authorizations ?? this.authorizations);
  }

  factory Payments.fromJson(Map<String, dynamic> json) {
    return Payments(
      authorizations: json["authorizations"] is! List
          ? []
          : List<Authorization>.from(
              json["authorizations"]!.map((x) => Authorization.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "authorizations": authorizations.map((x) => x.toJson()).toList(),
  };
}

class Authorization {
  Authorization({
    this.id,
    this.status,
    this.amount,
    this.sellerProtection,
    this.expirationTime,
    this.links = const [],
  });

  final String? id;
  final String? status;
  final Amount? amount;
  final SellerProtection? sellerProtection;
  final DateTime? expirationTime;
  final List<Link> links;

  Authorization copy({
    String? id,
    String? status,
    Amount? amount,
    SellerProtection? sellerProtection,
    DateTime? expirationTime,
    List<Link>? links,
  }) {
    return Authorization(
      id: id ?? this.id,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      sellerProtection: sellerProtection ?? this.sellerProtection,
      expirationTime: expirationTime ?? this.expirationTime,
      links: links ?? this.links,
    );
  }

  factory Authorization.fromJson(Map<String, dynamic> json) {
    return Authorization(
      id: json["id"],
      status: json["status"],
      amount: json["amount"] == null ? null : Amount.fromJson(json["amount"]),
      sellerProtection: json["seller_protection"] == null
          ? null
          : SellerProtection.fromJson(json["seller_protection"]),
      expirationTime: DateTime.tryParse(json["expiration_time"] ?? ""),
      links: json["links"] is! List
          ? []
          : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "amount": amount?.toJson(),
    "seller_protection": sellerProtection?.toJson(),
    "expiration_time": expirationTime?.toIso8601String(),
    "links": links.map((x) => x.toJson()).toList(),
  };
}

/*
{
	"id": "5O190127TN364715T",
	"status": "COMPLETED",
	"payment_source": {
		"paypal": {
			"name": {
				"given_name": "John",
				"surname": "Doe"
			},
			"email_address": "customer@example.com",
			"account_id": "QYR5Z8XDVJNXQ"
		}
	},
	"purchase_units": [
		{
			"reference_id": "d9f80740-38f0-11e8-b467-0ed5f89f718b",
			"payments": {
				"authorizations": [
					{
						"id": "3C679366HH908993F",
						"status": "CREATED",
						"amount": {
							"currency_code": "USD",
							"value": "100.00"
						},
						"seller_protection": {
							"status": "ELIGIBLE",
							"dispute_categories": [
								"ITEM_NOT_RECEIVED",
								"UNAUTHORIZED_TRANSACTION"
							]
						},
						"expiration_time": "2021-10-08T23:37:39Z",
						"links": [
							{
								"href": "https://api-m.paypal.com/v2/payments/authorizations/5O190127TN364715T",
								"rel": "self",
								"method": "GET"
							},
							{
								"href": "https://api-m.paypal.com/v2/payments/authorizations/5O190127TN364715T/capture",
								"rel": "capture",
								"method": "POST"
							},
							{
								"href": "https://api-m.paypal.com/v2/payments/authorizations/5O190127TN364715T/void",
								"rel": "void",
								"method": "POST"
							},
							{
								"href": "https://api-m.paypal.com/v2/checkout/orders/5O190127TN364715T",
								"rel": "up",
								"method": "GET"
							}
						]
					}
				]
			}
		}
	],
	"payer": {
		"name": {
			"given_name": "John",
			"surname": "Doe"
		},
		"email_address": "customer@example.com",
		"payer_id": "QYR5Z8XDVJNXQ"
	},
	"links": [
		{
			"href": "https://api-m.paypal.com/v2/checkout/orders/5O190127TN364715T",
			"rel": "self",
			"method": "GET"
		}
	]
}*/
