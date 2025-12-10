import 'package:flutter/material.dart';
import 'package:paypal_payment/paypal_payment.dart';


void main() {
  // Ensure that all necessary platform bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PaypalHomeScreen(), // Use the new widget here
    );
  }
}

class PaypalHomeScreen extends StatefulWidget {
  const PaypalHomeScreen({super.key});

  @override
  State<PaypalHomeScreen> createState() => _PaypalHomeScreenState();
}

class _PaypalHomeScreenState extends State<PaypalHomeScreen> {
  @override
  void initState() {
    super.initState();
    PaypalPayment.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          spacing: 12.0,
          children: [
            ElevatedButton(
              onPressed: () async {
                // await PaypalPayment.instance.orders.createOrder(
                //   intent: .capture,
                //   purchaseUnits: [
                //     PurchaseUnit(
                //       referenceId: "test-product-123",
                //       amount: Amount(currencyCode: "USD", value: "5.0"),
                //     ),
                //
                //     PurchaseUnit(
                //       referenceId: "test-product-456",
                //       amount: Amount(currencyCode: "USD", value: "7.0"),
                //     ),
                //   ],
                //   onSuccess: (res) async {
                //     final id = res.id;
                //     final approveUrl = res.approvalLink?.href;
                //     if (id == null || approveUrl == null) return;
                //
                //     print(res.toJson());
                //
                //
                //     PaypalPayment.instance.orders.startNativeCheckout(
                //       orderId: id,
                //       onSuccess: (orderId, payerId) {
                //         print("""
                //     OrderId: $orderId,
                //     PayerId: $payerId,
                //     """);
                //       },
                //       onFailure: (orderId, reason, code, correlationId) {
                //         print("""
                //     OrderId: $orderId,
                //     Reason: $reason,
                //     Code: $code,
                //     CorrelationId: $correlationId,
                //     """);
                //       },
                //       onCancel: (orderId) {
                //         print("""
                //     OrderId: $orderId,
                //     """);
                //       },
                //       onError: (error) {
                //         print("""
                //     Error: $error,
                //     """);
                //       },
                //     );
                //   },
                //   onError: (res) {
                //     print("Error :$res");
                //   },
                // );

                await PaypalPayment.instance.checkout.checkoutOrder(
                  intent: .capture,
                  purchaseUnits: [
                    PurchaseUnit(
                      referenceId: "test-product-123",
                      amount: Amount(currencyCode: "USD", value: "5.0"),
                    ),

                    PurchaseUnit(
                      referenceId: "test-product-456",
                      amount: Amount(currencyCode: "USD", value: "7.0"),
                    ),
                  ],
                  onError: (error) {
                    print("Error :$error");
                  },
                  onSuccess: (orderId) {
                    print("Success :$orderId");
                  },
                );
              },
              child: Text("Create Order"),
            ),
            ElevatedButton(
              onPressed: () {
                PaypalPayment.instance.checkout.checkoutPayment(
                  context,
                  intent: .authorize,
                  payer: Payer(paymentMethod: "paypal"),
                  transactions: [
                    Transaction(
                      amount: TransactionAmount(
                        total: "5.00",
                        currency: "AUD",
                        details: Details(
                          subtotal: "5.0",
                          shipping: "0.0",
                          shippingDiscount: "0.0",
                        ),
                      ),
                      description: "This is test product",
                      itemList: ItemList(
                        items: [
                          Item(
                            name: "Test Item",
                            quantity: "1",
                            price: "5.0",
                            currency: "AUD",
                            description: "This is test item",
                          ),
                        ],
                        shippingAddress: ShippingAddress(
                          recipientName: "John Doe",
                          line1: "123 Main St",
                          city: 'Kathmandu',
                          state: 'Bagmati',
                          phone: '9809809809',
                          postalCode: '22400',
                          countryCode: 'NP',
                        ),
                      ),
                    ),
                  ],
                  redirectUrls: RedirectUrls(
                    returnUrl: "https://itheamc.com/return",
                    cancelUrl: "https://itheamc.com/cancel",
                  ),
                  onSuccess: (paymentId) {
                    print("Success :$paymentId");
                  },
                  onError: (res) {
                    print("Error :$res");
                  },
                );
              },
              child: Text("Create Payment"),
            ),
            ElevatedButton(
              onPressed: () {
                PaypalPayment.instance.transactions.listTransactions(
                  startDate: DateTime.now().subtract(Duration(days: 30)),
                  endDate: DateTime.now(),
                  onPreRequest: (endpoint, query) {
                    print("Endpoint :$endpoint");
                    print("Query :$query");
                  },
                  onError: (e) {
                    print("Error :$e");
                  },
                  onSuccess: (res) {
                    print("Success :${res.toJson()}");
                  },
                );
              },
              child: Text('Fetch Transactions'),
            ),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                // Fully customizable style
                backgroundColor: const Color(0xFF003087), // PayPal Blue
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.payment, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Pay with PayPal',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
