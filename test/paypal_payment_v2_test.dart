import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paypal_payment/paypal_payment.dart';
import 'package:paypal_payment/src/network/paypal_http_service.dart';

void main() {
  group('PaymentsApiV2 Tests', () {
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

        if (request.url.path ==
                '/v2/payments/authorizations/AUTH-123/capture' &&
            request.method == 'POST') {
          return http.Response(
            jsonEncode({'id': 'CAP-123', 'status': 'COMPLETED'}),
            201,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.payments.v2.captureAuthorizedPayment(
        authorizationId: 'AUTH-123',
        amount: Amount(currencyCode: "USD", value: "10.00"),
        onSuccess: (response) {
          expect(response.id, 'CAP-123');
          expect(response.status, 'COMPLETED');
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

        if (request.url.path == '/v2/payments/authorizations/AUTH-123/void' &&
            request.method == 'POST') {
          return http.Response(
            jsonEncode({'id': 'AUTH-123', 'status': 'VOIDED'}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.payments.v2.voidAuthorizedPayment(
        authorizationId: 'AUTH-123',
        onSuccess: (response) {
          expect(response.status, 'VOIDED');
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

        if (request.url.path == '/v2/payments/captures/CAP-123/refund' &&
            request.method == 'POST') {
          return http.Response(
            jsonEncode({'id': 'REFUND-123', 'status': 'COMPLETED'}),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.payments.v2.refundCapturedPayment(
        captureId: 'CAP-123',
        amount: Amount(currencyCode: "USD", value: "5.00"),
        onSuccess: (response) {
          expect(response.id, 'REFUND-123');
          expect(response.status, 'COMPLETED');
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });
  });
}
