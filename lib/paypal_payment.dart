
import 'paypal_payment_platform_interface.dart';

class PaypalPayment {
  Future<String?> getPlatformVersion() {
    return PaypalPaymentPlatform.instance.getPlatformVersion();
  }
}
