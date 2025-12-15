import 'dart:js_interop';

@JS('paypal')
external PaypalNamespace? get paypal;

extension type PaypalNamespace(JSObject _) implements JSObject {
  @JS('Buttons')
  external Buttons call(ButtonsOptions options);
}

extension type Buttons(JSObject _) implements JSObject {
  external void render(JSAny elementOrSelector);
}

@JS()
@anonymous
extension type ButtonsOptions._(JSObject _) implements JSObject {
  external factory ButtonsOptions({
    JSFunction? createOrder,
    JSFunction? onApprove,
    JSFunction? onCancel,
    JSFunction? onError,
  });
}
