import 'package:get/get.dart';

import '../../../../core/core.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/services/theme_service.dart';

class SettingsController extends GetxController {
  final RxBool notificationsEnabled = true.obs;
  final RxBool messagesEnabled = true.obs;
  final RxBool privacyMode = false.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorText = RxnString();

  // ThemeService
  late final ThemeService _themeService;
  
  // Getters для совместимости
  RxBool get isDarkMode => _themeService.isDarkMode;
  Rx<AppTheme> get currentTheme => _themeService.currentTheme;
  
  // Доступные темы
  List<AppTheme> get availableThemes => AppTheme.values;

  @override
  void onInit() {
    super.onInit();
    _themeService = Get.find<ThemeService>();
    _loadSettings();
  }

  /// Загрузить настройки из Hive
  void _loadSettings() {
    try {
      // Загружаем настройки уведомлений
      notificationsEnabled.value = HiveService.instance.appBox.get('notificationsEnabled', defaultValue: true);
      messagesEnabled.value = HiveService.instance.appBox.get('messagesEnabled', defaultValue: true);
      privacyMode.value = HiveService.instance.appBox.get('privacyMode', defaultValue: false);

      LogService.i('⚙️ Settings loaded from Hive');
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to load settings: $e', e, stackTrace);
    }
  }

  /// Сохранить настройки в Hive
  void _saveSettings() {
    try {
      HiveService.instance.appBox.put('notificationsEnabled', notificationsEnabled.value);
      HiveService.instance.appBox.put('messagesEnabled', messagesEnabled.value);
      HiveService.instance.appBox.put('privacyMode', privacyMode.value);

      LogService.i('💾 Settings saved to Hive');
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to save settings: $e', e, stackTrace);
    }
  }

  /// Изменить тему приложения
  void changeAppTheme(AppTheme theme) {
    try {
      _themeService.setTheme(theme);
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to change theme: $e', e, stackTrace);
    }
  }

  /// Переключить темный/светлый режим
  void toggleThemeMode() {
    try {
      _themeService.toggleDarkMode(!_themeService.isDarkMode.value);
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to toggle theme mode: $e', e, stackTrace);
    }
  }

  /// Переключить уведомления
  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
    _saveSettings();
  }

  /// Переключить сообщения
  void toggleMessages() {
    messagesEnabled.value = !messagesEnabled.value;
    _saveSettings();
  }

  /// Переключить приватный режим
  void togglePrivacyMode() {
    privacyMode.value = !privacyMode.value;
    _saveSettings();
  }

  /// Сбросить настройки
  void resetSettings() {
    notificationsEnabled.value = true;
    messagesEnabled.value = true;
    privacyMode.value = false;

    _themeService.setTheme(AppTheme.theme1);
    _themeService.toggleDarkMode(false);
    _saveSettings();
  }
}