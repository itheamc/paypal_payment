import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:paypal_payment/paypal_payment.dart';
import '../../common/response_viewer.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _status = '';
  String _formattedResponse = '';
  final TextEditingController _orderIdController = TextEditingController();

  OrderIntent _selectedIntent = OrderIntent.capture;

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
          DropdownButtonFormField<OrderIntent>(
            initialValue: _selectedIntent,
            decoration: const InputDecoration(
              labelText: "Order Intent",
              border: OutlineInputBorder(),
            ),
            items: OrderIntent.values.map((intent) {
              return DropdownMenuItem(
                value: intent,
                child: Text(intent.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedIntent = value;
                });
              }
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _updateStatus("Creating Order (${_selectedIntent.name})...");
              _formattedResponse = '';
              PaypalPayment.instance.orders.createOrder(
                intent: _selectedIntent,
                purchaseUnits: [
                  PurchaseUnit(
                    referenceId: "order-test-1",
                    amount: Amount(currencyCode: "USD", value: "5.0"),
                  ),
                ],
                onSuccess: (res) {
                  _updateStatus("Order Created: ${res.id}");
                  _updateResponse(res);
                  if (res.id != null) {
                    setState(() {
                      _orderIdController.text = res.id!;
                    });
                  }
                },
                onError: (error) => _updateStatus("Create Order Error: $error"),
              );
            },
            child: const Text("Create Order"),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _orderIdController,
            decoration: const InputDecoration(
              labelText: "Order ID",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              final orderId = _orderIdController.text;
              if (orderId.isEmpty) {
                _updateStatus("Please enter an Order ID");
                return;
              }
              _updateStatus("Starting Native Checkout for $orderId...");
              _formattedResponse = '';
              PaypalPayment.instance.orders.startNativeCheckout(
                orderId: orderId,
                onSuccess: (oId, payerId) {
                  _updateStatus(
                    "Native Checkout Success. Order: $oId, Payer: $payerId",
                  );
                  _updateResponse({"orderId": oId, "payerId": payerId});
                },
                onFailure: (oId, reason, code, correlationId) =>
                    _updateStatus("Native Checkout Failed: $reason"),
                onCancel: (oId) =>
                    _updateStatus("Native Checkout Canceled: $oId"),
                onError: (error) =>
                    _updateStatus("Native Checkout Error: $error"),
              );
            },
            child: const Text("Start Native Checkout"),
          ),
          const SizedBox(height: 10),
          if (_selectedIntent == OrderIntent.capture)
            ElevatedButton(
              onPressed: () {
                final orderId = _orderIdController.text;
                if (orderId.isEmpty) {
                  _updateStatus("Please enter an Order ID");
                  return;
                }
                _updateStatus("Capturing Order $orderId...");
                _formattedResponse = '';
                PaypalPayment.instance.orders.captureOrder(
                  orderId: orderId,
                  onSuccess: (res) {
                    _updateStatus("Capture Success: ${res.status}");
                    _updateResponse(res);
                  },
                  onError: (error) => _updateStatus("Capture Error: $error"),
                );
              },
              child: const Text("Capture Order"),
            ),
          if (_selectedIntent == OrderIntent.authorize)
            ElevatedButton(
              onPressed: () {
                final orderId = _orderIdController.text;
                if (orderId.isEmpty) {
                  _updateStatus("Please enter an Order ID");
                  return;
                }
                _updateStatus("Authorizing Order $orderId...");
                _formattedResponse = '';
                PaypalPayment.instance.orders.authorizeOrder(
                  orderId: orderId,
                  onSuccess: (res) {
                    _updateStatus("Authorization Success: ${res.status}");
                    _updateResponse(res);
                  },
                  onError: (error) =>
                      _updateStatus("Authorization Error: $error"),
                );
              },
              child: const Text("Authorize Order"),
            ),
          ResponseViewer(text: _formattedResponse),
        ],
      ),
    );
  }
}
