import 'dart:convert';
import 'package:http/http.dart';

/// Custom exception used with HTTP requests.
///
class HttpException implements Exception {
  /// Creates a new instance of [HttpException].
  ///
  /// [title] - The title of the exception (optional).
  /// [message] - A detailed message about the exception (optional).
  /// [statusCode] - The HTTP response status code associated with the exception (optional).
  ///
  HttpException({this.title, this.message, this.statusCode});

  /// The title of the exception, providing a brief description.
  ///
  final String? title;

  /// The detailed message associated with the exception.
  ///
  final String? message;

  /// The HTTP status code returned by the server (if available).
  ///
  final int? statusCode;

  /// Creates an [HttpException] from an HTTP [Response].
  ///
  /// [response] - The response object returned by Dio.
  /// Attempts to extract a message from the response data or falls back to the status message.
  ///
  static HttpException fromResponse(Response response) => HttpException(
    title: 'Data Response Error',
    statusCode: response.statusCode,
    message: _extractMessageFromResponse(response),
  );

  /// Creates an [HttpException] from a Dio [Exception].
  ///
  /// [error] - The error object thrown by Dio, typically a [DioException].
  /// If the error is a DioException, it is captured; otherwise, a generic exception message is provided.
  ///
  static HttpException fromException(dynamic error) => HttpException(
    statusCode: 502,
    title: 'Exception',
    message: 'Unable to handle your request',
  );

  /// Helper method to extract the message from the [Response] object.
  ///
  /// This method tries to extract a meaningful error message from common response fields like
  /// `message`, `details`, `error`, etc., with fallbacks to ensure some message is provided.
  ///
  static String? _extractMessageFromResponse(Response response) {
    try {
      final body = response.body;

      final parsed = body.startsWith("{") || body.startsWith("[")
          ? jsonDecode(body)
          : null;

      if (parsed != null) {
        return parsed['message'] ??
            parsed['Message'] ??
            parsed['details'] ??
            parsed['detail'] ??
            parsed['error'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'HttpException{title: $title, message: $message, statusCode: $statusCode';
  }
}
