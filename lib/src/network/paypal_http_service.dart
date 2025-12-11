import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';
import 'http_response_validator.dart';
import 'http_exception.dart';
import 'http_service.dart';
import '../config/paypal_configuration.dart';

/// A concrete implementation of [HttpService] for interacting with PayPal APIs.
///
/// This service provides GET, POST, PUT, PATCH, and DELETE HTTP methods,
/// including automatic handling of PayPal OAuth2 authentication when required.
///
/// It is implemented as a lazy-loaded singleton and depends on a global
/// [PaypalConfiguration] instance to resolve environment URLs and credentials.
class PaypalHttpService implements HttpService {
  /// Private internal constructor to prevent direct instantiation.
  ///
  PaypalHttpService._();

  /// Holds the PayPal configuration, including environment and credentials.
  ///
  /// Must be initialized before making any authenticated requests.
  ///
  PaypalConfiguration? configuration;

  /// Base url of the api request
  ///
  @override
  String? get baseUrl => configuration?.environment.baseUrl;

  /// Internal singleton instance of [PaypalHttpService].
  ///
  static PaypalHttpService? _instance;

  /// Returns the lazily initialized instance of this service.
  ///
  /// Logs initialization the first time this getter is called.
  ///
  static PaypalHttpService get instance {
    if (_instance == null) {
      Logger.logMessage("PaypalHttpService is initialized!");
    }
    _instance ??= PaypalHttpService._();
    return _instance!;
  }

  /// Default HTTP headers applied to all requests.
  ///
  /// Authentication headers will be added dynamically when needed.
  ///
  @override
  Map<String, String> headers = {
    'accept': 'application/json',
    'content-type': 'application/json',
  };

  /// Internal HTTP client used for making requests.
  ///
  http.Client _client = http.Client();

  /// Allows overriding the internal HTTP client for testing purposes.
  ///
  @visibleForTesting
  set client(http.Client client) => _client = client;

  /// Sends an HTTP GET request.
  ///
  /// [endpoint] – Relative endpoint path.
  /// [queryParameters] – Optional parameters appended to the URL.
  /// [isAuthenticated] – Whether to include PayPal OAuth2 headers.
  ///
  /// Throws [HttpException] when configuration is missing or request fails.
  ///
  @override
  Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = false,
  }) async {
    try {
      final uri = Uri.parse(
        baseUrl! + endpoint,
      ).replace(queryParameters: queryParameters);

      final updatedHeaders = {
        ...headers,
        ...(await _getAuthHeaders(isAuthenticated)),
      };

      return await _client.get(uri, headers: updatedHeaders);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sends an HTTP POST request with a JSON-encoded payload.
  ///
  /// Throws [HttpException] on failure.
  @override
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> payload, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = false,
  }) async {
    try {
      final uri = Uri.parse(
        baseUrl! + endpoint,
      ).replace(queryParameters: queryParameters);

      final updatedHeaders = {
        ...headers,
        ...(await _getAuthHeaders(isAuthenticated)),
      };

      return await _client.post(
        uri,
        headers: updatedHeaders,
        body: jsonEncode(payload),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sends an HTTP PUT request with a JSON-encoded payload.
  ///
  /// Typically used for full resource updates.
  @override
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> payload, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = false,
  }) async {
    try {
      final uri = Uri.parse(
        baseUrl! + endpoint,
      ).replace(queryParameters: queryParameters);

      final updatedHeaders = {
        ...headers,
        ...(await _getAuthHeaders(isAuthenticated)),
      };

      return await _client.put(
        uri,
        headers: updatedHeaders,
        body: jsonEncode(payload),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sends an HTTP PATCH request with a JSON-encoded payload.
  ///
  /// Used for partial updates. Defaults to authenticated requests.
  @override
  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> payload, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
  }) async {
    try {
      final uri = Uri.parse(
        baseUrl! + endpoint,
      ).replace(queryParameters: queryParameters);

      final updatedHeaders = {
        ...headers,
        ...(await _getAuthHeaders(isAuthenticated)),
      };

      return await _client.patch(
        uri,
        headers: updatedHeaders,
        body: jsonEncode(payload),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sends an HTTP DELETE request.
  ///
  /// Supports an optional JSON payload (for APIs that allow bodies in DELETE calls).
  @override
  Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? payload,
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
  }) async {
    try {
      final uri = Uri.parse(
        baseUrl! + endpoint,
      ).replace(queryParameters: queryParameters);

      final updatedHeaders = {
        ...headers,
        ...(await _getAuthHeaders(isAuthenticated)),
      };

      if (payload == null) {
        return await _client.delete(uri, headers: updatedHeaders);
      }

      return await _client.delete(
        uri,
        headers: updatedHeaders,
        body: jsonEncode(payload),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generates authentication headers using PayPal OAuth2 credentials.
  ///
  /// Returns an empty map if:
  /// - the request does not require authentication
  /// - authentication fails
  ///
  /// Makes an internal POST request to `/v1/oauth2/token` to obtain the access token.
  Future<Map<String, String>> _getAuthHeaders(bool isAuthenticated) async {
    try {
      if (!isAuthenticated) return {};

      final authToken = base64.encode(
        utf8.encode(
          "${configuration?.clientId}:${configuration?.clientSecret}",
        ),
      );

      // Endpoint to get the authorization token
      final endpoint = '/v1/oauth2/token?grant_type=client_credentials';

      // Headers for the request
      final headers = {
        'Authorization': 'Basic $authToken',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      // Creating the uri to make the request
      final uri = Uri.parse(baseUrl! + endpoint);

      // Making the get request
      final response = await _client.post(uri, headers: headers);

      // If response is valid then process the response body and return the
      // authorization headers with the token
      if (ResponseValidator.isValidResponse(response)) {
        final decoded = jsonDecode(response.body);
        return {
          "Authorization":
              "${decoded['token_type']} ${decoded['access_token']}",
        };
      }

      return {};
    } catch (_) {
      return {};
    }
  }

  /// Converts caught exceptions into standardized [HttpException] objects.
  ///
  /// If the base URL is missing, this indicates that `PaypalConfiguration`
  /// was never initialized.
  HttpException _handleError(dynamic e) {
    return HttpException(
      title: "Http Error!",
      statusCode: 500,
      message: baseUrl == null
          ? "PaypalPayment is not initialized!"
          : e.toString(),
    );
  }
}
