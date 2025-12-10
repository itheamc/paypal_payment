class SellerProtection {
  SellerProtection({this.status, this.disputeCategories = const []});

  final String? status;
  final List<String> disputeCategories;

  SellerProtection copy({String? status, List<String>? disputeCategories}) {
    return SellerProtection(
      status: status ?? this.status,
      disputeCategories: disputeCategories ?? this.disputeCategories,
    );
  }

  factory SellerProtection.fromJson(Map<String, dynamic> json) {
    return SellerProtection(
      status: json["status"],
      disputeCategories: json["dispute_categories"] is! List
          ? []
          : List<String>.from(json["dispute_categories"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "dispute_categories": disputeCategories.map((x) => x).toList(),
  };
}
