import 'package:flutter/material.dart';
import 'package:paypal_payment/paypal_payment.dart';
import '../checkout_api/checkout_screen.dart';
import '../orders_api/orders_screen.dart';
import '../payments_v1/payments_v1_screen.dart';
import '../payments_v2/payments_v2_screen.dart';
import '../transactions_api/transactions_screen.dart';
import '../ecommerce/product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    PaypalPayment.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PayPal Plugin Example'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Ecommerce"),
              Tab(text: "Checkout"),
              Tab(text: "Orders"),
              Tab(text: "Payments V1"),
              Tab(text: "Payments V2"),
              Tab(text: "Transactions"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProductListScreen(),
            CheckoutScreen(),
            OrdersScreen(),
            PaymentsV1Screen(),
            PaymentsV2Screen(),
            TransactionsScreen(),
          ],
        ),
      ),
    );
  }
}
