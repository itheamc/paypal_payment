import 'package:flutter/material.dart';
import 'package:paypal_payment/paypal_payment.dart';
import 'service/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cart = CartService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cart.addListener(_update);
  }

  @override
  void dispose() {
    _cart.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  Future<void> _processCheckout() async {
    setState(() {
      _isProcessing = true;
    });

    final purchaseUnits = [
      PurchaseUnit(
        referenceId: "cart-${DateTime.now().millisecondsSinceEpoch}",
        amount: Amount(
          currencyCode: "USD",
          value: _cart.totalAmount.toStringAsFixed(2),
        ),
      ),
    ];

    print("Starting checkout with total: ${_cart.totalAmount}");

    await PaypalPayment.instance.checkout.checkoutOrder(
      intent: OrderIntent.capture,
      purchaseUnits: purchaseUnits,
      onInitiated: () {
        print("Checkout Initiated");
      },
      onSuccess: (orderId) {
        print("Order Success: $orderId");
        setState(() {
          _isProcessing = false;
        });
        _cart.clear();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Order Successful!'),
            content: Text('Thank you for your order.\nOrder ID: $orderId'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to store
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      },
      onError: (error) {
        print("Order Error: $error");
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Checkout Failed: $error')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${_cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).primaryTextTheme.titleLarge?.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 10),
                  if (_isProcessing)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: (_cart.totalAmount <= 0)
                          ? null
                          : _processCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003087), // PayPal Blue
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Pay with PayPal"),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _cart.items.length,
              itemBuilder: (ctx, i) {
                final item = _cart.items.values.toList()[i];
                return Dismissible(
                  key: ValueKey(item.product.id),
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _cart.removeItem(item.product.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 4,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: FittedBox(
                              child: Text(item.product.imageEmoji),
                            ),
                          ),
                        ),
                        title: Text(item.product.name),
                        subtitle: Text(
                          'Total: \$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        ),
                        trailing: Text('${item.quantity} x'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
