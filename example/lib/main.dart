import 'package:flutter/material.dart';
import 'package:paypal_payment_flutter/paypal_payment_flutter.dart';
import 'ui/features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PaypalPayment.instance.initialize();

  runApp(const PaypalPaymentExampleApp());
}

class PaypalPaymentExampleApp extends StatelessWidget {
  const PaypalPaymentExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      title: "Paypal Payment Flutter Example",
    );
  }
}
