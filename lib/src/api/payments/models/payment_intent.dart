enum PaymentIntent {
  sale,
  authorize,
  order;

  /// Parses a string to a [PaymentIntent] enum using a switch expression.
  ///
  /// Returns the corresponding enum value if [str] matches a known value,
  /// otherwise returns `null`. The comparison is case-insensitive.
  static PaymentIntent? fromStr(String? str) {
    return switch (str?.toLowerCase()) {
      'sale' => .sale,
      'authorize' => .authorize,
      'order' => .order,
      _ => null,
    };
  }
}
