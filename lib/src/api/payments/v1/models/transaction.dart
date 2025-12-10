import '../../../../utils/extension_functions.dart';
import 'payment_options.dart';
import 'item.dart';

class Transaction {
  Transaction({
    this.amount,
    this.description,
    this.custom,
    this.invoiceNumber,
    this.paymentOptions,
    this.softDescriptor,
    this.itemList,
    this.relatedResources,
  });

  final TransactionAmount? amount;
  final String? description;
  final String? custom;
  final String? invoiceNumber;
  final PaymentOptions? paymentOptions;
  final String? softDescriptor;
  final ItemList? itemList;
  final List<RelatedResource>? relatedResources;

  Transaction copy({
    TransactionAmount? amount,
    String? description,
    String? custom,
    String? invoiceNumber,
    PaymentOptions? paymentOptions,
    String? softDescriptor,
    ItemList? itemList,
    List<RelatedResource>? relatedResources,
  }) {
    return Transaction(
      amount: amount ?? this.amount,
      description: description ?? this.description,
      custom: custom ?? this.custom,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      paymentOptions: paymentOptions ?? this.paymentOptions,
      softDescriptor: softDescriptor ?? this.softDescriptor,
      itemList: itemList ?? this.itemList,
      relatedResources: relatedResources ?? this.relatedResources,
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: json["amount"] == null
          ? null
          : TransactionAmount.fromJson(json["amount"]),
      description: json["description"],
      custom: json["custom"],
      invoiceNumber: json["invoice_number"],
      paymentOptions: json["payment_options"] == null
          ? null
          : PaymentOptions.fromJson(json["payment_options"]),
      softDescriptor: json["soft_descriptor"],
      itemList: json["item_list"] == null
          ? null
          : ItemList.fromJson(json["item_list"]),
      relatedResources: json["related_resources"] is List
          ? (json["related_resources"] as List)
                .map((e) => RelatedResource.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "amount": amount?.toJson(),
    "description": description,
    "custom": custom,
    "invoice_number": invoiceNumber,
    "payment_options": paymentOptions?.toJson(),
    "soft_descriptor": softDescriptor,
    "item_list": itemList?.toJson(),
    "related_resources": relatedResources?.map((e) => e.toJson()).toList(),
  }.filterNotNull();
}

class TransactionAmount {
  TransactionAmount({this.total, this.currency, this.details});

  final String? total;
  final String? currency;
  final Details? details;

  TransactionAmount copy({String? total, String? currency, Details? details}) {
    return TransactionAmount(
      total: total ?? this.total,
      currency: currency ?? this.currency,
      details: details ?? this.details,
    );
  }

  factory TransactionAmount.fromJson(Map<String, dynamic> json) {
    return TransactionAmount(
      total: json["total"]?.toString(),
      currency: json["currency"],
      details: json["details"] == null
          ? null
          : Details.fromJson(json["details"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "total": total,
    "currency": currency,
    "details": details?.toJson(),
  }.filterNotNull();
}

class Details {
  Details({
    this.subtotal,
    this.tax,
    this.shipping,
    this.handlingFee,
    this.insurance,
    this.shippingDiscount,
  });

  final String? subtotal;
  final String? tax;
  final String? shipping;
  final String? handlingFee;
  final String? insurance;
  final String? shippingDiscount;

  Details copy({
    String? subtotal,
    String? tax,
    String? shipping,
    String? handlingFee,
    String? insurance,
    String? shippingDiscount,
  }) {
    return Details(
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      handlingFee: handlingFee ?? this.handlingFee,
      insurance: insurance ?? this.insurance,
      shippingDiscount: shippingDiscount ?? this.shippingDiscount,
    );
  }

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      subtotal: json["subtotal"]?.toString(),
      tax: json["tax"]?.toString(),
      shipping: json["shipping"]?.toString(),
      handlingFee: json["handling_fee"]?.toString(),
      insurance: json["insurance"]?.toString(),
      shippingDiscount: json["shipping_discount"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "subtotal": subtotal,
    "tax": tax,
    "shipping": shipping,
    "handling_fee": handlingFee,
    "insurance": insurance,
    "shipping_discount": shippingDiscount,
  }.filterNotNull();
}

class RelatedResource {
  RelatedResource({this.order, this.sale, this.authorization});

  final Map<String, dynamic>? order;
  final Map<String, dynamic>? sale;
  final Map<String, dynamic>? authorization;

  RelatedResource copy({
    Map<String, dynamic>? order,
    Map<String, dynamic>? sale,
    Map<String, dynamic>? authorization,
  }) {
    return RelatedResource(
      order: order ?? this.order,
      sale: sale ?? this.sale,
      authorization: authorization ?? this.authorization,
    );
  }

  factory RelatedResource.fromJson(Map<String, dynamic> json) {
    return RelatedResource(
      order: json["order"] == null
          ? null
          : Map<String, dynamic>.from(json["order"]),
      sale: json["sale"] == null
          ? null
          : Map<String, dynamic>.from(json["sale"]),
      authorization: json["authorization"] == null
          ? null
          : Map<String, dynamic>.from(json["authorization"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "order": order,
    "sale": sale,
    "authorization": authorization,
  }.filterNotNull();
}
