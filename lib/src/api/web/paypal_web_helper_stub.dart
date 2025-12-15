import 'paypal_web_helper.dart';

PaypalWebHelper getHelper() => PaypalWebHelperStub();

class PaypalWebHelperStub implements PaypalWebHelper {
  @override
  dynamic openPopup() => null;

  @override
  Future<String?> monitorPopup(window) async => null;

  @override
  void redirectPopup(window, String url) {}

  @override
  String getReturnUrl() => "https://example.com/return";
}
