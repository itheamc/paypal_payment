import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon_generated.dart',
    dartPackageName: 'paypal_payment',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/itheamc/paypal_payment/pigeon/PigeonGenerated.kt',
    kotlinOptions: KotlinOptions(),
    swiftOut: 'ios/Classes/Pigeon/PigeonGenerated.swift',
    swiftOptions: SwiftOptions(),
  ),
)
@HostApi()
abstract class PaypalPaymentHostApi {
  void initialize(String clientId, String environment);
}

@HostApi()
abstract class PayPalPaymentWebCheckoutHostApi {
  void startCheckout(
    String orderId,
    String fundingSource,
  );
}

// @FlutterApi()
// abstract class PaypalPaymentFlutterApi {
//   void onTest(double fps);
// }

sealed class PayPalWebCheckoutResultEvent {}

class PayPalWebCheckoutSuccessResultEvent extends PayPalWebCheckoutResultEvent {
  PayPalWebCheckoutSuccessResultEvent(this.orderId, this.payerId);

  final String? orderId;
  final String? payerId;
}

class PayPalWebCheckoutFailureResultEvent extends PayPalWebCheckoutResultEvent {
  PayPalWebCheckoutFailureResultEvent(
    this.orderId,
    this.reason,
    this.code,
    this.correlationId,
  );

  final String? orderId;
  final String reason;
  final int code;
  final String? correlationId;
}

class PayPalWebCheckoutCanceledResultEvent
    extends PayPalWebCheckoutResultEvent {
  PayPalWebCheckoutCanceledResultEvent(this.orderId);

  final String? orderId;
}

class PayPalWebCheckoutErrorResultEvent extends PayPalWebCheckoutResultEvent {
  PayPalWebCheckoutErrorResultEvent(this.error);

  final String? error;
}

@EventChannelApi()
abstract class PayPalWebCheckoutResultEventChannelApi {
  PayPalWebCheckoutResultEvent payPalWebCheckoutResultEvent();
}
