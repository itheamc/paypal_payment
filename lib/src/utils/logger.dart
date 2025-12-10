import 'package:flutter/foundation.dart';

class Logger {
  static void logSuccess(dynamic message) {
    debugPrint('✅✅✅ ${message?.toString()} ✅✅✅');
  }

  static void logError(dynamic message) {
    debugPrint('❌❌❌ ${message?.toString()} ❌❌❌');
  }

  static void logWarning(dynamic message) {
    debugPrint('⚠️⚠️⚠️ ${message?.toString()} ⚠️⚠️⚠️');
  }

  static void logMessage(dynamic message) {
    debugPrint('➡️➡️➡️ ${message?.toString()} ⬅️⬅️⬅️');
  }

  static void logRaw(dynamic message) {
    debugPrint(message is String ? message : '${message?.toString()}');
  }
}
