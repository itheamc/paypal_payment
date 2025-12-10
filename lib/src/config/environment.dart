/// Defines the PayPal API environments.
///
/// This enum is used to specify whether API calls should be directed
/// to PayPal's testing (sandbox) or production (live) servers.
enum Environment {
  /// The sandbox environment for testing purposes.
  ///
  /// API calls using this environment will not result in real transactions.
  /// Base URL: `https://api-m.sandbox.paypal.com`
  sandbox('https://api-m.sandbox.paypal.com'),

  /// The live environment for production use.
  ///
  /// API calls using this environment will result in real financial transactions.
  /// Base URL: `https://api.paypal.com`
  live('https://api.paypal.com');

  /// The base URL for the selected environment.
  final String baseUrl;

  /// Gets the full URL for V1 of the PayPal API.
  ///
  /// Combines the [baseUrl] with the `/v1` path segment.
  String get urlV1 => '$baseUrl/v1';

  /// Gets the full URL for V2 of the PayPal API.
  ///
  /// Combines the [baseUrl] with the `/v2` path segment.
  String get urlV2 => '$baseUrl/v2';

  /// A constant constructor to initialize an enum value with its [baseUrl].
  const Environment(this.baseUrl);
}
