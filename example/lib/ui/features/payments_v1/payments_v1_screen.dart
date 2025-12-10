import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:paypal_payment/paypal_payment.dart';
import '../../common/response_viewer.dart';

class PaymentsV1Screen extends StatefulWidget {
  const PaymentsV1Screen({super.key});

  @override
  State<PaymentsV1Screen> createState() => _PaymentsV1ScreenState();
}

class _PaymentsV1ScreenState extends State<PaymentsV1Screen> {
  PaymentIntent _selectedIntent = PaymentIntent.sale;
  String _status = '';
  String _formattedResponse = '';
  final TextEditingController _paymentIdController = TextEditingController();
  final TextEditingController _payerIdController = TextEditingController();
  final TextEditingController _authIdController = TextEditingController();
  final TextEditingController _captionIdController = TextEditingController();
  final TextEditingController _saleIdController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();

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
          DropdownButtonFormField<PaymentIntent>(
            initialValue: _selectedIntent,
            decoration: const InputDecoration(
              labelText: "Payment Intent",
              border: OutlineInputBorder(),
            ),
            onChanged: (PaymentIntent? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedIntent = newValue;
                });
              }
            },
            items: PaymentIntent.values.map<DropdownMenuItem<PaymentIntent>>((
              PaymentIntent value,
            ) {
              return DropdownMenuItem<PaymentIntent>(
                value: value,
                child: Text(value.name.toUpperCase()),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            "Status: $_status",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _updateStatus("Creating Payment (V1)...");
              _formattedResponse = '';
              final redirectUrls = RedirectUrls(
                returnUrl: "https://example.com/return",
                cancelUrl: "https://example.com/cancel",
              );
              PaypalPayment.instance.payments.v1.createPayment(
                intent: _selectedIntent,
                payer: Payer(paymentMethod: "paypal"),
                transactions: [
                  Transaction(
                    amount: TransactionAmount(total: "10.0", currency: "USD"),
                    description: "Payment V1 Test",
                  ),
                ],
                redirectUrls: redirectUrls,
                onSuccess: (res) async {
                  _updateStatus("Payment Created: ${res.id}");
                  _updateResponse(res);

                  if (res.approvalLink != null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaypalCheckoutPage(
                          approvalUrl: res.approvalLink!.href!,
                          redirectUrls: redirectUrls,
                        ),
                      ),
                    );

                    if (result != null && result is Map) {
                      if (result["success"] == true) {
                        final queryParams =
                            result["queryParams"] as Map<String, String>;
                        final payerId = queryParams["PayerID"];
                        final paymentId = queryParams["paymentId"];

                        setState(() {
                          if (payerId != null) {
                            _payerIdController.text = payerId;
                          }
                          if (paymentId != null) {
                            _paymentIdController.text = paymentId;
                          }
                        });
                        _updateStatus("Payment Approved. Ready to Execute.");
                      } else {
                        _updateStatus("Payment Canceled.");
                      }
                    }
                  }
                },
                onError: (error) =>
                    _updateStatus("Create Payment Error: $error"),
              );
            },
            child: const Text("Create Payment"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _paymentIdController,
            decoration: const InputDecoration(
              labelText: "Payment ID",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _payerIdController,
            decoration: const InputDecoration(
              labelText: "Payer ID",
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final paymentId = _paymentIdController.text;
              final payerId = _payerIdController.text;
              if (paymentId.isEmpty) {
                _updateStatus("Payment ID is empty");
                return;
              }
              if (payerId.isEmpty) {
                _updateStatus("Payer ID is empty");
                return;
              }

              _updateStatus("Executing Payment $paymentId...");
              _formattedResponse = '';
              PaypalPayment.instance.payments.v1.executePayment(
                paymentId: paymentId,
                payerId: payerId,
                onSuccess: (res) {
                  _updateStatus("Payment Executed: ${res.id}");
                  _updateResponse(res);

                  // Auto-populate relevant ID fields based on intent
                  if (_selectedIntent == PaymentIntent.authorize) {
                    final authId = res
                        .transactions
                        .firstOrNull
                        ?.relatedResources
                        ?.firstOrNull
                        ?.authorization?['id'];
                    if (authId != null) {
                      setState(() => _authIdController.text = authId);
                    }
                  } else if (_selectedIntent == PaymentIntent.order) {
                    final orderId = res
                        .transactions
                        .firstOrNull
                        ?.relatedResources
                        ?.firstOrNull
                        ?.order?['id'];
                    if (orderId != null) {
                      setState(() => _orderIdController.text = orderId);
                    }
                  } else if (_selectedIntent == PaymentIntent.sale) {
                    final saleId = res
                        .transactions
                        .firstOrNull
                        ?.relatedResources
                        ?.firstOrNull
                        ?.sale?['id'];
                    if (saleId != null) {
                      setState(() => _saleIdController.text = saleId);
                    }
                  }
                },
                onError: (error) =>
                    _updateStatus("Execute Payment Error: $error"),
              );
            },
            child: const Text("Execute Payment"),
          ),
          if (_selectedIntent == PaymentIntent.authorize) ...[
            const Divider(),
            const Text("Authorizations (V1)"),
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
                      _updateStatus("Capturing Authorization $authId...");
                      _formattedResponse = '';
                      PaypalPayment.instance.payments.v1
                          .captureAuthorizedPayment(
                            authorizationId: authId,
                            amount: TransactionAmount(
                              currency: "USD",
                              total: "10.0",
                            ),
                            finalCapture: true,
                            onSuccess: (res) {
                              _updateStatus("Capture Success: ${res.id}");
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
                      _updateStatus("Voiding Authorization $authId...");
                      _formattedResponse = '';
                      PaypalPayment.instance.payments.v1.voidAuthorizedPayment(
                        authorizationId: authId,
                        onSuccess: (res) {
                          _updateStatus("Void Success: ${res.id}");
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
          ],
          if (_selectedIntent == PaymentIntent.order) ...[
            const Divider(),
            const Text("Orders (V1)"),
            TextField(
              controller: _orderIdController,
              decoration: const InputDecoration(
                labelText: "Order ID (Transaction)",
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final orderId = _orderIdController.text;
                if (orderId.isEmpty) return;
                _updateStatus("Capturing Order $orderId...");
                _formattedResponse = '';
                PaypalPayment.instance.payments.v1.captureOrderPayment(
                  orderId: orderId,
                  amount: TransactionAmount(currency: "USD", total: "10.0"),
                  onSuccess: (res) {
                    _updateStatus("Order Capture Success: ${res.id}");
                    _updateResponse(res);
                  },
                  onError: (error) =>
                      _updateStatus("Order Capture Error: $error"),
                );
              },
              child: const Text("Capture Order"),
            ),
          ],
          const Divider(),
          const Text("Refunds (V1)"),
          TextField(
            controller: _captionIdController,
            decoration: const InputDecoration(
              labelText: "Capture ID",
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final captureId = _captionIdController.text;
              if (captureId.isEmpty) return;
              _updateStatus("Refunding Capture $captureId...");
              _formattedResponse = '';
              PaypalPayment.instance.payments.v1.refundCapturedPayment(
                captureId: captureId,
                amount: TransactionAmount(currency: "USD", total: "10.0"),
                onSuccess: (res) {
                  _updateStatus("Refund Success: ${res.id}");
                  _updateResponse(res);
                },
                onError: (error) => _updateStatus("Refund Error: $error"),
              );
            },
            child: const Text("Refund Capture"),
          ),
          if (_selectedIntent == PaymentIntent.sale) ...[
            TextField(
              controller: _saleIdController,
              decoration: const InputDecoration(
                labelText: "Sale ID",
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final saleId = _saleIdController.text;
                if (saleId.isEmpty) return;
                _updateStatus("Refunding Sale $saleId...");
                _formattedResponse = '';
                PaypalPayment.instance.payments.v1.refundSale(
                  saleId: saleId,
                  amount: TransactionAmount(currency: "USD", total: "10.0"),
                  onSuccess: (res) {
                    _updateStatus("Refund Sale Success: ${res.id}");
                    _updateResponse(res);
                  },
                  onError: (error) =>
                      _updateStatus("Refund Sale Error: $error"),
                );
              },
              child: const Text("Refund Sale"),
            ),
          ],
          const Divider(),
          ElevatedButton(
            onPressed: () {
              final paymentId = _paymentIdController.text;
              if (paymentId.isEmpty) return;
              _updateStatus("Getting Payment Details $paymentId...");
              _formattedResponse = '';
              PaypalPayment.instance.payments.v1.getPaymentDetails(
                paymentId: paymentId,
                onSuccess: (res) {
                  _updateStatus("Got Details: ${res.id}");
                  _updateResponse(res);
                },
                onError: (error) => _updateStatus("Get Details Error: $error"),
              );
            },
            child: const Text("Get Payment Details"),
          ),
          ResponseViewer(text: _formattedResponse),
        ],
      ),
    );
  }
}
