import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paypal_payment_flutter/paypal_payment_flutter.dart';
import 'service/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cart = CartService();
  bool _isProcessing = false;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.paypal;

  // Card form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController(text: 'US');

  @override
  void initState() {
    super.initState();
    _cart.addListener(_update);
  }

  @override
  void dispose() {
    _cart.removeListener(_update);
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  Future<void> _processPayPalCheckout() async {
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

    print("Starting PayPal checkout with total: ${_cart.totalAmount}");

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
        _showSuccessDialog(orderId);
      },
      onError: (error) {
        print("Order Error: $error");
        setState(() {
          _isProcessing = false;
        });
        _showErrorSnackBar('PayPal Checkout Failed: $error');
      },
    );
  }

  Future<void> _processCardCheckout() async {
    // Validate card form
    if (!_validateCardForm()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Parse expiry date (MM/YY format)
    final expiryParts = _expiryController.text.split('/');
    final expiryMonth = expiryParts[0].trim();
    final expiryYear = '20${expiryParts[1].trim()}';

    final cardDetail = CardDetail(
      number: _cardNumberController.text.replaceAll(' ', ''),
      expirationMonth: expiryMonth,
      expirationYear: expiryYear,
      securityCode: _cvvController.text,
      cardholderName: _nameController.text,
      billingAddress: BillingAddress(
        countryCode: _countryController.text,
        streetAddress: _streetController.text.isEmpty
            ? null
            : _streetController.text,
        locality: _cityController.text.isEmpty ? null : _cityController.text,
        region: _stateController.text.isEmpty ? null : _stateController.text,
        postalCode: _zipController.text.isEmpty ? null : _zipController.text,
      ),
    );

    final purchaseUnits = [
      PurchaseUnit(
        referenceId: "cart-${DateTime.now().millisecondsSinceEpoch}",
        amount: Amount(
          currencyCode: "USD",
          value: _cart.totalAmount.toStringAsFixed(2),
        ),
      ),
    ];

    print("Starting card checkout with total: ${_cart.totalAmount}");

    await PaypalPayment.instance.checkout.checkoutOrderWithCard(
      intent: OrderIntent.capture,
      purchaseUnits: purchaseUnits,
      cardDetail: cardDetail,
      sca: SCA.whenRequired,
      onInitiated: () {
        print("Card Checkout Initiated");
      },
      onSuccess: (orderId) {
        print("Card Payment Success: $orderId");
        setState(() {
          _isProcessing = false;
        });
        _cart.clear();
        _showSuccessDialog(orderId);
      },
      onError: (error) {
        print("Card Payment Error: $error");
        setState(() {
          _isProcessing = false;
        });
        _showErrorSnackBar('Card Payment Failed: $error');
      },
    );
  }

  bool _validateCardForm() {
    if (_cardNumberController.text.replaceAll(' ', '').length < 13) {
      _showErrorSnackBar('Please enter a valid card number');
      return false;
    }
    if (!_expiryController.text.contains('/') ||
        _expiryController.text.length < 5) {
      _showErrorSnackBar('Please enter expiry date in MM/YY format');
      return false;
    }
    if (_cvvController.text.length < 3) {
      _showErrorSnackBar('Please enter a valid CVV');
      return false;
    }
    if (_nameController.text.isEmpty) {
      _showErrorSnackBar('Please enter cardholder name');
      return false;
    }
    if (_countryController.text.length != 2) {
      _showErrorSnackBar('Please enter a valid 2-letter country code');
      return false;
    }
    return true;
  }

  void _showSuccessDialog(String orderId) {
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
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          // Total and checkout button
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
                ],
              ),
            ),
          ),

          // Payment method selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Method',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioGroup<PaymentMethod>(
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        child: RadioListTile<PaymentMethod>(
                          title: const Text('PayPal'),
                          value: PaymentMethod.paypal,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RadioGroup<PaymentMethod>(
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        child: RadioListTile<PaymentMethod>(
                          title: const Text('Card'),
                          value: PaymentMethod.card,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Card form (shown only when card is selected)
          if (_selectedPaymentMethod == PaymentMethod.card)
            Padding(
              padding: const EdgeInsets.all(15),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Card Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cardNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Card Number',
                          hintText: '4111 1111 1111 1111',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          _CardNumberFormatter(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _expiryController,
                              decoration: const InputDecoration(
                                labelText: 'Expiry',
                                hintText: 'MM/YY',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                _ExpiryDateFormatter(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _cvvController,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Cardholder Name',
                          hintText: 'John Doe',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _streetController,
                        decoration: const InputDecoration(
                          labelText: 'Street Address (Optional)',
                          hintText: '123 Main St',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City (Optional)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _stateController,
                              decoration: const InputDecoration(
                                labelText: 'State (Optional)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _zipController,
                              decoration: const InputDecoration(
                                labelText: 'ZIP (Optional)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _countryController,
                              decoration: const InputDecoration(
                                labelText: 'Country Code',
                                hintText: 'US',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Checkout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: double.infinity,
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: (_cart.totalAmount <= 0)
                          ? null
                          : _selectedPaymentMethod == PaymentMethod.paypal
                          ? _processPayPalCheckout
                          : _processCardCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedPaymentMethod == PaymentMethod.paypal
                            ? const Color(0xFF003087) // PayPal Blue
                            : const Color(0xFF0070BA), // Card Blue
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _selectedPaymentMethod == PaymentMethod.paypal
                            ? "Pay with PayPal"
                            : "Pay with Card",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),

          // Cart items list
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

enum PaymentMethod { paypal, card }

// Card number formatter to add spaces every 4 digits
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Expiry date formatter to add slash after MM
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length >= 2 && !text.contains('/')) {
      final month = text.substring(0, 2);
      final year = text.substring(2);
      final formatted = '$month/$year';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    return newValue;
  }
}
