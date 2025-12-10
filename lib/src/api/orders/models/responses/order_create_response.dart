import '../../../models/link.dart';

enum OrderCreateStatus {
  created,
  saved,
  approved,
  voided,
  completed,
  payerActionRequired;

  String get toStr => switch (this) {
    OrderCreateStatus.created => "CREATED",
    OrderCreateStatus.saved => "SAVED",
    OrderCreateStatus.approved => "APPROVED",
    OrderCreateStatus.voided => "VOIDED",
    OrderCreateStatus.completed => "COMPLETED",
    OrderCreateStatus.payerActionRequired => "PAYER_ACTION_REQUIRED",
  };

  static OrderCreateStatus? fromString(String? value) {
    return switch (value) {
      "CREATED" => OrderCreateStatus.created,
      "SAVED" => OrderCreateStatus.saved,
      "APPROVED" => OrderCreateStatus.approved,
      "VOIDED" => OrderCreateStatus.voided,
      "COMPLETED" => OrderCreateStatus.completed,
      "PAYER_ACTION_REQUIRED" => OrderCreateStatus.payerActionRequired,
      _ => null,
    };
  }
}

class OrderCreateResponse {
  OrderCreateResponse({this.id, this.status, this.links = const []});

  final String? id;
  final OrderCreateStatus? status;
  final List<Link> links;

  /// Getter for Approval and Execute Url
  ///
  Link? get approvalLink =>
      links.where((element) => element.rel == 'approve').firstOrNull;

  OrderCreateResponse copy({
    String? id,
    OrderCreateStatus? status,
    List<Link>? links,
  }) {
    return OrderCreateResponse(
      id: id ?? this.id,
      status: status ?? this.status,
      links: links ?? this.links,
    );
  }

  factory OrderCreateResponse.fromJson(Map<String, dynamic> json) {
    return OrderCreateResponse(
      id: json["id"],
      status: OrderCreateStatus.fromString(json["status"]),
      links: json["links"] == null || json["links"] is! List
          ? []
          : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status?.toStr,
    "links": links.map((x) => x.toJson()).toList(),
  };
}

/*
{
	"id": "55X49551E4477102F",
	"status": "CREATED",
	"links": [
		{
			"href": "https://api.sandbox.paypal.com/v2/checkout/orders/55X49551E4477102F",
			"rel": "self",
			"method": "GET"
		},
		{
			"href": "https://www.sandbox.paypal.com/checkoutnow?token=55X49551E4477102F",
			"rel": "approve",
			"method": "GET"
		},
		{
			"href": "https://api.sandbox.paypal.com/v2/checkout/orders/55X49551E4477102F",
			"rel": "update",
			"method": "PATCH"
		},
		{
			"href": "https://api.sandbox.paypal.com/v2/checkout/orders/55X49551E4477102F/capture",
			"rel": "capture",
			"method": "POST"
		}
	]
}*/
