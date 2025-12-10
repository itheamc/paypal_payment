import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:paypal_payment/paypal_payment.dart';
import '../../common/response_viewer.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _status = '';
  String _formattedResponse = '';

  void _updateStatus(String status) {
    setState(() {
      _status = status;
    });
  }

  void _updateResponse(dynamic response) {
    try {
      final jsonObject = response is String ? jsonDecode(response) : response;
      // If it's an object with toJson(), use that
      final map = (jsonObject as dynamic).toJson();
      final prettyString = const JsonEncoder.withIndent('  ').convert(map);
      setState(() {
        _formattedResponse = prettyString;
      });
    } catch (e) {
      // Fallback if not serializable or simple string
      setState(() {
        _formattedResponse = response.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Status: $_status",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _updateStatus("Starting Checkout Order...");
              _formattedResponse = '';
              PaypalPayment.instance.checkout.checkoutOrder(
                intent: OrderIntent.capture,
                purchaseUnits: [
                  PurchaseUnit(
                    referenceId: "test-checkout-order",
                    amount: Amount(currencyCode: "USD", value: "10.0"),
                  ),
                ],
                onInitiated: () => _updateStatus("Checkout Initiated..."),
                onSuccess: (orderId) {
                  _updateStatus("Checkout Order Success: $orderId");
                  // checkoutOrder returns just an ID string, so we display that
                  _updateResponse({"orderId": orderId});
                },
                onError: (error) =>
                    _updateStatus("Checkout Order Error: $error"),
              );
            },
            child: const Text("Checkout Order (Capture)"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _updateStatus("Starting Checkout Payment...");
              _formattedResponse = '';
              PaypalPayment.instance.checkout.checkoutPayment(
                context,
                intent: PaymentIntent.sale,
                payer: Payer(paymentMethod: "paypal"),
                transactions: [
                  Transaction(
                    amount: TransactionAmount(currency: "USD", total: "10.0"),
                    description: "Test Payment",
                  ),
                ],
                redirectUrls: RedirectUrls(
                  returnUrl: "https://example.com/return",
                  cancelUrl: "https://example.com/cancel",
                ),
                onSuccess: (paymentId) {
                  _updateStatus("Checkout Payment Success: $paymentId");
                  _updateResponse({"paymentId": paymentId});
                },
                onError: (error) =>
                    _updateStatus("Checkout Payment Error: $error"),
              );
            },
            child: const Text("Checkout Payment (Sale)"),
          ),
          ResponseViewer(text: _formattedResponse),
        ],
      ),
    );
  }
}
