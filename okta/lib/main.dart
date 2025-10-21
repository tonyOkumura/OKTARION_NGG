import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/core.dart';
import 'core/services/theme_service.dart';
import 'core/initializers/api_initializer.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    LogService.i('Initializing Russian locale...');
    await initializeDateFormatting('ru', null);
    LogService.i('✅ Russian locale initialized successfully');
    
    LogService.i('🚀 Starting ${AppConstants.appName} v${AppConstants.appVersion}');
    
    try {
      LogService.i('📦 Initializing Hive storage...');
      await HiveService.instance.init();
      LogService.i('✅ Hive storage initialized successfully');
      
      LogService.i('🎨 Initializing ThemeService...');
      await Get.putAsync(() => ThemeService().init());
      LogService.i('✅ ThemeService initialized successfully');
      
      LogService.i('🔗 Initializing Supabase...');
      await SupabaseService.instance.init();
      LogService.i('✅ Supabase initialized successfully');
      
      LogService.i('🔍 Checking Supabase connection...');
      final isConnected = await SupabaseService.instance.checkConnection();
      if (isConnected) {
        LogService.i('✅ Supabase connection verified');
      } else {
        LogService.w('⚠️ Supabase connection check failed, but continuing...');
      }
      
      LogService.i('🌐 Initializing API services...');
      await ApiInitializer.initialize();
      LogService.i('✅ API services initialized successfully');
      
      LogService.i('🎯 Launching OktarionApp...');
      runApp(const OktarionApp());
      
      LogService.i('✅ Application launched successfully with theme: ${Get.find<ThemeService>().currentTheme.value.name}');
      
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to initialize application: $e', e, stackTrace);
      ErrorLogService.logCriticalError('Application Initialization', e, stackTrace: stackTrace);
      rethrow;
    }
  }, (error, stackTrace) {
    // Обработка необработанных ошибок
    LogService.e('🚨 Uncaught error: $error', error, stackTrace);
    ErrorLogService.logCriticalError('Uncaught Error', error, stackTrace: stackTrace);
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}
