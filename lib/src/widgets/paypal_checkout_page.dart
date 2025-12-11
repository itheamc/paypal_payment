import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/payments/v1/models/redirect_urls.dart';

/// A StatefulWidget that displays the PayPal checkout page in a [WebView].
///
/// This widget is used to present the PayPal payment flow to the user.
/// It navigates to the provided [approvalUrl] and listens for a redirect
/// to the [returnUrl] to complete the payment process.
///
class PaypalCheckoutPage extends StatefulWidget {
  /// The URL provided by PayPal to approve the payment. The [WebView] will
  /// initially load this URL.
  ///
  final String approvalUrl;

  /// The URL to which PayPal redirects the user after the payment is approved or canceled.
  /// This widget listens for URL changes and when the new URL contains this
  /// [redirectUrls.returnUrl] or [redirectUrls.cancelUrl], it pops the navigation stack
  /// and returns the query parameters.
  ///
  final RedirectUrls redirectUrls;

  /// Creates a new instance of [PaypalCheckoutPage].
  ///
  /// Requires [approvalUrl] and [returnUrl] to function correctly.
  ///
  const PaypalCheckoutPage({
    super.key,
    required this.approvalUrl,
    required this.redirectUrls,
  });

  @override
  State<PaypalCheckoutPage> createState() => _PaypalCheckoutPageState();
}

/// The state for the [PaypalCheckoutPage] widget.
///
/// Manages the [WebViewController] and handles the navigation logic
/// for the PayPal checkout flow.
class _PaypalCheckoutPageState extends State<PaypalCheckoutPage> {
  /// The controller for the [WebView] used to display the checkout page.
  ///
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  /// Method to initialize the [WebViewController]
  ///
  void _initializeController() {
    // Initialize the WebViewController.
    _controller = WebViewController()
      // Ensure a clean session by clearing cache and local storage.
      ..clearCache()
      ..clearLocalStorage()
      // Enable JavaScript to ensure the PayPal page functions correctly.
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Set up the navigation delegate to handle URL changes.
      ..setNavigationDelegate(
        NavigationDelegate(
          // This callback is currently unused but can be useful for debugging.
          onPageFinished: (_) {},
          // Called when the URL in the WebView changes.
          onUrlChange: (c) {
            // Getting change url
            final url = c.url;

            // If url is null return early
            if (url == null) return;

            // Check if the new URL contains the specified returnUrl.
            if (url.contains(widget.redirectUrls.returnUrl)) {
              // If it does, parse the URL to extract query parameters.
              final uri = Uri.parse(url);
              final queryParams = uri.queryParameters;
              // Pop the current page from the navigation stack and pass back
              // the query parameters, which typically include payment
              // details like 'PayerID' and 'paymentId'.
              // We are doing like this to support other routing like go_router
              // But we can also sent these response on callback function
              Navigator.pop(context, {
                "success": true,
                "queryParams": queryParams,
              });

              return;
            }

            // Else check if the new URL contains the specified cancelUrl.
            if (url.contains(widget.redirectUrls.cancelUrl)) {
              // If it does, pop the current page from the navigation stack.
              Navigator.pop(context, {"success": false, "queryParams": null});
            }
          },
        ),
      )
      // Load the initial PayPal approval URL.
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
