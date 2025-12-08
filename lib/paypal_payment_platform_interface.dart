import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'paypal_payment_method_channel.dart';

abstract class PaypalPaymentPlatform extends PlatformInterface {
  /// Constructs a PaypalPaymentPlatform.
  PaypalPaymentPlatform() : super(token: _token);

  static final Object _token = Object();

  static PaypalPaymentPlatform _instance = MethodChannelPaypalPayment();

  /// The default instance of [PaypalPaymentPlatform] to use.
  ///
  /// Defaults to [MethodChannelPaypalPayment].
  static PaypalPaymentPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PaypalPaymentPlatform] when
  /// they register themselves.
  static set instance(PaypalPaymentPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
