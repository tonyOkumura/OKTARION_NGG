import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:okta/app/modules/home/bindings/main_binding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/core.dart';
import '../../app/modules/splash/views/splash_view.dart';
import '../../app/modules/home/views/main_view.dart';
import '../../app/modules/login/views/login_view.dart';
import '../../app/modules/login/views/email_confirmation_view.dart';
import '../../app/modules/login/bindings/login_binding.dart';
import '../../app/modules/login/controllers/login_controller.dart';
import '../../app/modules/home/controllers/main_controller.dart';

/// AuthGate - виджет для управления навигацией в зависимости от статуса аутентификации
/// Автоматически переключает между Splash, Login и Home страницами
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      LogService.i('🚀 Initializing AuthGate...');
      
      // Проверяем текущее состояние аутентификации
      final currentUser = SupabaseService.instance.currentUser;
      LogService.i('🔍 Current user on init: ${currentUser?.email ?? 'No user'}');
      
      // Показываем splash экран минимум 2 секунды
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        LogService.i('✅ AuthGate initialization completed');
      }
    } catch (e, stackTrace) {
      LogService.e('❌ AuthGate initialization failed: $e', e, stackTrace);
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Показываем splash экран во время инициализации
    if (_isInitializing) {
      return const SplashView();
    }

    return StreamBuilder<AuthState>(
      stream: SupabaseService.instance.authStateChanges,
      builder: (context, snapshot) {
        // Показываем Splash пока идет загрузка
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashView();
        }

        // Проверяем статус аутентификации
        final authState = snapshot.data;
        final isAuthenticated = authState?.session != null;
        final user = authState?.session?.user;
        final isEmailConfirmed = user?.emailConfirmedAt != null;

        LogService.i('🔐 AuthGate: User ${isAuthenticated ? 'authenticated' : 'not authenticated'}');
        LogService.i('🔐 AuthGate: AuthState: ${authState?.event}');
        LogService.i('🔐 AuthGate: Session: ${user?.email ?? 'No user'}');
        LogService.i('🔐 AuthGate: Email confirmed: $isEmailConfirmed');

        if (isAuthenticated && user != null && isEmailConfirmed) {
          // Пользователь авторизован и email подтвержден - показываем Home
          // Инициализируем биндинг для MainController
          if (!Get.isRegistered<MainController>()) {
            MainBinding().dependencies();
          }
          return const MainView();
        } else if (isAuthenticated && user != null && !isEmailConfirmed) {
          // Пользователь зарегистрирован, но email не подтвержден - показываем экран подтверждения
          // Инициализируем биндинг для LoginController
          if (!Get.isRegistered<LoginController>()) {
            LoginBinding().dependencies();
          }
          return const EmailConfirmationView();
        } else {
          // Пользователь не авторизован - показываем Login
          // Очищаем все контроллеры при выходе
          if (Get.isRegistered<MainController>()) {
            Get.delete<MainController>();
          }
          
          // Инициализируем биндинг для LoginController
          if (!Get.isRegistered<LoginController>()) {
            LoginBinding().dependencies();
          }
          return const LoginView();
        }
      },
    );
  }
}
