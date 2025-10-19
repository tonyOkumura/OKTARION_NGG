import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../enums/app_enums.dart';
import '../storage/hive_service.dart';

class ThemeService extends GetxService {
  static const String keyThemeIndex = 'theme_index';
  static const String keyIsDark = 'is_dark';

  final Rx<AppTheme> currentTheme = Rx<AppTheme>(AppTheme.theme1);
  final RxBool isDarkMode = RxBool(false);

  Future<ThemeService> init() async {
    final int? savedIndex = HiveService.instance.appBox.get(keyThemeIndex);
    final bool? savedDark = HiveService.instance.appBox.get(keyIsDark);

    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < AppTheme.values.length) {
      currentTheme.value = AppTheme.values[savedIndex];
    } else {
      currentTheme.value = AppTheme.theme1;
      HiveService.instance.appBox.put(keyThemeIndex, AppTheme.theme1.index);
    }

    if (savedDark != null) {
      isDarkMode.value = savedDark;
    } else {
      isDarkMode.value = _detectSystemDarkMode();
      HiveService.instance.appBox.put(keyIsDark, isDarkMode.value);
    }

    return this;
  }

  ThemeData get themeData => isDarkMode.value
      ? currentTheme.value.darkTheme
      : currentTheme.value.lightTheme;

  void setTheme(AppTheme theme) {
    currentTheme.value = theme;
    HiveService.instance.appBox.put(keyThemeIndex, theme.index);
    _applyThemeChange();
  }

  void toggleDarkMode(bool isDark) {
    isDarkMode.value = isDark;
    HiveService.instance.appBox.put(keyIsDark, isDark);
    _applyThemeChange();
  }

  void syncWithSystem() {
    final bool systemDark = _detectSystemDarkMode();
    if (isDarkMode.value != systemDark) {
      toggleDarkMode(systemDark);
    }
  }

  bool _detectSystemDarkMode() {
    final Brightness brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  void _applyThemeChange() {
    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      Get.changeTheme(themeData);
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.changeTheme(themeData);
      });
    }
  }
}
