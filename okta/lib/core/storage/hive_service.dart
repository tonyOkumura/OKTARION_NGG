import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../utils/log_service.dart';
import 'hive_config.dart';

/// Сервис для работы с Hive локальным хранилищем
/// Предоставляет методы для инициализации и работы с различными box'ами
class HiveService {
  HiveService._();
  
  static final HiveService _instance = HiveService._();
  static HiveService get instance => _instance;

  bool _isInitialized = false;

  /// Инициализация Hive
  Future<void> init() async {
    if (_isInitialized) {
      LogService.w('HiveService already initialized');
      return;
    }

    try {
      // Инициализация Hive Flutter
      await Hive.initFlutter();
      
      // Регистрация адаптеров (будут добавлены позже при необходимости)
      
      // Открытие всех необходимых box'ов
      await _openBoxes();
      
      _isInitialized = true;
      LogService.i('HiveService initialized successfully');
      
      // Установка начальных значений если это первый запуск
      await _setInitialValues();
      
    } catch (e) {
      LogService.e('Failed to initialize HiveService: $e');
      rethrow;
    }
  }

  /// Открытие всех необходимых box'ов
  Future<void> _openBoxes() async {
    try {
      await Future.wait([
        Hive.openBox(HiveConfig.appBox),
        Hive.openBox(HiveConfig.cacheBox),
        Hive.openBox(HiveConfig.sessionBox),
      ]);
      LogService.i('All Hive boxes opened successfully');
    } catch (e) {
      LogService.e('Failed to open Hive boxes: $e');
      rethrow;
    }
  }

  /// Установка начальных значений
  Future<void> _setInitialValues() async {
    final appBox = Hive.box(HiveConfig.appBox);
    
    // Проверяем, первый ли это запуск приложения
    if (!appBox.containsKey(HiveConfig.isFirstLaunch)) {
      appBox.put(HiveConfig.isFirstLaunch, true);
      appBox.put(HiveConfig.appVersion, AppConstants.appVersion);
      LogService.i('First launch detected, initial values set');
    } else {
      // Обновляем версию приложения
      appBox.put(HiveConfig.appVersion, AppConstants.appVersion);
    }
  }

  /// Получение box'а по имени
  Box getBox(String boxName) {
    if (!_isInitialized) {
      throw Exception('HiveService not initialized. Call init() first.');
    }
    return Hive.box(boxName);
  }

  /// Получение App Box
  Box get appBox => getBox(HiveConfig.appBox);

  /// Получение Cache Box
  Box get cacheBox => getBox(HiveConfig.cacheBox);

  /// Получение Session Box
  Box get sessionBox => getBox(HiveConfig.sessionBox);

  /// Проверка, первый ли это запуск приложения
  bool get isFirstLaunch {
    return appBox.get(HiveConfig.isFirstLaunch, defaultValue: true);
  }

  /// Установка флага первого запуска
  Future<void> setFirstLaunchCompleted() async {
    await appBox.put(HiveConfig.isFirstLaunch, false);
  }

  /// Очистка всех данных
  Future<void> clearAllData() async {
    try {
      await Future.wait([
        appBox.clear(),
        cacheBox.clear(),
        sessionBox.clear(),
      ]);
      LogService.i('All Hive data cleared');
    } catch (e) {
      LogService.e('Failed to clear Hive data: $e');
      rethrow;
    }
  }

  /// Очистка кэша
  Future<void> clearCache() async {
    try {
      await cacheBox.clear();
      LogService.i('Cache cleared');
    } catch (e) {
      LogService.e('Failed to clear cache: $e');
      rethrow;
    }
  }

  /// Очистка сессии
  Future<void> clearSession() async {
    try {
      await sessionBox.clear();
      LogService.i('Session cleared');
    } catch (e) {
      LogService.e('Failed to clear session: $e');
      rethrow;
    }
  }

  /// Получение размера всех box'ов
  Map<String, int> getStorageInfo() {
    return {
      HiveConfig.appBox: appBox.length,
      HiveConfig.cacheBox: cacheBox.length,
      HiveConfig.sessionBox: sessionBox.length,
    };
  }

  /// Закрытие всех box'ов
  Future<void> close() async {
    if (!_isInitialized) return;
    
    try {
      await Hive.close();
      _isInitialized = false;
      LogService.i('HiveService closed');
    } catch (e) {
      LogService.e('Failed to close HiveService: $e');
    }
  }
}
