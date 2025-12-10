import 'package:paypal_payment/src/config/env/env.dart';
import 'config/env/env_keys.dart';
import 'config/environment.dart';
import 'api/orders/orders_api.dart';
import 'api/payments/payments_api.dart';
import 'api/transactions/transactions_api.dart';
import 'config/paypal_configuration.dart';
import 'network/paypal_http_service.dart';
import 'pigeon_generated.dart';
import 'utils/logger.dart';

/// The main class for interacting with the PayPal SDK.
///
/// This class provides access to various PayPal APIs and handles the
/// initialization of the payment services. It follows the singleton pattern
/// to ensure a single, consistent instance throughout the app.
///
/// Access the singleton instance via `PaypalPayment.instance`.
class PaypalPayment {
  /// An instance of the host API for native PayPal functionality.
  ///
  /// This is used for communication with the native platform's PayPal SDK.
  ///
  final PaypalPaymentHostApi _hostApi;

  /// Provides access to the PayPal Orders API.
  ///
  /// Use this to create, update, and retrieve order details.
  ///
  final OrdersApi orders;

  /// Provides access to the PayPal Payments API.
  ///
  /// Use this to manage payment-related operations.
  ///
  final PaymentsApi payments;

  /// Provides access to the PayPal Transactions API.
  ///
  /// Use this to view details about transactions.
  ///
  final TransactionsApi transactions;

  /// A private constructor to prevent direct instantiation.
  ///
  /// This is part of the singleton pattern implementation. It initializes
  /// the API handlers and native host API instances.
  ///
  PaypalPayment._()
    : _hostApi = PaypalPaymentHostApi(),
      orders = OrdersApi.instance,
      payments = PaymentsApi.instance,
      transactions = TransactionsApi.instance;

  /// The internal, private instance of the [PaypalPayment] class.
  ///
  static PaypalPayment? _instance;

  /// Provides a lazy-loaded singleton instance of the [PaypalPayment] class.
  ///
  /// On first access, it creates and initializes a new instance.
  /// Subsequent accesses return the existing instance.
  ///
  static PaypalPayment get instance {
    if (_instance == null) {
      Logger.logMessage("PaypalPayment is initialized!");
    }
    _instance ??= PaypalPayment._();
    return _instance!;
  }

  /// Initializes the PayPal payment services.
  ///
  /// This method must be called before any other PayPal operations. It retrieves
  /// the `clientId` and `clientSecret` from the environment variables
  /// (`EnvKeys.paypalClientId` and `EnvKeys.paypalClientSecret`) and sets up
  /// the necessary HTTP services and native SDK configurations.
  ///
  /// [environment] The PayPal environment to use, either `.sandbox` or `.live`.
  /// Defaults to `.sandbox`.
  ///
  Future<void> initialize([Environment environment = .sandbox]) async {
    try {
      // Loading environment variables
      await Env.instance.load();

      // Creating PaypalConfiguration instance
      final configuration = PaypalConfiguration(
        clientId: Env.instance.valueOf(EnvKeys.paypalClientId) ?? '',
        clientSecret: Env.instance.valueOf(EnvKeys.paypalClientSecret) ?? '',
        environment: environment,
      );

      // Setting configuration to PaypalHttpService
      PaypalHttpService.instance.configuration = configuration;

      // Initializing PaypalPaymentHostApi
      await _hostApi.initialize(
        configuration.clientId,
        configuration.environment.name,
      );
    } catch (e) {
      Logger.logError(e.toString());
    }
  }
}
