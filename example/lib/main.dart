import 'package:flutter/material.dart';
import 'ui/features/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const PaypalPaymentExampleApp());
}

class PaypalPaymentExampleApp extends StatelessWidget {
  const PaypalPaymentExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      title: "Paypal Payment Example",
    );
  }
}
