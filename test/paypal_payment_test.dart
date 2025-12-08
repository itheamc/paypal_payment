import 'package:flutter_test/flutter_test.dart';
import 'package:paypal_payment/paypal_payment.dart';
import 'package:paypal_payment/paypal_payment_platform_interface.dart';
import 'package:paypal_payment/paypal_payment_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPaypalPaymentPlatform
    with MockPlatformInterfaceMixin
    implements PaypalPaymentPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PaypalPaymentPlatform initialPlatform = PaypalPaymentPlatform.instance;

  test('$MethodChannelPaypalPayment is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPaypalPayment>());
  });

  test('getPlatformVersion', () async {
    PaypalPayment paypalPaymentPlugin = PaypalPayment();
    MockPaypalPaymentPlatform fakePlatform = MockPaypalPaymentPlatform();
    PaypalPaymentPlatform.instance = fakePlatform;

    expect(await paypalPaymentPlugin.getPlatformVersion(), '42');
  });
}
