import 'package:http/http.dart';

/// A service interface for handling HTTP requests, including various methods
/// to send HTTP requests such as GET, POST, PUT, PATCH, DELETE, and download.
abstract class HttpService {
  /// The base URL for HTTP requests.
  /// This URL is the root endpoint for all the requests in the service.
  String? get baseUrl;

  /// The headers that should be included in the HTTP request.
  /// Typically includes authentication tokens, content type, etc.
  Map<String, String> get headers;

  /// Sends a GET request to the given [endpoint].
  ///
  /// [endpoint] - The URL path to append to [baseUrl] for the request.
  /// [queryParameters] - Optional parameters to include in the URL query string.
  /// [isAuthenticated] - Flag indicating if authentication is required (default is true).
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
  });

  /// Sends a POST request to the given [endpoint] with [formData].
  ///
  /// [endpoint] - The URL path to append to [baseUrl] for the request.
  /// [payload] - Data to send in the body of the POST request.
  /// [queryParameters] - Optional parameters to include in the URL query string.
  /// [contentType] - Specifies the content type of the request (default is [ContentType.formData]).
  /// [isAuthenticated] - Flag indicating if authentication is required (default is false).
  Future<Response> post(
    String endpoint,
    Map<String, dynamic> payload, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = false,
  });

  /// Sends a PUT request to the given [endpoint] with [formData].
  ///
  /// [endpoint] - The URL path to append to [baseUrl] for the request.
  /// [payload] - Data to send in the body of the PUT request.
  /// [queryParameters] - Optional parameters to include in the URL query string.
  /// [isAuthenticated] - Flag indicating if authentication is required (default is true).
  /// [contentType] - Specifies the content type of the request (default is [ContentType.json]).
  /// [cancelToken] - Token to cancel the request before completion.
  Future<Response> put(
    String endpoint,
    Map<String, dynamic> payload, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
  });

  /// Sends a PATCH request to the given [endpoint] with [formData].
  ///
  /// [endpoint] - The URL path to append to [baseUrl] for the request.
  /// [payload] - Data to send in the body of the PATCH request.
  /// [queryParameters] - Optional parameters to include in the URL query string.
  /// [isAuthenticated] - Flag indicating if authentication is required (default is true).
  /// [contentType] - Specifies the content type of the request (default is [ContentType.json]).
  /// [cancelToken] - Token to cancel the request before completion.
  Future<Response> patch(
    String endpoint,
    Map<String, dynamic> payload, {
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = true,
  });

  /// Sends a DELETE request to the given [endpoint] with optional [formData].
  ///
  /// [endpoint] - The URL path to append to [baseUrl] for the request.
  /// [payload] - Optional data to send in the body of the DELETE request.
  /// [queryParameters] - Optional parameters to include in the URL query string.
  /// [isAuthenticated] - Flag indicating if authentication is required (default is false).
  /// [contentType] - Specifies the content type of the request (default is [ContentType.json]).
  /// [cancelToken] - Token to cancel the request before completion.
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? payload,
    Map<String, dynamic>? queryParameters,
    bool isAuthenticated = false,
  });
}
