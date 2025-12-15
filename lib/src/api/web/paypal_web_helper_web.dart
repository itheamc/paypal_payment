import 'dart:async';
import 'dart:js_interop'; // ensure this is imported if not already, or check if 'web' exports it.
import 'package:web/web.dart' as web;
import 'paypal_web_helper.dart';

PaypalWebHelper getHelper() => PaypalWebHelperWeb();

class PaypalWebHelperWeb implements PaypalWebHelper {
  @override
  dynamic openPopup() {
    // Open a blank window immediately.
    // 'width=450,height=600,center=true'
    const features =
        'width=450,height=600,location=yes,status=yes,scrollbars=yes';
    try {
      final win = web.window.open('', 'paypal_checkout', features);
      if (win != null) {
        win.document.write(
          '''
          <html>
            <head>
              <title>PayPal Checkout</title>
              <style>
                body {
                  display: flex;
                  flex-direction: column;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                  margin: 0;
                  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
                  background-color: #f5f7fa;
                  color: #2c3e50;
                }
                .loader {
                  border: 4px solid #f3f3f3;
                  border-top: 4px solid #0070ba;
                  border-radius: 50%;
                  width: 40px;
                  height: 40px;
                  animation: spin 1s linear infinite;
                  margin-bottom: 20px;
                }
                @keyframes spin {
                  0% { transform: rotate(0deg); }
                  100% { transform: rotate(360deg); }
                }
                p {
                  font-size: 16px;
                  font-weight: 500;
                  color: #666;
                }
              </style>
            </head>
            <body>
              <div class="loader"></div>
              <p>Redirecting to PayPal...</p>
            </body>
          </html>
        '''
              .toJS,
        );
      }
      return win;
    } catch (e) {
      print("Error opening popup: $e");
      return null;
    }
  }

  @override
  void redirectPopup(dynamic window, String url) {
    if (window != null && window is web.Window) {
      window.location.href = url;
    }
  }

  @override
  Future<String?> monitorPopup(dynamic window) {
    final completer = Completer<String?>();
    if (window == null || window is! web.Window) {
      completer.completeError("Invalid window object");
      return completer.future;
    }

    // Polling interval
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      try {
        if (window.closed == true) {
          timer.cancel();
          if (!completer.isCompleted) {
            // If closed without success URL, consider it generic cancel or close.
            // We can't distinguish distinct "cancel" button vs "x" button easily
            // unless we inspect the URL before it closes, but cross-origin restrictions apply.
            // However, if we preserve the return URL, we might catch it.
            completer.complete(null);
          }
          return;
        }

        try {
          // Check for same-origin (user returned to our app)
          // Accessing location.href throws if cross-origin (while on PayPal).
          // It succeeds when back on our domain.
          final href = window.location.href;
          if (href.isNotEmpty) {
            final uri = Uri.parse(href);
            // Verify it is our return URL or contains specific params
            // PayerID is usually present on success.
            if (uri.queryParameters.containsKey('PayerID')) {
              timer.cancel();
              window.close(); // Close the popup
              completer.complete(uri.queryParameters['PayerID']);
            }
            // Handle explicit cancel return if applicable
          }
        } catch (e) {
          // Cross-origin: User is still on PayPal. Ignore.
        }
      } catch (e) {
        timer.cancel();
        if (!completer.isCompleted) completer.completeError(e);
      }
    });

    return completer.future;
  }

  @override
  String getReturnUrl() {
    return web.window.location.href;
  }
}
