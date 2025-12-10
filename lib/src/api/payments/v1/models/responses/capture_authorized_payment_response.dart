import '../../../../../utils/extension_functions.dart';
import '../../../../models/amount.dart';
import '../../../../models/link.dart';
import '../transaction.dart';

class CaptureAuthorizedPaymentResponseV1 {
  CaptureAuthorizedPaymentResponseV1({
    this.id,
    this.amount,
    this.state,
    this.reasonCode,
    this.custom,
    this.transactionFee,
    this.transactionFeeInReceivableCurrency,
    this.receivableAmount,
    this.exchangeRate,
    this.isFinalCapture,
    this.parentPayment,
    this.invoiceNumber,
    this.createTime,
    this.updateTime,
    this.links = const [],
  });

  final String? id;
  final TransactionAmount? amount;
  final String? state;
  final String? reasonCode;
  final String? custom;
  final Amount? transactionFee;
  final Amount? transactionFeeInReceivableCurrency;
  final Amount? receivableAmount;
  final String? exchangeRate;
  final bool? isFinalCapture;
  final String? parentPayment;
  final String? invoiceNumber;
  final DateTime? createTime;
  final DateTime? updateTime;
  final List<Link> links;

  CaptureAuthorizedPaymentResponseV1 copy({
    String? id,
    TransactionAmount? amount,
    String? state,
    String? reasonCode,
    String? custom,
    Amount? transactionFee,
    Amount? transactionFeeInReceivableCurrency,
    Amount? receivableAmount,
    String? exchangeRate,
    bool? isFinalCapture,
    String? parentPayment,
    String? invoiceNumber,
    DateTime? createTime,
    DateTime? updateTime,
    List<Link>? links,
  }) {
    return CaptureAuthorizedPaymentResponseV1(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      state: state ?? this.state,
      reasonCode: reasonCode ?? this.reasonCode,
      custom: custom ?? this.custom,
      transactionFee: transactionFee ?? this.transactionFee,
      transactionFeeInReceivableCurrency:
          transactionFeeInReceivableCurrency ??
          this.transactionFeeInReceivableCurrency,
      receivableAmount: receivableAmount ?? this.receivableAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      isFinalCapture: isFinalCapture ?? this.isFinalCapture,
      parentPayment: parentPayment ?? this.parentPayment,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      links: links ?? this.links,
    );
  }

  factory CaptureAuthorizedPaymentResponseV1.fromJson(
    Map<String, dynamic> json,
  ) {
    return CaptureAuthorizedPaymentResponseV1(
      id: json["id"],
      amount: json["amount"] == null
          ? null
          : TransactionAmount.fromJson(json["amount"]),
      state: json["state"],
      reasonCode: json["reason_code"],
      custom: json["custom"],
      transactionFee: json["transaction_fee"] == null
          ? null
          : Amount.fromJson(json["transaction_fee"]),
      transactionFeeInReceivableCurrency:
          json["transaction_fee_in_receivable_currency"] == null
          ? null
          : Amount.fromJson(json["transaction_fee_in_receivable_currency"]),
      receivableAmount: json["receivable_amount"] == null
          ? null
          : Amount.fromJson(json["receivable_amount"]),
      exchangeRate: json["exchange_rate"],
      isFinalCapture: json["is_final_capture"],
      parentPayment: json["parent_payment"],
      invoiceNumber: json["invoice_number"],
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
    "state": state,
    "reason_code": reasonCode,
    "custom": custom,
    "transaction_fee": transactionFee?.toJson(),
    "transaction_fee_in_receivable_currency": transactionFeeInReceivableCurrency
        ?.toJson(),
    "receivable_amount": receivableAmount?.toJson(),
    "exchange_rate": exchangeRate,
    "is_final_capture": isFinalCapture,
    "parent_payment": parentPayment,
    "invoice_number": invoiceNumber,
    "create_time": createTime?.toIso8601String(),
    "update_time": updateTime?.toIso8601String(),
    "links": links.map((x) => x.toJson()).toList(),
  }.filterNotNull();
}

/*
{
	"id": "05L60402VH257294E",
	"amount": {
		"total": "1.10",
		"currency": "USD"
	},
	"state": "completed",
	"reason_code": "NONE",
	"custom": "Nouphal Custom",
	"transaction_fee": {
		"value": "0.35",
		"currency": "USD"
	},
	"transaction_fee_in_receivable_currency": {
		"value": "0.35",
		"currency": "CNY"
	},
	"receivable_amount": {
		"value": "0.07",
		"currency": "CNY"
	},
	"exchange_rate": "0.009370279361376",
	"is_final_capture": false,
	"parent_payment": "PAYID-L2ZOT5Y1K876380CL583530L",
	"invoice_number": "",
	"create_time": "2020-05-06T16:49:32Z",
	"update_time": "2020-05-06T16:49:32Z",
	"links": [
		{
			"href": "https://www.${stage_domain}:12326/v1/payments/capture/05L60402VH257294E",
			"rel": "self",
			"method": "GET"
		},
		{
			"href": "https://www.${stage_domain}:12326/v1/payments/capture/05L60402VH257294E/refund",
			"rel": "refund",
			"method": "POST"
		},
		{
			"href": "https://www.${stage_domain}:12326/v1/payments/authorization/6JD14952FS4103539",
			"rel": "authorization",
			"method": "GET"
		},
		{
			"href": "https://www.${stage_domain}:12326/v1/payments/payment/PAYID-L2ZOT5Y1K876380CL583530L",
			"rel": "parent_payment",
			"method": "GET"
		}
	]
}*/
