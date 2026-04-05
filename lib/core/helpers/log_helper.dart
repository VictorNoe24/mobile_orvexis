import 'dart:developer';

class LogHelper {
  static void info(String message) {
    log(message, name: 'INFO');
  }

  static void error(String message, [Object? error]) {
    log(message, name: 'ERROR', error: error);
  }

  static void warning(String message) {
    log(message, name: 'WARNING');
  }
}