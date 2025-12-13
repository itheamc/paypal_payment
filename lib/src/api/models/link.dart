/// Represents a HATEOAS (Hypermedia as the Engine of Application State) link.
/// These links are used to represent relationships between resources.
class Link {
  /// Creates an instance of [Link].
  Link({this.href, this.rel, this.method});

  /// The complete URL of the link.
  final String? href;

  /// The relationship of the link to the current resource.
  final String? rel;

  /// The HTTP method to use when following the link.
  final String? method;

  /// Creates a copy of this [Link] with the given fields replaced with new values.
  Link copy({String? href, String? rel, String? method}) {
    return Link(
      href: href ?? this.href,
      rel: rel ?? this.rel,
      method: method ?? this.method,
    );
  }

  /// Creates a [Link] from a JSON object.
  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(href: json["href"], rel: json["rel"], method: json["method"]);
  }

  /// Converts this [Link] object to a JSON object.
  Map<String, dynamic> toJson() => {"href": href, "rel": rel, "method": method};
}
