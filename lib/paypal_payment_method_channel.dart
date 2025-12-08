import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'paypal_payment_platform_interface.dart';

/// An implementation of [PaypalPaymentPlatform] that uses method channels.
class MethodChannelPaypalPayment extends PaypalPaymentPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('paypal_payment');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
