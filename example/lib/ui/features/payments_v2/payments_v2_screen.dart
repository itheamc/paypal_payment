import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:paypal_payment_flutter/paypal_payment_flutter.dart';
import '../../common/response_viewer.dart';

class PaymentsV2Screen extends StatefulWidget {
  const PaymentsV2Screen({super.key});

  @override
  State<PaymentsV2Screen> createState() => _PaymentsV2ScreenState();
}

class _PaymentsV2ScreenState extends State<PaymentsV2Screen> {
  String _status = '';
  String _formattedResponse = '';
  final TextEditingController _authIdController = TextEditingController();
  final TextEditingController _captureIdController = TextEditingController();

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
          const Text("Authorizations (V2)"),
          TextField(
            controller: _authIdController,
            decoration: const InputDecoration(
              labelText: "Authorization ID",
              border: OutlineInputBorder(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final authId = _authIdController.text;
                    if (authId.isEmpty) return;
                    _updateStatus("Capturing Authorization $authId (V2)...");
                    _formattedResponse = '';
                    PaypalPayment.instance.payments.v2.captureAuthorizedPayment(
                      authorizationId: authId,
                      amount: Amount(currencyCode: "USD", value: "10.0"),
                      // V2 often requires simpler payload or just ID depending on plugin impl
                      onSuccess: (res) {
                        _updateStatus("Capture Success: ${res.status}");
                        _updateResponse(res);
                      },
                      onError: (error) =>
                          _updateStatus("Capture Error: $error"),
                    );
                  },
                  child: const Text("Capture"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final authId = _authIdController.text;
                    if (authId.isEmpty) return;
                    _updateStatus("Voiding Authorization $authId (V2)...");
                    _formattedResponse = '';
                    PaypalPayment.instance.payments.v2.voidAuthorizedPayment(
                      authorizationId: authId,
                      onSuccess: (res) {
                        _updateStatus("Void Success: ${res.status}");
                        _updateResponse(res);
                      },
                      onError: (error) => _updateStatus("Void Error: $error"),
                    );
                  },
                  child: const Text("Void"),
                ),
              ),
            ],
          ),
          const Divider(),
          const Text("Refunds (V2)"),
          TextField(
            controller: _captureIdController,
            decoration: const InputDecoration(
              labelText: "Capture ID",
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final captureId = _captureIdController.text;
              if (captureId.isEmpty) return;
              _updateStatus("Refunding Capture $captureId (V2)...");
              _formattedResponse = '';
              PaypalPayment.instance.payments.v2.refundCapturedPayment(
                captureId: captureId,
                amount: Amount(currencyCode: "USD", value: "10.0"),
                onSuccess: (res) {
                  _updateStatus("Refund Success: ${res.status}");
                  _updateResponse(res);
                },
                onError: (error) => _updateStatus("Refund Error: $error"),
              );
            },
            child: const Text("Refund Capture"),
          ),
          ResponseViewer(text: _formattedResponse),
        ],
      ),
    );
  }
}
