import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'core/core.dart';
import 'core/services/theme_service.dart';

/// Главный виджет приложения
/// Содержит конфигурацию GetMaterialApp
class OktarionApp extends StatelessWidget {
  const OktarionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => GetMaterialApp(
      title: AppConstants.appName,
      theme: themeService.currentTheme.value.lightTheme,
      darkTheme: themeService.currentTheme.value.darkTheme,
      themeMode: themeService.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: AppConstants.isDebugMode,
    ));
  }
}
