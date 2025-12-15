import 'paypal_web_helper_stub.dart'
    if (dart.library.js_interop) 'paypal_web_helper_web.dart';

abstract class PaypalWebHelper {
  static PaypalWebHelper _instance = getHelper();
  static PaypalWebHelper get instance => _instance;

  dynamic openPopup();
  void redirectPopup(dynamic window, String url);
  Future<String?> monitorPopup(dynamic window);
  String getReturnUrl();
}
