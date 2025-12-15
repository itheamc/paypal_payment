import 'environment.dart';

/// Configuration class for PayPal services.
///
/// Holds the necessary credentials and environment settings
/// to interact with the PayPal API.
class PaypalConfiguration {
  /// The client ID obtained from the PayPal developer dashboard.
  ///
  /// This is required to authenticate with PayPal's services.
  final String clientId;

  /// The client secret obtained from the PayPal developer dashboard.
  ///
  /// This is required to authenticate with PayPal's services.
  final String clientSecret;

  /// The environment for the PayPal API.
  ///
  /// Defaults to [Environment.sandbox] for testing purposes.
  /// Change to [Environment.live] for production transactions.
  final Environment environment;

  /// The currency code to use for transactions (e.g., 'USD', 'EUR').
  final String? currency;

  /// Creates a new instance of [PaypalConfiguration].
  ///
  /// Requires a [clientId] and [clientSecret].
  /// The [environment] defaults to [Environment.sandbox] if not specified.
  const PaypalConfiguration({
    required this.clientId,
    required this.clientSecret,
    this.environment = .sandbox,
    this.currency,
  });
}
