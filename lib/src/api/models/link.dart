class Link {
  Link({this.href, this.rel, this.method});

  final String? href;
  final String? rel;
  final String? method;

  Link copy({String? href, String? rel, String? method}) {
    return Link(
      href: href ?? this.href,
      rel: rel ?? this.rel,
      method: method ?? this.method,
    );
  }

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(href: json["href"], rel: json["rel"], method: json["method"]);
  }

  Map<String, dynamic> toJson() => {"href": href, "rel": rel, "method": method};
}
