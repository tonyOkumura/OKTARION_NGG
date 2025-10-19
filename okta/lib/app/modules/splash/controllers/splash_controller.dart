import 'package:get/get.dart';

import '../../../../core/core.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    LogService.i('🚀 SplashController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    _initializeApp();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Инициализация приложения
  Future<void> _initializeApp() async {
    try {
      LogService.i('🔄 SplashController: App initialization...');
      
      // AuthGate теперь управляет задержкой и переходами
      // SplashController просто логирует процесс
      
      LogService.i('✅ SplashController: App initialization completed');
      
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to initialize app: $e', e, stackTrace);
      ErrorLogService.logCriticalError('App Initialization', e, stackTrace: stackTrace);
    }
  }
}
