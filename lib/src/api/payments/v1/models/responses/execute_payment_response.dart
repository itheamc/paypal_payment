import '../../../../../utils/extension_functions.dart';
import '../../../../models/link.dart';
import '../payer.dart';
import '../transaction.dart';

class PaymentExecuteResponse {
  PaymentExecuteResponse({
    this.id,
    this.createTime,
    this.updateTime,
    this.state,
    this.intent,
    this.payer,
    this.transactions = const [],
    this.links = const [],
  });

  final String? id;
  final DateTime? createTime;
  final DateTime? updateTime;
  final String? state;
  final String? intent;
  final Payer? payer;
  final List<Transaction> transactions;
  final List<Link> links;

  PaymentExecuteResponse copy({
    String? id,
    DateTime? createTime,
    DateTime? updateTime,
    String? state,
    String? intent,
    Payer? payer,
    List<Transaction>? transactions,
    List<Link>? links,
  }) {
    return PaymentExecuteResponse(
      id: id ?? this.id,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      state: state ?? this.state,
      intent: intent ?? this.intent,
      payer: payer ?? this.payer,
      transactions: transactions ?? this.transactions,
      links: links ?? this.links,
    );
  }

  factory PaymentExecuteResponse.fromJson(Map<String, dynamic> json) {
    return PaymentExecuteResponse(
      id: json["id"],
      createTime: DateTime.tryParse(json["create_time"] ?? ""),
      updateTime: DateTime.tryParse(json["update_time"] ?? ""),
      state: json["state"],
      intent: json["intent"],
      payer: json["payer"] == null ? null : Payer.fromJson(json["payer"]),
      transactions: json["transactions"] is! List
          ? []
          : List<Transaction>.from(
              json["transactions"]!.map((x) => Transaction.fromJson(x)),
            ),
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
    "intent": intent,
    "payer": payer?.toJson(),
    "transactions": transactions.map((x) => x.toJson()).toList(),
    "links": links.map((x) => x.toJson()).toList(),
  }.filterNotNull();
}

/*
{
	"id": "PAY-9N9834337A9191208KOZOQWI",
	"create_time": "2017-07-01T16:56:57Z",
	"update_time": "2017-07-01T17:05:41Z",
	"state": "APPROVED",
	"intent": "order",
	"payer": {
		"payment_method": "paypal",
		"payer_info": {
			"email": "qa152-biz@example.com",
			"first_name": "Thomas",
			"last_name": "Miller",
			"payer_id": "PUP87RBJV8HPU",
			"shipping_address": {
				"line1": "4th Floor, One Lagoon Drive",
				"line2": "Unit #34",
				"city": "Redwood City",
				"state": "CA",
				"postal_code": "94065",
				"country_code": "US",
				"phone": "011862212345678",
				"recipient_name": "Thomas Miller"
			}
		}
	},
	"transactions": [
		{
			"amount": {
				"total": "41.15",
				"currency": "USD",
				"details": {
					"subtotal": "30.00",
					"tax": "0.15",
					"shipping": "11.00"
				}
			},
			"description": "The payment transaction description.",
			"item_list": {
				"items": [
					{
						"name": "hat",
						"sku": "1",
						"price": "3.00",
						"currency": "USD",
						"quantity": "5"
					},
					{
						"name": "handbag",
						"sku": "product34",
						"price": "15.00",
						"currency": "USD",
						"quantity": "1"
					}
				],
				"shipping_options": [
					{
						"id": "PICKUP0000001",
						"label": "Free Shipping",
						"type": "PICKUP",
						"amount": {
							"currency_code": "USD",
							"value": "5.00"
						},
						"selected": true
					}
				],
				"shipping_address": {
					"recipient_name": "Thomas Miller",
					"line1": "4th Floor, One Lagoon Drive",
					"line2": "Unit #34",
					"city": "Redwood City",
					"state": "CA",
					"phone": "011862212345678",
					"postal_code": "94065",
					"country_code": "US"
				}
			},
			"related_resources": [
				{
					"order": {
						"id": "O-3SP845109F051535C",
						"create_time": "2017-07-01T16:56:58Z",
						"update_time": "2017-07-01T17:05:41Z",
						"state": "PENDING",
						"amount": {
							"total": "41.15",
							"currency": "USD"
						},
						"parent_payment": "PAY-9N9834337A9191208KOZOQWI",
						"links": [
							{
								"href": "https://api-m.sandbox.paypal.com/v1/payments/orders/O-3SP845109F051535C",
								"rel": "self",
								"method": "GET"
							},
							{
								"href": "https://api-m.sandbox.paypal.com/v1/payments/payment/PAY-9N9834337A9191208KOZOQWI",
								"rel": "parent_payment",
								"method": "GET"
							},
							{
								"href": "https://api-m.sandbox.paypal.com/v1/payments/orders/O-3SP845109F051535C/void",
								"rel": "void",
								"method": "POST"
							},
							{
								"href": "https://api-m.sandbox.paypal.com/v1/payments/orders/O-3SP845109F051535C/authorize",
								"rel": "authorization",
								"method": "POST"
							},
							{
								"href": "https://api-m.sandbox.paypal.com/v1/payments/orders/O-3SP845109F051535C/capture",
								"rel": "capture",
								"method": "POST"
							}
						]
					}
				}
			]
		}
	],
	"links": [
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/payment/PAY-9N9834337A9191208KOZOQWI",
			"rel": "self",
			"method": "GET"
		}
	]
}*/
