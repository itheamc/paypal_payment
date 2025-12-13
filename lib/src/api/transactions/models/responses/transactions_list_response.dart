import '../../../models/amount.dart';
import '../../../models/link.dart';

/// Represents the response body for a request that retrieves a list of transactions.
/// It includes the transaction details, pagination information, and account details.
///
class TransactionsListResponse {
  TransactionsListResponse({
    this.transactionDetails = const [],
    this.accountNumber,
    this.lastRefreshedDatetime,
    this.page,
    this.totalItems,
    this.totalPages,
    this.links = const [],
  });

  final List<TransactionDetail> transactionDetails;
  final String? accountNumber;
  final String? lastRefreshedDatetime;
  final num? page;
  final num? totalItems;
  final num? totalPages;
  final List<Link> links;

  TransactionsListResponse copy({
    List<TransactionDetail>? transactionDetails,
    String? accountNumber,
    String? lastRefreshedDatetime,
    num? page,
    num? totalItems,
    num? totalPages,
    List<Link>? links,
  }) {
    return TransactionsListResponse(
      transactionDetails: transactionDetails ?? this.transactionDetails,
      accountNumber: accountNumber ?? this.accountNumber,
      lastRefreshedDatetime:
          lastRefreshedDatetime ?? this.lastRefreshedDatetime,
      page: page ?? this.page,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      links: links ?? this.links,
    );
  }

  factory TransactionsListResponse.fromJson(Map<String, dynamic> json) {
    return TransactionsListResponse(
      transactionDetails: json["transaction_details"] is! List
          ? []
          : List<TransactionDetail>.from(
              json["transaction_details"]!.map(
                (x) => TransactionDetail.fromJson(x),
              ),
            ),
      accountNumber: json["account_number"],
      lastRefreshedDatetime: json["last_refreshed_datetime"],
      page: json["page"],
      totalItems: json["total_items"],
      totalPages: json["total_pages"],
      links: json["links"] is! List
          ? []
          : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "transaction_details": transactionDetails.map((x) => x.toJson()).toList(),
    "account_number": accountNumber,
    "last_refreshed_datetime": lastRefreshedDatetime,
    "page": page,
    "total_items": totalItems,
    "total_pages": totalPages,
    "links": links.map((x) => x.toJson()).toList(),
  };
}

class TransactionDetail {
  TransactionDetail({
    this.transactionInfo,
    this.payerInfo,
    this.shippingInfo,
    this.cartInfo,
    this.storeInfo,
    this.auctionInfo,
    this.incentiveInfo,
  });

  final TransactionInfo? transactionInfo;
  final PayerInfo? payerInfo;
  final ShippingInfo? shippingInfo;
  final CartInfo? cartInfo;
  final EInfo? storeInfo;
  final AuctionInfo? auctionInfo;
  final EInfo? incentiveInfo;

  TransactionDetail copy({
    TransactionInfo? transactionInfo,
    PayerInfo? payerInfo,
    ShippingInfo? shippingInfo,
    CartInfo? cartInfo,
    EInfo? storeInfo,
    AuctionInfo? auctionInfo,
    EInfo? incentiveInfo,
  }) {
    return TransactionDetail(
      transactionInfo: transactionInfo ?? this.transactionInfo,
      payerInfo: payerInfo ?? this.payerInfo,
      shippingInfo: shippingInfo ?? this.shippingInfo,
      cartInfo: cartInfo ?? this.cartInfo,
      storeInfo: storeInfo ?? this.storeInfo,
      auctionInfo: auctionInfo ?? this.auctionInfo,
      incentiveInfo: incentiveInfo ?? this.incentiveInfo,
    );
  }

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      transactionInfo: json["transaction_info"] == null
          ? null
          : TransactionInfo.fromJson(json["transaction_info"]),
      payerInfo: json["payer_info"] == null
          ? null
          : PayerInfo.fromJson(json["payer_info"]),
      shippingInfo: json["shipping_info"] == null
          ? null
          : ShippingInfo.fromJson(json["shipping_info"]),
      cartInfo: json["cart_info"] == null
          ? null
          : CartInfo.fromJson(json["cart_info"]),
      storeInfo: json["store_info"] == null
          ? null
          : EInfo.fromJson(json["store_info"]),
      auctionInfo: json["auction_info"] == null
          ? null
          : AuctionInfo.fromJson(json["auction_info"]),
      incentiveInfo: json["incentive_info"] == null
          ? null
          : EInfo.fromJson(json["incentive_info"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "transaction_info": transactionInfo?.toJson(),
    "payer_info": payerInfo?.toJson(),
    "shipping_info": shippingInfo?.toJson(),
    "cart_info": cartInfo?.toJson(),
    "store_info": storeInfo?.toJson(),
    "auction_info": auctionInfo?.toJson(),
    "incentive_info": incentiveInfo?.toJson(),
  };
}

class AuctionInfo {
  AuctionInfo({
    this.auctionSite,
    this.auctionItemSite,
    this.auctionBuyerId,
    this.auctionClosingDate,
  });

  final String? auctionSite;
  final String? auctionItemSite;
  final String? auctionBuyerId;
  final String? auctionClosingDate;

  AuctionInfo copy({
    String? auctionSite,
    String? auctionItemSite,
    String? auctionBuyerId,
    String? auctionClosingDate,
  }) {
    return AuctionInfo(
      auctionSite: auctionSite ?? this.auctionSite,
      auctionItemSite: auctionItemSite ?? this.auctionItemSite,
      auctionBuyerId: auctionBuyerId ?? this.auctionBuyerId,
      auctionClosingDate: auctionClosingDate ?? this.auctionClosingDate,
    );
  }

  factory AuctionInfo.fromJson(Map<String, dynamic> json) {
    return AuctionInfo(
      auctionSite: json["auction_site"],
      auctionItemSite: json["auction_item_site"],
      auctionBuyerId: json["auction_buyer_id"],
      auctionClosingDate: json["auction_closing_date"],
    );
  }

  Map<String, dynamic> toJson() => {
    "auction_site": auctionSite,
    "auction_item_site": auctionItemSite,
    "auction_buyer_id": auctionBuyerId,
    "auction_closing_date": auctionClosingDate,
  };
}

class CartInfo {
  CartInfo({this.itemDetails = const []});

  final List<ItemDetail> itemDetails;

  CartInfo copy({List<ItemDetail>? itemDetails}) {
    return CartInfo(itemDetails: itemDetails ?? this.itemDetails);
  }

  factory CartInfo.fromJson(Map<String, dynamic> json) {
    return CartInfo(
      itemDetails: json["item_details"] is! List
          ? []
          : List<ItemDetail>.from(
              json["item_details"]!.map((x) => ItemDetail.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "item_details": itemDetails.map((x) => x.toJson()).toList(),
  };
}

class ItemDetail {
  ItemDetail({
    this.itemCode,
    this.itemName,
    this.itemQuantity,
    this.itemUnitPrice,
    this.itemAmount,
    this.taxAmounts = const [],
    this.basicShippingAmount,
    this.totalItemAmount,
  });

  final String? itemCode;
  final String? itemName;
  final String? itemQuantity;
  final Amount? itemUnitPrice;
  final Amount? itemAmount;
  final List<TaxAmount> taxAmounts;
  final Amount? basicShippingAmount;
  final Amount? totalItemAmount;

  ItemDetail copy({
    String? itemCode,
    String? itemName,
    String? itemQuantity,
    Amount? itemUnitPrice,
    Amount? itemAmount,
    List<TaxAmount>? taxAmounts,
    Amount? basicShippingAmount,
    Amount? totalItemAmount,
  }) {
    return ItemDetail(
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      itemQuantity: itemQuantity ?? this.itemQuantity,
      itemUnitPrice: itemUnitPrice ?? this.itemUnitPrice,
      itemAmount: itemAmount ?? this.itemAmount,
      taxAmounts: taxAmounts ?? this.taxAmounts,
      basicShippingAmount: basicShippingAmount ?? this.basicShippingAmount,
      totalItemAmount: totalItemAmount ?? this.totalItemAmount,
    );
  }

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    return ItemDetail(
      itemCode: json["item_code"],
      itemName: json["item_name"],
      itemQuantity: json["item_quantity"],
      itemUnitPrice: json["item_unit_price"] == null
          ? null
          : Amount.fromJson(json["item_unit_price"]),
      itemAmount: json["item_amount"] == null
          ? null
          : Amount.fromJson(json["item_amount"]),
      taxAmounts: json["tax_amounts"] is! List
          ? []
          : List<TaxAmount>.from(
              json["tax_amounts"]!.map((x) => TaxAmount.fromJson(x)),
            ),
      basicShippingAmount: json["basic_shipping_amount"] == null
          ? null
          : Amount.fromJson(json["basic_shipping_amount"]),
      totalItemAmount: json["total_item_amount"] == null
          ? null
          : Amount.fromJson(json["total_item_amount"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "item_code": itemCode,
    "item_name": itemName,
    "item_quantity": itemQuantity,
    "item_unit_price": itemUnitPrice?.toJson(),
    "item_amount": itemAmount?.toJson(),
    "tax_amounts": taxAmounts.map((x) => x.toJson()).toList(),
    "basic_shipping_amount": basicShippingAmount?.toJson(),
    "total_item_amount": totalItemAmount?.toJson(),
  };
}

class TaxAmount {
  TaxAmount({this.taxAmount});

  final Amount? taxAmount;

  TaxAmount copy({Amount? taxAmount}) {
    return TaxAmount(taxAmount: taxAmount ?? this.taxAmount);
  }

  factory TaxAmount.fromJson(Map<String, dynamic> json) {
    return TaxAmount(
      taxAmount: json["tax_amount"] == null
          ? null
          : Amount.fromJson(json["tax_amount"]),
    );
  }

  Map<String, dynamic> toJson() => {"tax_amount": taxAmount?.toJson()};
}

class EInfo {
  EInfo({required this.json});

  final Map<String, dynamic> json;

  factory EInfo.fromJson(Map<String, dynamic> json) {
    return EInfo(json: json);
  }

  Map<String, dynamic> toJson() => {};
}

class PayerInfo {
  PayerInfo({
    this.accountId,
    this.emailAddress,
    this.addressStatus,
    this.payerStatus,
    this.payerName,
    this.countryCode,
  });

  final String? accountId;
  final String? emailAddress;
  final String? addressStatus;
  final String? payerStatus;
  final PayerName? payerName;
  final String? countryCode;

  PayerInfo copy({
    String? accountId,
    String? emailAddress,
    String? addressStatus,
    String? payerStatus,
    PayerName? payerName,
    String? countryCode,
  }) {
    return PayerInfo(
      accountId: accountId ?? this.accountId,
      emailAddress: emailAddress ?? this.emailAddress,
      addressStatus: addressStatus ?? this.addressStatus,
      payerStatus: payerStatus ?? this.payerStatus,
      payerName: payerName ?? this.payerName,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  factory PayerInfo.fromJson(Map<String, dynamic> json) {
    return PayerInfo(
      accountId: json["account_id"],
      emailAddress: json["email_address"],
      addressStatus: json["address_status"],
      payerStatus: json["payer_status"],
      payerName: json["payer_name"] == null
          ? null
          : PayerName.fromJson(json["payer_name"]),
      countryCode: json["country_code"],
    );
  }

  Map<String, dynamic> toJson() => {
    "account_id": accountId,
    "email_address": emailAddress,
    "address_status": addressStatus,
    "payer_status": payerStatus,
    "payer_name": payerName?.toJson(),
    "country_code": countryCode,
  };
}

class PayerName {
  PayerName({this.givenName, this.surname, this.alternateFullName});

  final String? givenName;
  final String? surname;
  final String? alternateFullName;

  PayerName copy({
    String? givenName,
    String? surname,
    String? alternateFullName,
  }) {
    return PayerName(
      givenName: givenName ?? this.givenName,
      surname: surname ?? this.surname,
      alternateFullName: alternateFullName ?? this.alternateFullName,
    );
  }

  factory PayerName.fromJson(Map<String, dynamic> json) {
    return PayerName(
      givenName: json["given_name"],
      surname: json["surname"],
      alternateFullName: json["alternate_full_name"],
    );
  }

  Map<String, dynamic> toJson() => {
    "given_name": givenName,
    "surname": surname,
    "alternate_full_name": alternateFullName,
  };
}

class ShippingInfo {
  ShippingInfo({this.name, this.method, this.address});

  final String? name;
  final String? method;
  final Address? address;

  ShippingInfo copy({String? name, String? method, Address? address}) {
    return ShippingInfo(
      name: name ?? this.name,
      method: method ?? this.method,
      address: address ?? this.address,
    );
  }

  factory ShippingInfo.fromJson(Map<String, dynamic> json) {
    return ShippingInfo(
      name: json["name"],
      method: json["method"],
      address: json["address"] == null
          ? null
          : Address.fromJson(json["address"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "method": method,
    "address": address?.toJson(),
  };
}

class Address {
  Address({this.line1, this.city, this.countryCode, this.postalCode});

  final String? line1;
  final String? city;
  final String? countryCode;
  final String? postalCode;

  Address copy({
    String? line1,
    String? city,
    String? countryCode,
    String? postalCode,
  }) {
    return Address(
      line1: line1 ?? this.line1,
      city: city ?? this.city,
      countryCode: countryCode ?? this.countryCode,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1: json["line1"],
      city: json["city"],
      countryCode: json["country_code"],
      postalCode: json["postal_code"],
    );
  }

  Map<String, dynamic> toJson() => {
    "line1": line1,
    "city": city,
    "country_code": countryCode,
    "postal_code": postalCode,
  };
}

class TransactionInfo {
  TransactionInfo({
    this.paypalAccountId,
    this.transactionId,
    this.transactionEventCode,
    this.transactionInitiationDate,
    this.transactionUpdatedDate,
    this.transactionAmount,
    this.feeAmount,
    this.transactionStatus,
    this.protectionEligibility,
  });

  final String? paypalAccountId;
  final String? transactionId;
  final String? transactionEventCode;
  final String? transactionInitiationDate;
  final String? transactionUpdatedDate;
  final Amount? transactionAmount;
  final Amount? feeAmount;
  final String? transactionStatus;
  final String? protectionEligibility;

  TransactionInfo copy({
    String? paypalAccountId,
    String? transactionId,
    String? transactionEventCode,
    String? transactionInitiationDate,
    String? transactionUpdatedDate,
    Amount? transactionAmount,
    Amount? feeAmount,
    String? transactionStatus,
    String? protectionEligibility,
  }) {
    return TransactionInfo(
      paypalAccountId: paypalAccountId ?? this.paypalAccountId,
      transactionId: transactionId ?? this.transactionId,
      transactionEventCode: transactionEventCode ?? this.transactionEventCode,
      transactionInitiationDate:
          transactionInitiationDate ?? this.transactionInitiationDate,
      transactionUpdatedDate:
          transactionUpdatedDate ?? this.transactionUpdatedDate,
      transactionAmount: transactionAmount ?? this.transactionAmount,
      feeAmount: feeAmount ?? this.feeAmount,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      protectionEligibility:
          protectionEligibility ?? this.protectionEligibility,
    );
  }

  factory TransactionInfo.fromJson(Map<String, dynamic> json) {
    return TransactionInfo(
      paypalAccountId: json["paypal_account_id"],
      transactionId: json["transaction_id"],
      transactionEventCode: json["transaction_event_code"],
      transactionInitiationDate: json["transaction_initiation_date"],
      transactionUpdatedDate: json["transaction_updated_date"],
      transactionAmount: json["transaction_amount"] == null
          ? null
          : Amount.fromJson(json["transaction_amount"]),
      feeAmount: json["fee_amount"] == null
          ? null
          : Amount.fromJson(json["fee_amount"]),
      transactionStatus: json["transaction_status"],
      protectionEligibility: json["protection_eligibility"],
    );
  }

  Map<String, dynamic> toJson() => {
    "paypal_account_id": paypalAccountId,
    "transaction_id": transactionId,
    "transaction_event_code": transactionEventCode,
    "transaction_initiation_date": transactionInitiationDate,
    "transaction_updated_date": transactionUpdatedDate,
    "transaction_amount": transactionAmount?.toJson(),
    "fee_amount": feeAmount?.toJson(),
    "transaction_status": transactionStatus,
    "protection_eligibility": protectionEligibility,
  };
}

/*
{
	"transaction_details": [
		{
			"transaction_info": {
				"paypal_account_id": "F4YHVT9RFTZSU",
				"transaction_id": "9GS80322P28628837",
				"transaction_event_code": "T0004",
				"transaction_initiation_date": "2014-07-12T02:05:19+0000",
				"transaction_updated_date": "2014-07-12T02:05:19+0000",
				"transaction_amount": {
					"currency_code": "USD",
					"value": "23.05"
				},
				"fee_amount": {
					"currency_code": "USD",
					"value": "-0.97"
				},
				"transaction_status": "S",
				"protection_eligibility": "01"
			},
			"payer_info": {
				"account_id": "F4YHVT9RFTZSU",
				"email_address": "payer@example.com",
				"address_status": "Y",
				"payer_status": "Y",
				"payer_name": {
					"given_name": "Matt",
					"surname": "Cole",
					"alternate_full_name": "Amalgamated Steel & Oatmeal of Sudan"
				},
				"country_code": "US"
			},
			"shipping_info": {
				"name": "Matt Cole",
				"method": "0",
				"address": {
					"line1": "7700 Eastport Pkwy",
					"city": "La Vista",
					"country_code": "US",
					"postal_code": "68128"
				}
			},
			"cart_info": {
				"item_details": [
					{
						"item_code": "110208696345",
						"item_name": "Auction with details",
						"item_quantity": "3",
						"item_unit_price": {
							"currency_code": "USD",
							"value": "5.00"
						},
						"item_amount": {
							"currency_code": "USD",
							"value": "15.00"
						},
						"tax_amounts": [
							{
								"tax_amount": {
									"currency_code": "USD",
									"value": "1.05"
								}
							}
						],
						"basic_shipping_amount": {
							"currency_code": "USD",
							"value": "7.00"
						},
						"total_item_amount": {
							"currency_code": "USD",
							"value": "23.05"
						}
					}
				]
			},
			"store_info": {},
			"auction_info": {
				"auction_site": "eBay",
				"auction_item_site": "https://example.com/?ViewItem&item=110208696345",
				"auction_buyer_id": "testuser_mikaey0",
				"auction_closing_date": "1970-01-01T00:00:00+0000"
			},
			"incentive_info": {}
		}
	],
	"account_number": "XZXSPECPDZHZU",
	"last_refreshed_datetime": "2017-01-02T06:59:59+0000",
	"page": 1,
	"total_items": 1,
	"total_pages": 1,
	"links": [
		{
			"href": "https://api-m.sandbox.paypal.com/v1/reporting/transactions??start_date=2014-07-12T00:00:00-0700&end_date=2014-07-12T23:59:59-0700&transaction_id=9GS80322P28628837&fields=all&page_size=100&page=1",
			"rel": "self",
			"method": "GET"
		}
	]
}*/
