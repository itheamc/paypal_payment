import 'package:http/http.dart';

/// A utility class to validate HTTP responses.
class ResponseValidator {
  /// Validates whether the given [response] is successful.
  ///
  /// This method checks if the response contains non-null data and the status code
  /// is one of the standard successful HTTP codes: 200, 201, 202, 203, or 204.
  /// Logs a success message if the response is valid.
  ///
  /// [response] - The HTTP [Response] object to validate.
  ///
  /// Returns `true` if the response is valid, otherwise `false`.
  static bool isValidResponse(Response response) {
    final bool isSuccessStatusCode = [
      200,
      201,
      202,
      203,
      204,
    ].contains(response.statusCode);

    return (response.body.startsWith("{") || response.body.startsWith("[")) &&
        isSuccessStatusCode;
  }
}
