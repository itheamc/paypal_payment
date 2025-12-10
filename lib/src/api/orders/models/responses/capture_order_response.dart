import '../../../models/amount.dart';
import '../../../models/link.dart';
import '../../../models/seller_protection.dart';

class CaptureOrderResponse {
  CaptureOrderResponse({
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

  CaptureOrderResponse copy({
    String? id,
    String? status,
    PaymentSource? paymentSource,
    List<PurchaseUnit>? purchaseUnits,
    Payer? payer,
    List<Link>? links,
  }) {
    return CaptureOrderResponse(
      id: id ?? this.id,
      status: status ?? this.status,
      paymentSource: paymentSource ?? this.paymentSource,
      purchaseUnits: purchaseUnits ?? this.purchaseUnits,
      payer: payer ?? this.payer,
      links: links ?? this.links,
    );
  }

  factory CaptureOrderResponse.fromJson(Map<String, dynamic> json) {
    return CaptureOrderResponse(
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

class Payer {
  Payer({this.givenName, this.surname, this.emailAddress, this.payerId});

  final String? givenName;
  final String? surname;
  final String? emailAddress;
  final String? payerId;

  Payer copy({
    String? givenName,
    String? surname,
    String? emailAddress,
    String? payerId,
  }) {
    return Payer(
      givenName: givenName ?? this.givenName,
      surname: surname ?? this.surname,
      emailAddress: emailAddress ?? this.emailAddress,
      payerId: payerId ?? this.payerId,
    );
  }

  factory Payer.fromJson(Map<String, dynamic> json) {
    return Payer(
      givenName: json["name"] == null ? null : json["name"]['given_name'],
      surname: json["name"] == null ? null : json["name"]['surname'],
      emailAddress: json["email_address"],
      payerId: json["payer_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "name": {"given_name": givenName, "surname": surname},
    "email_address": emailAddress,
    "payer_id": payerId,
  };
}

class PaymentSource {
  PaymentSource({this.paypal});

  final Paypal? paypal;

  PaymentSource copy({Paypal? paypal}) {
    return PaymentSource(paypal: paypal ?? this.paypal);
  }

  factory PaymentSource.fromJson(Map<String, dynamic> json) {
    return PaymentSource(
      paypal: json["paypal"] == null ? null : Paypal.fromJson(json["paypal"]),
    );
  }

  Map<String, dynamic> toJson() => {"paypal": paypal?.toJson()};
}

class Paypal {
  Paypal({this.givenName, this.surname, this.emailAddress, this.accountId});

  final String? givenName;
  final String? surname;
  final String? emailAddress;
  final String? accountId;

  Paypal copy({
    String? givenName,
    String? surname,
    String? emailAddress,
    String? accountId,
  }) {
    return Paypal(
      givenName: givenName ?? this.givenName,
      surname: surname ?? this.surname,
      emailAddress: emailAddress ?? this.emailAddress,
      accountId: accountId ?? this.accountId,
    );
  }

  factory Paypal.fromJson(Map<String, dynamic> json) {
    return Paypal(
      givenName: json["name"] == null ? null : json["name"]['given_name'],
      surname: json["name"] == null ? null : json["name"]['surname'],
      emailAddress: json["email_address"],
      accountId: json["account_id"],
    );
  }

  Map<String, dynamic> toJson() => {
    "name": {"given_name": givenName, "surname": surname},
    "email_address": emailAddress,
    "account_id": accountId,
  };
}

class PurchaseUnit {
  PurchaseUnit({this.referenceId, this.shipping, this.payments});

  final String? referenceId;
  final Shipping? shipping;
  final Payments? payments;

  PurchaseUnit copy({
    String? referenceId,
    Shipping? shipping,
    Payments? payments,
  }) {
    return PurchaseUnit(
      referenceId: referenceId ?? this.referenceId,
      shipping: shipping ?? this.shipping,
      payments: payments ?? this.payments,
    );
  }

  factory PurchaseUnit.fromJson(Map<String, dynamic> json) {
    return PurchaseUnit(
      referenceId: json["reference_id"],
      shipping: json["shipping"] == null
          ? null
          : Shipping.fromJson(json["shipping"]),
      payments: json["payments"] == null
          ? null
          : Payments.fromJson(json["payments"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "reference_id": referenceId,
    "shipping": shipping?.toJson(),
    "payments": payments?.toJson(),
  };
}

class Payments {
  Payments({this.captures = const []});

  final List<Capture> captures;

  Payments copy({List<Capture>? captures}) {
    return Payments(captures: captures ?? this.captures);
  }

  factory Payments.fromJson(Map<String, dynamic> json) {
    return Payments(
      captures: json["captures"] is! List
          ? []
          : List<Capture>.from(
              json["captures"]!.map((x) => Capture.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "captures": captures.map((x) => x.toJson()).toList(),
  };
}

class Capture {
  Capture({
    this.id,
    this.status,
    this.amount,
    this.sellerProtection,
    this.finalCapture,
    this.disbursementMode,
    this.sellerReceivableBreakdown,
    this.createTime,
    this.updateTime,
    this.links = const [],
  });

  final String? id;
  final String? status;
  final Amount? amount;
  final SellerProtection? sellerProtection;
  final bool? finalCapture;
  final String? disbursementMode;
  final SellerReceivableBreakdown? sellerReceivableBreakdown;
  final DateTime? createTime;
  final DateTime? updateTime;
  final List<Link> links;

  Capture copy({
    String? id,
    String? status,
    Amount? amount,
    SellerProtection? sellerProtection,
    bool? finalCapture,
    String? disbursementMode,
    SellerReceivableBreakdown? sellerReceivableBreakdown,
    DateTime? createTime,
    DateTime? updateTime,
    List<Link>? links,
  }) {
    return Capture(
      id: id ?? this.id,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      sellerProtection: sellerProtection ?? this.sellerProtection,
      finalCapture: finalCapture ?? this.finalCapture,
      disbursementMode: disbursementMode ?? this.disbursementMode,
      sellerReceivableBreakdown:
          sellerReceivableBreakdown ?? this.sellerReceivableBreakdown,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      links: links ?? this.links,
    );
  }

  factory Capture.fromJson(Map<String, dynamic> json) {
    return Capture(
      id: json["id"],
      status: json["status"],
      amount: json["amount"] == null ? null : Amount.fromJson(json["amount"]),
      sellerProtection: json["seller_protection"] == null
          ? null
          : SellerProtection.fromJson(json["seller_protection"]),
      finalCapture: json["final_capture"],
      disbursementMode: json["disbursement_mode"],
      sellerReceivableBreakdown: json["seller_receivable_breakdown"] == null
          ? null
          : SellerReceivableBreakdown.fromJson(
              json["seller_receivable_breakdown"],
            ),
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
    "seller_protection": sellerProtection?.toJson(),
    "final_capture": finalCapture,
    "disbursement_mode": disbursementMode,
    "seller_receivable_breakdown": sellerReceivableBreakdown?.toJson(),
    "create_time": createTime?.toIso8601String(),
    "update_time": updateTime?.toIso8601String(),
    "links": links.map((x) => x.toJson()).toList(),
  };
}

class SellerReceivableBreakdown {
  SellerReceivableBreakdown({this.grossAmount, this.paypalFee, this.netAmount});

  final Amount? grossAmount;
  final Amount? paypalFee;
  final Amount? netAmount;

  SellerReceivableBreakdown copy({
    Amount? grossAmount,
    Amount? paypalFee,
    Amount? netAmount,
  }) {
    return SellerReceivableBreakdown(
      grossAmount: grossAmount ?? this.grossAmount,
      paypalFee: paypalFee ?? this.paypalFee,
      netAmount: netAmount ?? this.netAmount,
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
    );
  }

  Map<String, dynamic> toJson() => {
    "gross_amount": grossAmount?.toJson(),
    "paypal_fee": paypalFee?.toJson(),
    "net_amount": netAmount?.toJson(),
  };
}

class Shipping {
  Shipping({this.address});

  final Address? address;

  Shipping copy({Address? address}) {
    return Shipping(address: address ?? this.address);
  }

  factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      address: json["address"] == null
          ? null
          : Address.fromJson(json["address"]),
    );
  }

  Map<String, dynamic> toJson() => {"address": address?.toJson()};
}

class Address {
  Address({
    this.addressLine1,
    this.addressLine2,
    this.adminArea2,
    this.adminArea1,
    this.postalCode,
    this.countryCode,
  });

  final String? addressLine1;
  final String? addressLine2;
  final String? adminArea2;
  final String? adminArea1;
  final String? postalCode;
  final String? countryCode;

  Address copy({
    String? addressLine1,
    String? addressLine2,
    String? adminArea2,
    String? adminArea1,
    String? postalCode,
    String? countryCode,
  }) {
    return Address(
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      adminArea2: adminArea2 ?? this.adminArea2,
      adminArea1: adminArea1 ?? this.adminArea1,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine1: json["address_line_1"],
      addressLine2: json["address_line_2"],
      adminArea2: json["admin_area_2"],
      adminArea1: json["admin_area_1"],
      postalCode: json["postal_code"],
      countryCode: json["country_code"],
    );
  }

  Map<String, dynamic> toJson() => {
    "address_line_1": addressLine1,
    "address_line_2": addressLine2,
    "admin_area_2": adminArea2,
    "admin_area_1": adminArea1,
    "postal_code": postalCode,
    "country_code": countryCode,
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
			"shipping": {
				"address": {
					"address_line_1": "2211 N First Street",
					"address_line_2": "Building 17",
					"admin_area_2": "San Jose",
					"admin_area_1": "CA",
					"postal_code": "95131",
					"country_code": "US"
				}
			},
			"payments": {
				"captures": [
					{
						"id": "3C679366HH908993F",
						"status": "COMPLETED",
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
						"final_capture": true,
						"disbursement_mode": "INSTANT",
						"seller_receivable_breakdown": {
							"gross_amount": {
								"currency_code": "USD",
								"value": "100.00"
							},
							"paypal_fee": {
								"currency_code": "USD",
								"value": "3.00"
							},
							"net_amount": {
								"currency_code": "USD",
								"value": "97.00"
							}
						},
						"create_time": "2018-04-01T21:20:49Z",
						"update_time": "2018-04-01T21:20:49Z",
						"links": [
							{
								"href": "https://api-m.paypal.com/v2/payments/captures/3C679366HH908993F",
								"rel": "self",
								"method": "GET"
							},
							{
								"href": "https://api-m.paypal.com/v2/payments/captures/3C679366HH908993F/refund",
								"rel": "refund",
								"method": "POST"
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
