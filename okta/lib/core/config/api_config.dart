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
  
  // Настройки для разных сред
  static const Map<String, String> environments = {
    'development': 'http://localhost:3000/api/v1',
    'staging': 'https://staging-api.your-server.com/api/v1',
    'production': 'https://api.your-server.com/api/v1',
  };
  
  // Получить URL для текущей среды
  static String getBaseUrlForEnvironment(String environment) {
    return environments[environment] ?? baseUrl;
  }
  
  // Проверка, является ли URL локальным
  static bool isLocalUrl(String url) {
    return url.contains('localhost') || url.contains('127.0.0.1');
  }
  
  // Получить полный URL эндпоинта
  static String getFullUrl(String endpoint, {String? environment}) {
    final base = environment != null 
        ? getBaseUrlForEnvironment(environment) 
        : baseUrl;
    return '$base$endpoint';
  }
}
