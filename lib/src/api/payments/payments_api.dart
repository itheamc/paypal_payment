import '../../network/paypal_http_service.dart';
import '../../utils/logger.dart';
import 'v1/payments_api_v1.dart';
import 'v2/payments_api_v2.dart';

/// The main entry point for interacting with the PayPal Payments API.
///
/// This class provides a singleton instance to access different versions
/// of the payments API, such as `v1` and `v2`. It encapsulates the
/// underlying HTTP service and API versioning.
class PaymentsApi {
  /// A reference to the shared [PaypalHttpService] instance used for all
  /// network requests.
  final PaypalHttpService _httpService;

  /// Provides access to the methods available in version 1 of the Payments API.
  ///
  final PaymentsApiV1 v1;

  /// Provides access to the methods available in version 2 of the Payments API.
  ///
  final PaymentsApiV2 v2;

  /// Private internal constructor to enforce the singleton pattern.
  /// It initializes the http service and the different API versions.
  ///
  PaymentsApi._()
    : _httpService = PaypalHttpService.instance,
      v1 = PaymentsApiV1.instance,
      v2 = PaymentsApiV2.instance;

  /// The static, private instance of the [PaymentsApi].
  ///
  static PaymentsApi? _instance;

  /// Provides a lazy-loaded, singleton instance of the [PaymentsApi].
  ///
  /// This ensures that only one instance of the API handler exists throughout
  /// the application's lifecycle.
  ///
  static PaymentsApi get instance {
    if (_instance == null) {
      Logger.logMessage("PaymentsApi is initialized!");
    }
    _instance ??= PaymentsApi._();
    return _instance!;
  }
}
