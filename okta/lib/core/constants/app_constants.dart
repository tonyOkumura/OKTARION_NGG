/// Центральный файл констант приложения
/// Содержит все основные константы, используемые в приложении
class AppConstants {
  AppConstants._();

  // ==================== APP INFO ====================
  static const String appName = 'Okta';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A new Flutter project';

  // ==================== API CONSTANTS ====================
  static const String baseUrl = 'http://localhost:8008';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ==================== SUPABASE CONSTANTS ====================
  static const String supabaseUrl = 'http://localhost:8008';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE';
  static const String supabaseJwtSecret = 'your-super-secret-jwt-token-with-at-least-32-characters-long';

  // ==================== STORAGE CONSTANTS ====================
  static const String hiveBoxName = 'okta_storage';
  static const String userBoxName = 'user_storage';
  static const String settingsBoxName = 'settings_storage';

  // ==================== PAGINATION CONSTANTS ====================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ==================== ASSETS PATHS ====================
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String fontsPath = 'assets/fonts/';

  // ==================== ENVIRONMENT ====================
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
  static const bool enableCrashReporting = true;
}
