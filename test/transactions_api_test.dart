import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paypal_payment/paypal_payment.dart';
import 'package:paypal_payment/src/network/paypal_http_service.dart';

void main() {
  group('TransactionsApi Tests', () {
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

    test('listTransactions success', () async {
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

        if (request.url.path == '/v1/reporting/transactions' &&
            request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'transaction_details': [
                {
                  'transaction_info': {
                    'transaction_id': 'TRANS-123',
                    'transaction_amount': {
                      'currency_code': 'USD',
                      'value': '10.00',
                    },
                  },
                },
              ],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      httpService.client = mockClient;

      await PaypalPayment.instance.transactions.listTransactions(
        startDate: DateTime.now().subtract(Duration(days: 1)),
        endDate: DateTime.now(),
        onSuccess: (response) {
          expect(
            response.transactionDetails.first.transactionInfo?.transactionId,
            'TRANS-123',
          );
          expect(
            response
                .transactionDetails
                .first
                .transactionInfo
                ?.transactionAmount
                ?.value,
            '10.00',
          );
        },
        onError: (err) => fail('Should not fail: $err'),
      );
    });
  });
}
