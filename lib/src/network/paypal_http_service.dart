import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';
import 'http_response_validator.dart';
import 'http_exception.dart';
import 'http_service.dart';
import '../config/paypal_configuration.dart';

class PaypalHttpService implements HttpService {
  /// Private internal constructor
  ///
  PaypalHttpService._();

  /// PaypalConfiguration Instance
  ///
  PaypalConfiguration? configuration;

  @override
  String? get baseUrl => configuration?.environment.baseUrl;

  /// Private instance of PaypalHttpService
  ///
  static PaypalHttpService? _instance;

  /// Lazy-loaded singleton instance of this class
  ///
  static PaypalHttpService get instance {
    if (_instance == null) {
      Logger.logMessage("PaypalHttpService is initialized!");
    }
    _instance ??= PaypalHttpService._();
    return _instance!;
  }

  @override
  Map<String, String> headers = {
    'accept': 'application/json',
    'content-type': 'application/json',
  };

  final http.Client _client = http.Client();

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

      final response = await _client.get(uri, headers: updatedHeaders);

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

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

      final response = await _client.post(
        uri,
        headers: updatedHeaders,
        body: jsonEncode(payload),
      );

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

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

      final response = await _client.put(
        uri,
        headers: updatedHeaders,
        body: jsonEncode(payload),
      );

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

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

      final response = await _client.patch(
        uri,
        headers: updatedHeaders,
        body: jsonEncode(payload),
      );

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

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

      final response = await _client.delete(
        uri,
        headers: updatedHeaders,
        body: jsonEncode(payload),
      );

      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, String>> _getAuthHeaders(bool isAuthenticated) async {
    try {
      // If not authenticated api just return the empty map
      if (!isAuthenticated) return <String, String>{};

      // Base64 encode the client id and secret to get the secret auth token
      var authToken = base64.encode(
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

        final token = decoded['access_token'];
        final type = decoded['token_type'];

        return <String, String>{"Authorization": "$type $token"};
      }

      return <String, String>{};
    } catch (e) {
      return <String, String>{};
    }
  }

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
