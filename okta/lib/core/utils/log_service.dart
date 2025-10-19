import 'package:logger/logger.dart';

import '../constants/app_constants.dart';

/// Центральный сервис логирования для всего приложения
/// Предоставляет единый интерфейс для логирования с настройками
class LogService {
  LogService._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: false,
      printTime: true,
    ),
    filter: AppConstants.enableLogging ? ProductionFilter() : DevelopmentFilter(),
  );

  /// Debug сообщения - для отладки
  static void d(Object? message, [Object? error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Info сообщения - для информации
  static void i(Object? message, [Object? error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Warning сообщения - для предупреждений
  static void w(Object? message, [Object? error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Error сообщения - для ошибок
  static void e(Object? message, [Object? error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Fatal сообщения - для критических ошибок
  static void f(Object? message, [Object? error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging) {
      _logger.f(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Verbose сообщения - для детальной информации
  static void v(Object? message, [Object? error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging) {
      _logger.t(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Логирование сетевых запросов
  static void network(String method, String url, {Map<String, dynamic>? data}) {
    if (AppConstants.enableLogging) {
      _logger.i('🌐 $method $url${data != null ? ' | Data: $data' : ''}');
    }
  }

  /// Логирование сетевых ответов
  static void networkResponse(String method, String url, int statusCode, {Object? data}) {
    if (AppConstants.enableLogging) {
      final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      _logger.i('$emoji $method $url | Status: $statusCode${data != null ? ' | Response: $data' : ''}');
    }
  }

  /// Логирование ошибок сети
  static void networkError(String method, String url, Object error) {
    if (AppConstants.enableLogging) {
      _logger.e('❌ $method $url | Error: $error');
    }
  }

  /// Логирование работы с базой данных
  static void database(String operation, String table, {Object? data}) {
    if (AppConstants.enableLogging) {
      _logger.d('🗄️ DB $operation $table${data != null ? ' | Data: $data' : ''}');
    }
  }

  /// Логирование работы с локальным хранилищем
  static void storage(String operation, String key, {Object? data}) {
    if (AppConstants.enableLogging) {
      _logger.d('💾 Storage $operation $key${data != null ? ' | Data: $data' : ''}');
    }
  }

  /// Логирование навигации
  static void navigation(String from, String to, {Map<String, dynamic>? arguments}) {
    if (AppConstants.enableLogging) {
      _logger.i('🧭 Navigation: $from → $to${arguments != null ? ' | Args: $arguments' : ''}');
    }
  }

  /// Логирование аутентификации
  static void auth(String operation, {Object? data}) {
    if (AppConstants.enableLogging) {
      _logger.i('🔐 Auth $operation${data != null ? ' | Data: $data' : ''}');
    }
  }

  /// Логирование производительности
  static void performance(String operation, Duration duration) {
    if (AppConstants.enableLogging) {
      _logger.i('⚡ Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }

  /// Логирование пользовательских действий
  static void userAction(String action, {Map<String, dynamic>? data}) {
    if (AppConstants.enableLogging) {
      _logger.i('👤 User Action: $action${data != null ? ' | Data: $data' : ''}');
    }
  }

  /// Логирование бизнес-логики
  static void business(String operation, {Object? data}) {
    if (AppConstants.enableLogging) {
      _logger.i('💼 Business: $operation${data != null ? ' | Data: $data' : ''}');
    }
  }

  /// Включить/выключить логирование
  static void setLoggingEnabled(bool enabled) {
    // Это можно использовать для динамического управления логированием
    // В реальном приложении можно добавить сохранение в настройки
    LogService.d('Logging ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Получить текущий уровень логирования
  static bool get isLoggingEnabled => AppConstants.enableLogging;
}
