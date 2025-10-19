import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import 'log_service.dart';

/// Расширенный сервис для логирования ошибок и исключений
/// Предоставляет детальное логирование для отладки
class ErrorLogService {
  ErrorLogService._();

  /// Логирование исключений с полной информацией
  static void logException(
    Object exception, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    if (!AppConstants.enableLogging) return;

    final buffer = StringBuffer();
    
    if (context != null) {
      buffer.writeln('Context: $context');
    }
    
    buffer.writeln('Exception: $exception');
    
    if (stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace.toString());
    }
    
    if (additionalData != null && additionalData.isNotEmpty) {
      buffer.writeln('Additional Data:');
      additionalData.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    }

    LogService.e(buffer.toString());
  }

  /// Логирование ошибок сети
  static void logNetworkError(
    String method,
    String url,
    Object error, {
    int? statusCode,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
  }) {
    if (!AppConstants.enableLogging) return;

    final buffer = StringBuffer();
    buffer.writeln('Network Error Details:');
    buffer.writeln('Method: $method');
    buffer.writeln('URL: $url');
    buffer.writeln('Error: $error');
    
    if (statusCode != null) {
      buffer.writeln('Status Code: $statusCode');
    }
    
    if (requestData != null) {
      buffer.writeln('Request Data: $requestData');
    }
    
    if (responseData != null) {
      buffer.writeln('Response Data: $responseData');
    }

    LogService.e(buffer.toString());
  }

  /// Логирование ошибок валидации
  static void logValidationError(
    String field,
    String value,
    String rule, {
    Map<String, dynamic>? context,
  }) {
    if (!AppConstants.enableLogging) return;

    final buffer = StringBuffer();
    buffer.writeln('Validation Error:');
    buffer.writeln('Field: $field');
    buffer.writeln('Value: $value');
    buffer.writeln('Rule: $rule');
    
    if (context != null) {
      buffer.writeln('Context: $context');
    }

    LogService.w(buffer.toString());
  }

  /// Логирование ошибок базы данных
  static void logDatabaseError(
    String operation,
    String table,
    Object error, {
    Map<String, dynamic>? queryData,
  }) {
    if (!AppConstants.enableLogging) return;

    final buffer = StringBuffer();
    buffer.writeln('Database Error:');
    buffer.writeln('Operation: $operation');
    buffer.writeln('Table: $table');
    buffer.writeln('Error: $error');
    
    if (queryData != null) {
      buffer.writeln('Query Data: $queryData');
    }

    LogService.e(buffer.toString());
  }

  /// Логирование ошибок аутентификации
  static void logAuthError(
    String operation,
    Object error, {
    String? userId,
    Map<String, dynamic>? context,
  }) {
    if (!AppConstants.enableLogging) return;

    final buffer = StringBuffer();
    buffer.writeln('Authentication Error:');
    buffer.writeln('Operation: $operation');
    buffer.writeln('Error: $error');
    
    if (userId != null) {
      buffer.writeln('User ID: $userId');
    }
    
    if (context != null) {
      buffer.writeln('Context: $context');
    }

    LogService.e(buffer.toString());
  }

  /// Логирование критических ошибок
  static void logCriticalError(
    String component,
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    if (!AppConstants.enableLogging) return;

    final buffer = StringBuffer();
    buffer.writeln('🚨 CRITICAL ERROR 🚨');
    buffer.writeln('Component: $component');
    buffer.writeln('Error: $error');
    
    if (stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace.toString());
    }
    
    if (context != null) {
      buffer.writeln('Context: $context');
    }

    LogService.f(buffer.toString());
    
    // В production можно отправить в crash reporting сервис
    if (AppConstants.enableCrashReporting && !kDebugMode) {
      _sendToCrashReporting(error, stackTrace, context);
    }
  }

  /// Отправка ошибок в crash reporting сервис
  static void _sendToCrashReporting(
    Object error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ) {
    // Здесь можно интегрировать с Firebase Crashlytics, Sentry и т.д.
    LogService.i('Sending error to crash reporting service');
  }

  /// Логирование производительности
  static void logPerformanceIssue(
    String operation,
    Duration duration,
    Duration threshold, {
    Map<String, dynamic>? context,
  }) {
    if (!AppConstants.enableLogging) return;

    if (duration > threshold) {
      final buffer = StringBuffer();
      buffer.writeln('Performance Issue:');
      buffer.writeln('Operation: $operation');
      buffer.writeln('Duration: ${duration.inMilliseconds}ms');
      buffer.writeln('Threshold: ${threshold.inMilliseconds}ms');
      
      if (context != null) {
        buffer.writeln('Context: $context');
      }

      LogService.w(buffer.toString());
    }
  }

  /// Логирование с тегами для фильтрации
  static void logWithTag(
    String tag,
    String message, {
    Level level = Level.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!AppConstants.enableLogging) return;

    final taggedMessage = '[$tag] $message';
    
    switch (level) {
      case Level.debug:
        LogService.d(taggedMessage, error, stackTrace);
        break;
      case Level.info:
        LogService.i(taggedMessage, error, stackTrace);
        break;
      case Level.warning:
        LogService.w(taggedMessage, error, stackTrace);
        break;
      case Level.error:
        LogService.e(taggedMessage, error, stackTrace);
        break;
      case Level.fatal:
        LogService.f(taggedMessage, error, stackTrace);
        break;
      default:
        LogService.i(taggedMessage, error, stackTrace);
        break;
    }
  }
}
