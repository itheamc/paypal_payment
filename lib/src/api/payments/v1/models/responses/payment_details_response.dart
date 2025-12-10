import '../../../models/payment_intent.dart';
import '../../../../../utils/extension_functions.dart';
import '../../../../models/link.dart';
import '../payer.dart';
import '../transaction.dart';

class PaymentDetailsResponse {
  PaymentDetailsResponse({
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
  final PaymentIntent? intent;
  final Payer? payer;
  final List<Transaction> transactions;
  final List<Link> links;

  /// Getter for Approval and Execute Url
  ///
  Link? get approvalLink =>
      links.where((element) => element.rel == 'approval_url').firstOrNull;

  Link? get executeLink =>
      links.where((element) => element.rel == 'execute').firstOrNull;

  PaymentDetailsResponse copy({
    String? id,
    DateTime? createTime,
    DateTime? updateTime,
    String? state,
    PaymentIntent? intent,
    Payer? payer,
    List<Transaction>? transactions,
    List<Link>? links,
  }) {
    return PaymentDetailsResponse(
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

  factory PaymentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsResponse(
      id: json["id"],
      createTime: DateTime.tryParse(json["create_time"] ?? ""),
      updateTime: DateTime.tryParse(json["update_time"] ?? ""),
      state: json["state"],
      intent: PaymentIntent.fromStr(json["intent"]),
      payer: json["payer"] == null ? null : Payer.fromJson(json["payer"]),
      transactions:
          json["transactions"] == null || json["transactions"] is! List
          ? []
          : List<Transaction>.from(
              json["transactions"]!.map((x) => Transaction.fromJson(x)),
            ),
      links: json["links"] == null || json["links"] is! List
          ? []
          : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "create_time": createTime?.toIso8601String(),
    "update_time": updateTime?.toIso8601String(),
    "state": state,
    "intent": intent?.name,
    "payer": payer?.toJson(),
    "transactions": transactions.map((x) => x.toJson()).toList(),
    "links": links.map((x) => x.toJson()).toList(),
  }.filterNotNull();
}

/*
{
	"id": "PAY-1B56960729604235TKQQIYVY",
	"create_time": "2017-09-22T20:53:43Z",
	"update_time": "2017-09-22T20:53:44Z",
	"state": "CREATED",
	"intent": "sale",
	"payer": {
		"payment_method": "paypal"
	},
	"transactions": [
		{
			"amount": {
				"total": "30.11",
				"currency": "USD",
				"details": {
					"subtotal": "30.00",
					"tax": "0.07",
					"shipping": "0.03",
					"handling_fee": "1.00",
					"insurance": "0.01",
					"shipping_discount": "-1.00"
				}
			},
			"description": "The payment transaction description.",
			"custom": "EBAY_EMS_90048630024435",
			"invoice_number": "48787589673",
			"item_list": {
				"items": [
					{
						"name": "hat",
						"sku": "1",
						"price": "3.00",
						"currency": "USD",
						"quantity": "5",
						"description": "Brown hat.",
						"tax": "0.01"
					},
					{
						"name": "handbag",
						"sku": "product34",
						"price": "15.00",
						"currency": "USD",
						"quantity": "1",
						"description": "Black handbag.",
						"tax": "0.02"
					}
				],
				"shipping_address": {
					"recipient_name": "Brian Robinson",
					"line1": "4th Floor",
					"line2": "Unit #34",
					"city": "San Jose",
					"state": "CA",
					"phone": "011862212345678",
					"postal_code": "95131",
					"country_code": "US"
				}
			}
		}
	],
	"links": [
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/payment/PAY-1B56960729604235TKQQIYVY",
			"rel": "self",
			"method": "GET"
		},
		{
			"href": "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=EC-60385559L1062554J",
			"rel": "approval_url",
			"method": "REDIRECT"
		},
		{
			"href": "https://api-m.sandbox.paypal.com/v1/payments/payment/PAY-1B56960729604235TKQQIYVY/execute",
			"rel": "execute",
			"method": "POST"
		}
	]
}*/
