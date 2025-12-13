import 'package:flutter/foundation.dart';

/// A simple logger class for printing messages to the console.
/// This class provides static methods for logging different types of messages,
/// each with a unique visual indicator.
class Logger {
  /// Logs a success message.
  /// The message is prefixed and suffixed with checkmark emojis (✅✅✅).
  ///
  /// [message]: The message to be logged. It will be converted to a string.
  static void logSuccess(dynamic message) {
    debugPrint('✅✅✅ ${message?.toString()} ✅✅✅');
  }

  /// Logs an error message.
  /// The message is prefixed and suffixed with cross emojis (❌❌❌).
  ///
  /// [message]: The message to be logged. It will be converted to a string.
  static void logError(dynamic message) {
    debugPrint('❌❌❌ ${message?.toString()} ❌❌❌');
  }

  /// Logs a warning message.
  /// The message is prefixed and suffixed with warning emojis (⚠️⚠️⚠️).
  ///
  /// [message]: The message to be logged. It will be converted to a string.
  static void logWarning(dynamic message) {
    debugPrint('⚠️⚠️⚠️ ${message?.toString()} ⚠️⚠️⚠️');
  }

  /// Logs a general-purpose message.
  /// The message is prefixed with right arrows and suffixed with left arrows (➡️➡️➡️ ... ⬅️⬅️⬅️).
  ///
  /// [message]: The message to be logged. It will be converted to a string.
  static void logMessage(dynamic message) {
    debugPrint('➡️➡️➡️ ${message?.toString()} ⬅️⬅️⬅️');
  }

  /// Logs a raw message without any special formatting or emojis.
  /// If the message is already a string, it's printed directly.
  /// Otherwise, it's converted to a string before printing.
  ///
  /// [message]: The message to be logged.
  static void logRaw(dynamic message) {
    debugPrint(message is String ? message : '${message?.toString()}');
  }
}
