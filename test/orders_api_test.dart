import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paypal_payment/paypal_payment.dart';
import 'package:paypal_payment/src/network/paypal_http_service.dart';

void main() {
  group('OrdersApi Tests', () {
    late PaypalHttpService httpService;

    setUp(() {
      httpService = PaypalHttpService.instance;
      final config = PaypalConfiguration(
        clientId: 'test_client_id',
        clientSecret: 'test_client_secret',
        environment: .sandbox,
      );
      httpService.configuration = config;
    });

    /// Test for createOrder
    ///
    test('createOrder success', () async {
      // Creating mock http client and the
      // Dummy response for oauth and createOrder to simulate the testing
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

        if (request.url.path == '/v2/checkout/orders' &&
            request.method == 'POST') {
          final body = jsonDecode(request.body);
          if (body['intent'] == 'CAPTURE') {
            return http.Response(
              jsonEncode({
                'id': 'ORDER-12345',
                'status': 'CREATED',
                'links': [
                  {'href': 'https://approve', 'rel': 'approve'},
                ],
              }),
              201,
            );
          }
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.orders.createOrder(
        intent: OrderIntent.capture,
        purchaseUnits: [
          PurchaseUnit(
            referenceId: 'ref_123',
            amount: Amount(currencyCode: "USD", value: "15.00"),
          ),
        ],
        onSuccess: (response) {
          expect(response.id, 'ORDER-12345');
          expect(response.status, OrderCreateStatus.created);
          expect(response.links.firstOrNull?.href, 'https://approve');
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });

    /// Test for captureOrder
    ///
    test('captureOrder success', () async {
      // Creating mock http client and the dummy response same as createOrder test
      // for oauth and captureOrder to simulate the testing

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

        if (request.url.path == '/v2/checkout/orders/ORDER-12345/capture' &&
            request.method == 'POST') {
          return http.Response(
            jsonEncode({'id': 'ORDER-12345', 'status': 'COMPLETED'}),
            201,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.orders.captureOrder(
        orderId: 'ORDER-12345',
        onSuccess: (response) {
          expect(response.id, 'ORDER-12345');
          expect(response.status, 'COMPLETED');
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });
    test('authorizeOrder success', () async {
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

        if (request.url.path == '/v2/checkout/orders/ORDER-12345/authorize' &&
            request.method == 'POST') {
          return http.Response(
            jsonEncode({'id': 'AUTH-12345', 'status': 'COMPLETED'}),
            201,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.orders.authorizeOrder(
        orderId: 'ORDER-12345',
        onSuccess: (response) {
          expect(response.status, 'COMPLETED');
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });
  });
}
