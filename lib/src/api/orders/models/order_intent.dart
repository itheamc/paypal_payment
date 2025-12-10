enum OrderIntent {
  capture,
  authorize;

  /// Parses a string to a [OrderIntent] enum using a switch expression.
  ///
  /// Returns the corresponding enum value if [str] matches a known value,
  /// otherwise returns `null`. The comparison is case-insensitive.
  static OrderIntent? fromStr(String? str) {
    return switch (str?.toLowerCase()) {
      'capture' => .capture,
      'authorize' => .authorize,
      _ => null,
    };
  }
}
