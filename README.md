# paypal_payment_flutter

[![Pub](https://img.shields.io/pub/v/naxalibre)](https://pub.dev/packages/paypal_payment_flutter)
[![License](https://img.shields.io/github/license/itheamc/naxalibre)](https://github.com/itheamc/paypal_payment/blob/main/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/itheamc/naxalibre.svg?style=social)](https://github.com/itheamc/paypal_payment)

## Overview

A comprehensive Flutter plugin for integrating PayPal payments into your Flutter application. This plugin supports both Android and iOS platforms and provides access to PayPal's Orders API, Payments API (v1 & v2), Transactions API, and Checkout flows.

## Features

- ✅ **Orders API**: Create, capture, and authorize orders
- ✅ **Payments API V1**: Create, execute, capture, void, and refund payments
- ✅ **Payments API V2**: Capture, void, and refund authorized payments
- ✅ **Transactions API**: List and search transaction history
- ✅ **Checkout API**: Simplified checkout flows with native WebView integration
- ✅ **Manual Flows**: Build custom checkout experiences without using Checkout API

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  paypal_payment_flutter: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Setup

### 1. Get PayPal Credentials

1. Go to [PayPal Developer Dashboard](https://developer.paypal.com/dashboard/)
2. Create a new app or select an existing one
3. Copy your **Client ID** and **Secret**
4. Use **Sandbox** credentials for testing, **Live** credentials for production

### 2. Create .env File

Create a `.env` file in the root of your Flutter project:

```env
PAYPAL_CLIENT_ID=your_client_id_here
PAYPAL_CLIENT_SECRET=your_client_secret_here
```

**Example:**
```env
PAYPAL_CLIENT_ID=AX9HZkDVbFQDVyOQBO_t8oLscdNk9YTeXQ8lnKBoE0ns7Z_YTH70qPR0njSHge2QjqcNS3IkP3kxPB0b
PAYPAL_CLIENT_SECRET=EEpm782H_lewazmVlIlotj-3W8YNeEYXKFAmHYJk-4M9bsE1uC5Ptv8K6862Oc0MowwknHXg4_kb4bQX
```

> **Important:** Add `.env` to your `.gitignore` file to keep your credentials secure:
> ```
> # .gitignore
> .env
> ```

### 3. Add .env to Assets

Update your `pubspec.yaml` to include the `.env` file as an asset:

```yaml
flutter:
  assets:
    - .env
```

### 4. Initialize PayPal

Initialize the PayPal plugin in your app's main function or before using any PayPal APIs:

```dart
import 'package:paypal_payment_flutter/paypal_payment_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize PayPal
  // By default it will be initialize with sandbox environment
  await PaypalPayment.instance.initialize();
  
  // For production, use:
  // await PaypalPayment.instance.initialize(Environment.production);
  
  runApp(MyApp());
}
```

The `initialize()` method automatically:
- Loads environment variables from the `.env` file
- Retrieves `PAYPAL_CLIENT_ID` and `PAYPAL_CLIENT_SECRET`
- Configures the HTTP service with your credentials
- Initializes the native PayPal SDK on Android and iOS

**Note:** The plugin uses a custom environment variable loader that reads from the `.env` file. No additional packages like `flutter_dotenv` are required.

## API Usage

### Orders API

The Orders API allows you to create and manage orders for checkout flows.

#### Create an Order

```dart
import 'package:paypal_payment_flutter/paypal_payment_flutter.dart';

Future<void> createOrder() async {
  
  await PaypalPayment.instance.orders.createOrder(
    intent: OrderIntent.capture,
    purchaseUnits: [
      PurchaseUnit(
        referenceId: 'default',
        amount: Amount(
          currencyCode: 'USD',
          value: '100.00',
        ),
      ),
    ],
    onInitiated: () {
      print('Order creation Initiated');
    },
    onSuccess: (response) {
      print('Order created: ${response.id}');
      print('Status: ${response.status}');
      // Extract approval URL for manual checkout
      final approvalUrl = response.links
          ?.firstWhere((link) => link.rel == 'approve')
          .href;
      print('Approval URL: $approvalUrl');
    },
    onError: (error) {
      print('Error creating order: $error');
    },
  );
  
}
```

#### Capture an Order

```dart
Future<void> captureOrder(String orderId) async {
  
  await PaypalPayment.instance.orders.captureOrder(
    orderId: orderId,
    onInitiated: () {
      print('Capture Initiated');
    },
    onSuccess: (response) {
      print('Order captured: ${response.id}');
      print('Status: ${response.status}');
    },
    onError: (error) {
      print('Error capturing order: $error');
    },
  );
  
}
```

#### Authorize an Order

```dart
Future<void> authorizeOrder(String orderId) async {
  
  await PaypalPayment.instance.orders.authorizeOrder(
    orderId: orderId,
    onInitiated: () {
      print('Authorization Initiated');
    },
    onSuccess: (response) {
      print('Order authorized: ${response.id}');
    },
    onError: (error) {
      print('Error authorizing order: $error');
    },
  );
  
}
```

### Payments API V1

The Payments API V1 provides comprehensive payment management capabilities.

#### Create a Payment

```dart
Future<void> createPayment() async {
  
  await PaypalPayment.instance.payments.v1.createPayment(
    intent: PaymentIntent.sale,
    payer: Payer(paymentMethod: "paypal"),
    transactions: [
      Transaction(
        amount: TransactionAmount(
          total: "10.00",
          currency: "USD",
        ),
        description: "Payment for services",
      ),
    ],
    redirectUrls: RedirectUrls(
      returnUrl: "https://yourapp.com/return",
      cancelUrl: "https://yourapp.com/cancel",
    ),
    onInitiated: () {
      print('Create Payment Initiated');
    },
    onSuccess: (response) {
      print('Payment created: ${response.id}');
      // Get approval URL
      final approvalUrl = response.links
          ?.firstWhere((link) => link.rel == 'approval_url')
          .href;
      print('Approval URL: $approvalUrl');
    },
    onError: (error) {
      print('Error: $error');
    },
  );
  
}
```

#### Execute a Payment

After user approves the payment, execute it:

```dart
Future<void> executePayment(String paymentId, String payerId) async {
  
  await PaypalPayment.instance.payments.v1.executePayment(
    paymentId: paymentId,
    payerId: payerId,
    onInitiated: () {
      print('Executed Initiated');
    },
    onSuccess: (response) {
      print('Payment executed: ${response.id}');
      print('State: ${response.state}');
    },
    onError: (error) {
      print('Error: $error');
    },
  );
  
}
```

#### Capture Authorized Payment

```dart
Future<void> captureAuthorizedPayment(String authorizationId) async {
  
  await PaypalPayment.instance.payments.v1.captureAuthorizedPayment(
    authorizationId: authorizationId,
    amount: TransactionAmount(
      total: "10.00",
      currency: "USD",
    ),
    onInitiated: () {
      print('Capture initiated');
    },
    onSuccess: (response) {
      print('Payment captured: ${response.id}');
    },
    onError: (error) {
      print('Error: $error');
    },
  );
  
}
```

#### Void Authorized Payment

```dart
Future<void> voidAuthorizedPayment(String authorizationId) async {
  
  await PaypalPayment.instance.payments.v1.voidAuthorizedPayment(
    authorizationId: authorizationId,
    onInitiated: () {
      print('Void Initiated');
    },
    onSuccess: (response) {
      print('Authorization voided: ${response.id}');
    },
    onError: (error) {
      print('Error: $error');
    },
  );
  
}
```

#### Refund a Payment

```dart
Future<void> refundCapturedPayment(String captureId) async {
  
  await PaypalPayment.instance.payments.v1.refundCapturedPayment(
    captureId: captureId,
    amount: TransactionAmount(
      total: "5.00",
      currency: "USD",
    ),
    onInitiated: () {
      print('Refund Initiated');
    },
    onSuccess: (response) {
      print('Refund processed: ${response.id}');
    },
    onError: (error) {
      print('Error: $error');
    },
  );
  
}
```

#### Get Payment Details

```dart
Future<void> getPaymentDetails(String paymentId) async {
  
  await PaypalPayment.instance.payments.v1.getPaymentDetails(
    paymentId: paymentId,
    onInitiated: () {
      print('Payment Details Request Initiated');
    },
    onSuccess: (response) {
      print('Payment ID: ${response.id}');
      print('State: ${response.state}');
    },
    onError: (error) {
      print('Error: $error');
    },
  );
  
}
```

### Payments API V2

The Payments API V2 provides modern payment authorization and capture flows.

#### Capture Authorized Payment (V2)

```dart
Future<void> captureAuthorizedPaymentV2(String authorizationId) async {
  
  await PaypalPayment.instance.payments.v2.captureAuthorizedPayment(
    authorizationId: authorizationId,
    amount: Amount(
      currencyCode: "USD",
      value: "10.00",
    ),
    onInitiated: () {
      print('Capture Authorization Initiated');
    },
    onSuccess: (response) {
      print('Payment captured: ${response.id}');
      print('Status: ${response.status}');
    },
    onError: (error) {
      print('Error: $error');
    },
  );
  
}
```

#### Void Authorized Payment (V2)

```dart
Future<void> voidAuthorizedPaymentV2(String authorizationId) async {
  
  await PaypalPayment.instance.payments.v2.voidAuthorizedPayment(
    authorizationId: authorizationId,
    onInitiated: () {
      print('Void Authorization Initiated');
    },
    onSuccess: (response) {
      print('Authorization voided: ${response.id}');
    },
    onError: (error) {
      print('Error: $error');
    },
  );
  
}
```

#### Refund Captured Payment (V2)

```dart
Future<void> refundCapturedPaymentV2(String captureId) async {
  
  await PaypalPayment.instance.payments.v2.refundCapturedPayment(
    captureId: captureId,
    amount: Amount(
      currencyCode: "USD",
      value: "5.00",
    ),
    onInitiated: () {
      print('Refund Capture Payment Initiated');
    },
    onSuccess: (response) {
      print('Refund processed: ${response.id}');
    },
    onError: (error) {
      print('Error: $error');
    },
  );
  
}
```

### Transactions API

List and search transaction history.

```dart
Future<void> listTransactions() async {
  
  final startDate = DateTime.now().subtract(Duration(days: 30));
  final endDate = DateTime.now();

  await PaypalPayment.instance.transactions.listTransactions(
    startDate: startDate,
    endDate: endDate,
    onInitiated: () {
      print('Loading Initiated');
    },
    onSuccess: (response) {
      print('Total transactions: ${response.transactionDetails?.length}');
      response.transactionDetails?.forEach((transaction) {
        print('Transaction ID: ${transaction.transactionInfo?.transactionId}');
        print('Amount: ${transaction.transactionInfo?.transactionAmount?.value}');
      });
    },
    onError: (error) {
      print('Error: $error');
    },
  );
  
}
```

### Checkout API

The Checkout API provides simplified payment flows with built-in WebView integration.

#### Checkout with Order

```dart
Future<void> checkoutWithOrder(BuildContext context) async {
  
  await PaypalPayment.instance.checkout.checkoutOrder(
    intent: OrderIntent.capture,
    purchaseUnits: [
      PurchaseUnit(
        referenceId: 'default',
        amount: Amount(
          currencyCode: 'USD',
          value: '100.00',
        ),
      ),
    ],
    onInitiated: () {
      print('Order Checkout Process Initiated');
    },
    onSuccess: (orderId) {
      print('Order completed: $orderId');
      // Order is automatically captured
    },
    onError: (error) {
      print('Checkout error: $error');
    },
  );
  
}
```

#### Checkout with Payment (V1)

```dart
Future<void> checkoutWithPayment(BuildContext context) async {
  
  await PaypalPayment.instance.checkout.checkoutPayment(
    context,
    intent: PaymentIntent.sale,
    payer: Payer(paymentMethod: "paypal"),
    transactions: [
      Transaction(
        amount: TransactionAmount(
          total: "10.00",
          currency: "USD",
        ),
        description: "Payment for services",
      ),
    ],
    redirectUrls: RedirectUrls(
      returnUrl: "https://yourapp.com/return",
      cancelUrl: "https://yourapp.com/cancel",
    ),
    onInitiated: () {
      print('Payment Checkout Process Initiated');
    },
    onSuccess: (paymentId) {
      print('Payment completed: $paymentId');
      // Payment is automatically executed
    },
    onError: (error) {
      print('Checkout error: $error');
    },
  );
  
}

```

## Manual Checkout Flow (Without Checkout API)

If you prefer to build a custom checkout experience without using the Checkout API, you can manually handle the flow:

### Option 1: Manual Order Flow

```dart
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:paypal_payment_flutter/paypal_payment_flutter.dart';

class ManualOrderCheckout extends StatefulWidget {
  @override
  _ManualOrderCheckoutState createState() => _ManualOrderCheckoutState();
}

class _ManualOrderCheckoutState extends State<ManualOrderCheckout> {
  String? orderId;
  String? approvalUrl;

  // Step 1: Create the order
  Future<void> createOrder() async {
    await PaypalPayment.instance.orders.createOrder(
      intent: OrderIntent.capture,
      purchaseUnits: [
        PurchaseUnit(
          referenceId: 'default',
          amount: Amount(
            currencyCode: 'USD',
            value: '100.00',
          ),
        ),
      ],
      onSuccess: (response) {
        setState(() {
          orderId = response.id;
          // Extract approval URL
          approvalUrl = response.links
              ?.firstWhere((link) => link.rel == 'approve')
              .href;
        });
        
        // Step 2: Open approval URL in your custom WebView or browser
        if (approvalUrl != null) {
          openApprovalUrl(approvalUrl!);
        }
      },
      onError: (error) {
        print('Error: $error');
      },
    );
  }

  // Step 2: Open approval URL
  void openApprovalUrl(String url) {
    // Option A: Use WebView
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWebView(
          url: url,
          onApproved: () {
            // Step 3: Capture the order after approval
            captureOrder();
          },
        ),
      ),
    );

    // Option B: Use external browser
    // launchUrl(Uri.parse(url));
  }

  // Step 3: Capture the order
  Future<void> captureOrder() async {
    if (orderId == null) return;

    await PaypalPayment.instance.orders.captureOrder(
      orderId: orderId!,
      onSuccess: (response) {
        print('Order captured successfully!');
        print('Capture ID: ${response.id}');
        // Handle success
      },
      onError: (error) {
        print('Capture error: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manual Checkout')),
      body: Center(
        child: ElevatedButton(
          onPressed: createOrder,
          child: Text('Pay with PayPal'),
        ),
      ),
    );
  }
}

// Custom WebView widget
class CustomWebView extends StatelessWidget {
  final String url;
  final VoidCallback onApproved;

  const CustomWebView({
    required this.url,
    required this.onApproved,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PayPal Checkout')),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onUrlChange: (change) {
                // Monitor URL changes to detect approval
                if (change.url?.contains('yourapp.com/return') ?? false) {
                  Navigator.pop(context);
                  onApproved();
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(url)),
      ),
    );
  }
}
```

### Option 2: Manual Payment Flow (V1)

```dart
class ManualPaymentCheckout extends StatefulWidget {
  @override
  _ManualPaymentCheckoutState createState() => _ManualPaymentCheckoutState();
}

class _ManualPaymentCheckoutState extends State<ManualPaymentCheckout> {
  String? paymentId;
  String? approvalUrl;

  // Step 1: Create payment
  Future<void> createPayment() async {
    await PaypalPayment.instance.payments.v1.createPayment(
      intent: PaymentIntent.sale,
      payer: Payer(paymentMethod: "paypal"),
      transactions: [
        Transaction(
          amount: TransactionAmount(
            total: "10.00",
            currency: "USD",
          ),
        ),
      ],
      redirectUrls: RedirectUrls(
        returnUrl: "https://yourapp.com/return",
        cancelUrl: "https://yourapp.com/cancel",
      ),
      onSuccess: (response) {
        setState(() {
          paymentId = response.id;
          approvalUrl = response.links
              ?.firstWhere((link) => link.rel == 'approval_url')
              .href;
        });

        if (approvalUrl != null) {
          openApprovalUrl(approvalUrl!);
        }
      },
      onError: (error) {
        print('Error: $error');
      },
    );
  }

  // Step 2: Open approval URL (similar to above)
  void openApprovalUrl(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWebView(
          url: url,
          onApproved: (Uri returnUri) {
            // Extract PayerID from return URL
            final payerId = returnUri.queryParameters['PayerID'];
            if (payerId != null) {
              executePayment(payerId);
            }
          },
        ),
      ),
    );
  }

  // Step 3: Execute payment
  Future<void> executePayment(String payerId) async {
    if (paymentId == null) return;

    await PaypalPayment.instance.payments.v1.executePayment(
      paymentId: paymentId!,
      payerId: payerId,
      onSuccess: (response) {
        print('Payment executed successfully!');
        // Handle success
      },
      onError: (error) {
        print('Execution error: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manual Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: createPayment,
          child: Text('Pay with PayPal'),
        ),
      ),
    );
  }
}
```

## Complete Example

See the [example](example/) directory for a complete working application demonstrating all APIs.

## Platform Support

| Platform | Support |
|----------|---------|
| Android  | ✅      |
| iOS      | ✅      |
| Web      | ❌      |
| macOS    | ❌      |
| Windows  | ❌      |
| Linux    | ❌      |

## Requirements

- Flutter SDK: >=3.3.0
- Dart SDK: ^3.10.0
- Android: minSdkVersion 21
- iOS: 14.0+ (Required by the latest Paypal iOS SDK)

## Testing

The plugin includes comprehensive unit and widget tests. Run tests with:

```bash
flutter test
```

## Additional Resources

- [PayPal Developer Documentation](https://developer.paypal.com/docs/)
- [PayPal REST API Reference](https://developer.paypal.com/api/rest/)
- [PayPal Sandbox Testing](https://developer.paypal.com/tools/sandbox/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/itheamc/paypal_payment_flutter).
