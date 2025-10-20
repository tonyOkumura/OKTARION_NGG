/// Конфигурация API сервера
/// Содержит все настройки для работы с внешним API
class ApiConfig {
  // Базовый URL API сервера
  static const String baseUrl = 'http://localhost:8008/api/v1';
  
  // Таймауты для запросов
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Заголовки по умолчанию
  static const String contentType = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  
  // HTTP коды ответов
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int serverErrorCode = 500;
  


}
