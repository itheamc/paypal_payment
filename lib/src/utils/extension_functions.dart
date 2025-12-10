extension MapStringDynamicExt on Map<String, dynamic> {
  /// Returns a new map containing only the entries from the original
  /// map that have non-null values.
  ///
  Map<String, dynamic> filterNotNull() {
    return Map<String, dynamic>.from(this)
      ..removeWhere((key, value) => value == null);
  }
}

extension DateTimeExt on DateTime {
  /// Returns the DateTime as a UTC string in ISO 8601 format,
  /// truncated to the second.
  ///
  /// This format (e.g., "2024-12-08T10:30:00Z") is often required by APIs,
  /// such as the PayPal Transaction Search API, which do not accept
  /// milliseconds.
  String get formattedUtcIsoString {
    final str = toUtc().toIso8601String();
    final parts = str.split('.');
    return '${parts.first}Z';
  }
}
