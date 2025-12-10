import '../../../../utils/extension_functions.dart';
import 'shipping_address.dart';

class ItemList {
  ItemList({this.items = const [], this.shippingAddress});

  final List<Item> items;
  final ShippingAddress? shippingAddress;

  ItemList copy({List<Item>? items, ShippingAddress? shippingAddress}) {
    return ItemList(
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }

  factory ItemList.fromJson(Map<String, dynamic> json) {
    return ItemList(
      items: json["items"] == null || json["items"] is! List
          ? []
          : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
      shippingAddress: json["shipping_address"] == null
          ? null
          : ShippingAddress.fromJson(json["shipping_address"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "items": items.map((x) => x.toJson()).toList(),
    "shipping_address": shippingAddress?.toJson(),
  }.filterNotNull();
}

class Item {
  Item({
    this.name,
    this.sku,
    this.price,
    this.currency,
    this.quantity,
    this.description,
    this.tax,
  });

  final String? name;
  final String? sku;
  final String? price;
  final String? currency;
  final String? quantity;
  final String? description;
  final String? tax;

  Item copy({
    String? name,
    String? sku,
    String? price,
    String? currency,
    String? quantity,
    String? description,
    String? tax,
  }) {
    return Item(
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      tax: tax ?? this.tax,
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json["name"],
      sku: json["sku"],
      price: json["price"]?.toString(),
      currency: json["currency"],
      quantity: json["quantity"]?.toString(),
      description: json["description"],
      tax: json["tax"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "sku": sku,
    "price": price,
    "currency": currency,
    "quantity": quantity,
    "description": description,
    "tax": tax,
  }.filterNotNull();
}
