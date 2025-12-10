import 'dart:convert';

import '../../utils/logger.dart';
import '../../utils/extension_functions.dart';
import '../../network/http_exception.dart';
import '../../network/http_response_validator.dart';
import '../../network/paypal_http_service.dart';
import 'models/responses/transactions_list_response.dart';

/// Manages operations related to PayPal transactions.
///
/// This class provides methods to search and retrieve transaction history.
/// It follows the singleton pattern to ensure a single, consistent instance
/// throughout the application. Access the instance via `TransactionsApi.instance`.
///
class TransactionsApi {
  /// An instance of [PaypalHttpService] to handle network requests.
  ///
  /// This service is responsible for all HTTP communication with the PayPal API.
  ///
  final PaypalHttpService _httpService;

  /// A private constructor to prevent direct instantiation from outside the class.
  ///
  /// This is a core part of the singleton pattern implementation and initializes
  /// the required [_httpService] instance.
  ///
  TransactionsApi._() : _httpService = PaypalHttpService.instance;

  /// The internal, static instance of the [TransactionsApi] class.
  ///
  static TransactionsApi? _instance;

  /// Provides a lazy-loaded singleton instance of the [TransactionsApi] class.
  ///
  /// The first time this getter is accessed, it creates and initializes a new
  /// instance. On subsequent accesses, it returns the already created instance,
  /// ensuring that only one object of this type exists in the application.
  ///
  static TransactionsApi get instance {
    if (_instance == null) {
      Logger.logMessage("TransactionsApi is initialized!");
    }
    _instance ??= TransactionsApi._();
    return _instance!;
  }

  /// Lists transactions based on specified query parameters.
  /// https://developer.paypal.com/docs/api/transaction-search/v1/#transactions_get
  ///
  /// Use this method to search for and retrieve details of multiple transactions.
  /// All parameters are optional and are used to filter the results.
  ///
  /// [startDate] The start date and time for the search, in UTC.
  /// [endDate] The end date and time for the search, in UTC.
  /// [transactionId] The PayPal-generated transaction ID.
  /// [transactionType] The type of transaction.
  /// [transactionStatus] The status of the transaction, e.g., 'S' for successful.
  /// [transactionAmount] The amount of the transaction.
  /// [transactionCurrency] The ISO-4217 currency code of the transaction.
  /// [paymentInstrumentType] The payment instrument type used for the transaction.
  /// [storeId] The ID of the store where the transaction occurred.
  /// [terminalId] The ID of the terminal for a POS transaction.
  /// [fields] The fields to include in the response, can be 'all' or a comma-separated list.
  /// [balanceAffectingRecordsOnly] Whether to include only transactions that affect the balance.
  /// [pageSize] The number of items to return in a single page of results.
  /// [page] The page number to retrieve.
  /// [onInitiated] A callback that fires when the request is initiated.
  /// [onSuccess] A callback that fires with the list of transactions upon success.
  /// [onError] A callback that fires when an error occurs.
  Future<void> listTransactions({
    required DateTime startDate,
    required DateTime endDate,
    String? transactionId,
    String? transactionType,
    String? transactionStatus,
    String? transactionAmount,
    String? transactionCurrency,
    String? paymentInstrumentType,
    String? storeId,
    String? terminalId,
    String fields = 'all',
    bool balanceAffectingRecordsOnly = true,
    int pageSize = 100,
    int page = 1,
    void Function()? onInitiated,
    void Function(String endpoint, Map<String, dynamic> queryParameters)?
    onPreRequest,
    void Function(TransactionsListResponse)? onSuccess,
    void Function(String? error)? onError,
  }) async {
    try {
      onInitiated?.call();

      final queryParameters = <String, dynamic>{
        'transaction_id': transactionId,
        'transaction_type': transactionType,
        'transaction_status': transactionStatus,
        'transaction_amount': transactionAmount,
        'transaction_currency': transactionCurrency,
        'start_date': startDate.formattedUtcIsoString,
        'end_date': endDate.formattedUtcIsoString,
        'payment_instrument_type': paymentInstrumentType,
        'store_id': storeId,
        'terminal_id': terminalId,
        'fields': fields,
        'balance_affecting_records_only': balanceAffectingRecordsOnly
            ? 'Y'
            : 'N',
        'page_size': pageSize.toString(),
        'page': page.toString(),
      }.filterNotNull();

      final endpoint = '/v1/reporting/transactions';

      onPreRequest?.call(endpoint, queryParameters);

      final response = await _httpService.get(
        endpoint,
        queryParameters: queryParameters,
        isAuthenticated: true,
      );

      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        onSuccess?.call(TransactionsListResponse.fromJson(decoded));
        return;
      }

      onError?.call(HttpException.fromResponse(response).message);
    } on HttpException catch (e) {
      onError?.call(e.message);
    } catch (e) {
      onError?.call(e.toString());
    }
  }
}
