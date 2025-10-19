/// Конфигурация Hive для локального хранения данных
/// Содержит настройки и константы для работы с Hive
class HiveConfig {
  HiveConfig._();

  // ==================== BOX NAMES ====================
  static const String appBox = 'okta_app_box';
  static const String cacheBox = 'okta_cache_box';
  static const String sessionBox = 'okta_session_box';

  // ==================== KEYS ====================
  // App Box Keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String appVersion = 'app_version';
  static const String lastUpdateCheck = 'last_update_check';

  // Cache Box Keys
  static const String apiCache = 'api_cache';
  static const String imageCache = 'image_cache';
  static const String searchHistory = 'search_history';

  // Session Box Keys
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String sessionData = 'session_data';

  // ==================== CONFIGURATION ====================
  static const int maxCacheSize = 100; // Максимальное количество элементов в кэше
  static const Duration cacheExpiration = Duration(days: 7); // Время жизни кэша
  static const bool enableCompression = true; // Включить сжатие данных
}
