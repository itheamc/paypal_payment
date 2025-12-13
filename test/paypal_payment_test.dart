import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:paypal_payment_flutter/paypal_payment_flutter.dart';
import 'package:paypal_payment_flutter/src/network/paypal_http_service.dart';

import 'package:http/testing.dart';

void main() {
  group('PaymentsApiV1 Tests', () {
    late PaypalHttpService httpService;

    setUp(() {
      httpService = PaypalHttpService.instance;
      final config = PaypalConfiguration(
        clientId: 'test_client_id',
        clientSecret: 'test_client_secret',
        environment: Environment.sandbox,
      );
      httpService.configuration = config;
    });

    test('createPayment success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/oauth2/token')) {
          return http.Response(
            jsonEncode({
              'access_token': 'fake_access_token',
              'token_type': 'Bearer',
              'expires_in': 3600,
            }),
            200,
          );
        }

        if (request.url.path == '/v1/payments/payment' &&
            request.method == 'POST') {
          final body = jsonDecode(request.body);
          if (body['intent'] == 'sale') {
            return http.Response(
              jsonEncode({
                'id': 'PAY-12345',
                'intent': 'sale',
                'state': 'created',
                'links': [
                  {
                    'href': 'https://approval.url',
                    'rel': 'approval_url',
                    'method': 'REDIRECT',
                  },
                ],
              }),
              201,
            );
          }
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.payments.v1.createPayment(
        intent: PaymentIntent.sale,
        payer: Payer(paymentMethod: "paypal"),
        transactions: [
          Transaction(
            amount: TransactionAmount(total: "10.00", currency: "USD"),
          ),
        ],
        redirectUrls: RedirectUrls(
          returnUrl: "return.com",
          cancelUrl: "cancel.com",
        ),
        onSuccess: (response) {
          expect(response.id, 'PAY-12345');
          expect(response.state, 'created');
          expect(response.approvalLink?.href, 'https://approval.url');
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });

    test('executePayment success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/oauth2/token')) {
          return http.Response(
            jsonEncode({
              'access_token': 'fake_access_token',
              'token_type': 'Bearer',
              'expires_in': 3600,
            }),
            200,
          );
        }

        if (request.url.path == '/v1/payments/payment/PAY-12345/execute' &&
            request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'id': 'PAY-12345',
              'state': 'approved',
              'transactions': [
                {
                  'related_resources': [
                    {
                      'sale': {'id': 'SALE-123', 'state': 'completed'},
                    },
                  ],
                },
              ],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.payments.v1.executePayment(
        paymentId: 'PAY-12345',
        payerId: 'PAYER-987',
        onSuccess: (response) {
          expect(response.id, 'PAY-12345');
          expect(response.state, 'approved');
          expect(
            response.transactions.first.relatedResources?.first.sale?['id'],
            'SALE-123',
          );
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });
    test('captureAuthorizedPayment success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/oauth2/token')) {
          return http.Response(
            jsonEncode({
              'access_token': 'fake_access_token',
              'token_type': 'Bearer',
              'expires_in': 3600,
            }),
            200,
          );
        }

        if (request.url.path == '/v1/payments/authorization/AUTH-123/capture' &&
            request.method == 'POST') {
          return http.Response(
            jsonEncode({'id': 'CAP-123', 'state': 'completed'}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.payments.v1.captureAuthorizedPayment(
        authorizationId: 'AUTH-123',
        amount: TransactionAmount(total: "10.00", currency: "USD"),
        onSuccess: (response) {
          expect(response.id, 'CAP-123');
          expect(response.state, 'completed');
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });

    test('voidAuthorizedPayment success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/oauth2/token')) {
          return http.Response(
            jsonEncode({
              'access_token': 'fake_access_token',
              'token_type': 'Bearer',
              'expires_in': 3600,
            }),
            200,
          );
        }

        if (request.url.path == '/v1/payments/authorization/AUTH-123/void' &&
            request.method == 'POST') {
          return http.Response(
            jsonEncode({'id': 'AUTH-123', 'state': 'voided'}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.payments.v1.voidAuthorizedPayment(
        authorizationId: 'AUTH-123',
        onSuccess: (response) {
          expect(response.id, 'AUTH-123');
          expect(response.state, 'voided');
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });

    test('captureOrderPayment success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/oauth2/token')) {
          return http.Response(
            jsonEncode({
              'access_token': 'fake_access_token',
              'token_type': 'Bearer',
              'expires_in': 3600,
            }),
            200,
          );
        }

        if (request.url.path == '/v1/payments/orders/ORDER-123/capture' &&
            request.method == 'POST') {
          return http.Response(
            jsonEncode({'id': 'CAP-123', 'state': 'completed'}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.payments.v1.captureOrderPayment(
        orderId: 'ORDER-123',
        amount: TransactionAmount(total: "10.00", currency: "USD"),
        onSuccess: (response) {
          expect(response.id, 'CAP-123');
          expect(response.state, 'completed');
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });

    test('refundCapturedPayment success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/oauth2/token')) {
          return http.Response(
            jsonEncode({
              'access_token': 'fake_access_token',
              'token_type': 'Bearer',
              'expires_in': 3600,
            }),
            200,
          );
        }

        if (request.url.path == '/v1/payments/capture/CAP-123/refund' &&
            request.method == 'POST') {
          return http.Response(
            jsonEncode({'id': 'REFUND-123', 'state': 'completed'}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.payments.v1.refundCapturedPayment(
        captureId: 'CAP-123',
        amount: TransactionAmount(total: "5.00", currency: "USD"),
        onSuccess: (response) {
          expect(response.id, 'REFUND-123');
          expect(response.state, 'completed');
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });

    test('refundSale success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/oauth2/token')) {
          return http.Response(
            jsonEncode({
              'access_token': 'fake_access_token',
              'token_type': 'Bearer',
              'expires_in': 3600,
            }),
            200,
          );
        }

        if (request.url.path == '/v1/payments/sale/SALE-123/refund' &&
            request.method == 'POST') {
          return http.Response(
            jsonEncode({'id': 'REFUND-SALE-123', 'state': 'completed'}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.payments.v1.refundSale(
        saleId: 'SALE-123',
        amount: TransactionAmount(total: "5.00", currency: "USD"),
        onSuccess: (response) {
          expect(response.id, 'REFUND-SALE-123');
          expect(response.state, 'completed');
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });

    test('getPaymentDetails success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/v1/oauth2/token')) {
          return http.Response(
            jsonEncode({
              'access_token': 'fake_access_token',
              'token_type': 'Bearer',
              'expires_in': 3600,
            }),
            200,
          );
        }

        if (request.url.path == '/v1/payments/payment/PAY-123' &&
            request.method == 'GET') {
          return http.Response(
            jsonEncode({'id': 'PAY-123', 'state': 'approved'}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.payments.v1.getPaymentDetails(
        paymentId: 'PAY-123',
        onSuccess: (response) {
          expect(response.id, 'PAY-123');
          expect(response.state, 'approved');
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });
  });
}
