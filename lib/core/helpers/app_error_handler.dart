import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'log_helper.dart';

class AppErrorHandler {
  const AppErrorHandler._();

  static Future<void> run(FutureOr<void> Function() appRunner) async {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      LogHelper.error(
        'Flutter framework error',
        category: 'FLUTTER',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      LogHelper.error(
        'Uncaught platform error',
        category: 'PLATFORM',
        error: error,
        stackTrace: stackTrace,
      );
      return true;
    };

    ErrorWidget.builder = (details) {
      LogHelper.error(
        'Widget build error',
        category: 'WIDGET',
        error: details.exception,
        stackTrace: details.stack,
      );

      if (!kDebugMode) {
        return const Material(
          child: Center(
            child: Text('Something went wrong'),
          ),
        );
      }

      return Material(
        color: const Color(0xFFFFF1F0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              details.exceptionAsString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB42318),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    };

    await runZonedGuarded(
      () async {
        await appRunner();
      },
      (error, stackTrace) {
        LogHelper.error(
          'Uncaught asynchronous error',
          category: 'ZONE',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }
}
