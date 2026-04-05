import 'dart:developer';
import 'package:flutter/foundation.dart';

class LogHelper {
  static void info(
    String message, {
    String category = 'APP',
  }) {
    log(message, name: '$category.INFO');
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String category = 'APP',
  }) {
    log(
      message,
      name: '$category.ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(
    String message, {
    String category = 'APP',
  }) {
    log(message, name: '$category.WARNING');
  }

  static void debug(
    String message, {
    String category = 'APP',
  }) {
    if (!kDebugMode) {
      return;
    }

    log(message, name: '$category.DEBUG');
  }
}
