import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/core.dart';
import '../../../../core/services/theme_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isRegisterMode = false.obs;
  final errorText = Rxn<String>();
  final now = DateTime.now().obs;
  final seconds = 0.obs;
  
  late final ThemeService _themeService;
  
  // Свойства для проверки сложности пароля
  final passwordStrength = 0.0.obs;
  final passwordStrengthText = ''.obs;
  final passwordStrengthColor = Rx<Color>(Colors.grey);
  
  // Свойство для проверки готовности формы
  final isFormValid = false.obs;


  @override
  void onInit() {
    super.onInit();
    _themeService = Get.find<ThemeService>();
    LogService.i('🔐 LoginController initialized');
    
    
    // Обновляем время каждую секунду
    _startTimer();
  }

  /// Получить акцентный цвет по индексу через ThemeService
  Color _getAccentColor(int index) {
    return AccentColorsHelper.getAccentColorByIndexFromTheme(_themeService.themeData, index);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Запустить таймер для обновления времени
  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now();
      now.value = currentTime;
      seconds.value = currentTime.second;
    });
  }

  /// Переключить видимость пароля
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Оценить сложность пароля
  void evaluatePassword(String password) {
    if (password.isEmpty) {
      passwordStrength.value = 0.0;
      passwordStrengthText.value = '';
      passwordStrengthColor.value = Colors.grey;
    } else {
      double strength = 0.0;
      String text = '';
      Color color = Colors.grey;

      // Проверяем длину
      if (password.length >= 8) strength += 0.2;
      if (password.length >= 12) strength += 0.1;

      // Проверяем наличие различных типов символов
      if (password.contains(RegExp(r'[a-z]'))) strength += 0.1;
      if (password.contains(RegExp(r'[A-Z]'))) strength += 0.1;
      if (password.contains(RegExp(r'[0-9]'))) strength += 0.1;
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;

      // Определяем уровень сложности
      if (strength < 0.3) {
        text = 'Слабый';
        color = Colors.red;
      } else if (strength < 0.6) {
        text = 'Средний';
        color = Colors.orange;
      } else if (strength < 0.8) {
        text = 'Хороший';
        color = Colors.blue;
      } else {
        text = 'Отличный';
        color = Colors.green;
      }

      passwordStrength.value = strength;
      passwordStrengthText.value = text;
      passwordStrengthColor.value = color;
    }
    
    // Проверяем валидность формы
    _checkFormValidity();
  }

  /// Проверить валидность формы
  void _checkFormValidity() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    
    bool isValid = email.isNotEmpty && password.isNotEmpty;
    
    if (isRegisterMode.value) {
      // Для регистрации пароль должен быть достаточно сильным
      isValid = isValid && passwordStrength.value >= 0.3;
    }
    
    isFormValid.value = isValid;
  }

  /// Переключить режим регистрации/входа
  void toggleRegisterMode() {
    isRegisterMode.value = !isRegisterMode.value;
    errorText.value = null; // Очищаем ошибки при переключении
    _checkFormValidity(); // Проверяем валидность после переключения
  }

  /// Обработчик изменения email
  void onEmailChanged(String email) {
    _checkFormValidity();
  }

  /// Войти в систему
  Future<void> signIn() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      errorText.value = null;
      LogService.i('🔐 Attempting to sign in...');

      final response = await SupabaseService.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user != null) {
        LogService.i('✅ Successfully signed in: ${response.user!.email}');
        
        NotificationService.instance.showSuccess(
          title: 'Добро пожаловать!',
          message: 'Вы успешно вошли в систему',
          color: _getAccentColor(3),
        );
      } else {
        throw Exception('No user returned from sign in');
      }

    } on AuthException catch (e) {
      LogService.e('❌ Auth error during sign in: ${e.message}', e);
      
      String errorMessage;
      switch (e.message) {
        case 'Invalid login credentials':
          errorMessage = 'Неверный email или пароль';
          break;
        case 'Email not confirmed':
          errorMessage = 'Email не подтвержден. Проверьте почту';
          break;
        case 'Too many requests':
          errorMessage = 'Слишком много попыток. Попробуйте позже';
          break;
        default:
          errorMessage = 'Ошибка входа: ${e.message}';
      }
      
      errorText.value = errorMessage;
      
      NotificationService.instance.showError(
        title: 'Ошибка входа',
        message: errorMessage,
        color: _getAccentColor(0),
      );
    } catch (e, stackTrace) {
      LogService.e('❌ Unexpected error during sign in: $e', e, stackTrace);
      
      errorText.value = 'Произошла ошибка. Попробуйте еще раз';
      
      NotificationService.instance.showError(
        title: 'Ошибка входа',
        message: 'Произошла ошибка. Попробуйте еще раз',
        color: _getAccentColor(0),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Зарегистрироваться
  Future<void> signUp() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      errorText.value = null;
      LogService.i('📝 Attempting to sign up...');

      final response = await SupabaseService.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user != null) {
        LogService.i('✅ Successfully signed up: ${response.user!.email}');
        
        
        NotificationService.instance.showSuccess(
          title: 'Регистрация успешна!',
          message: response.session != null 
              ? 'Вы успешно зарегистрированы и вошли в систему'
              : 'Проверьте email для подтверждения аккаунта',
          color: _getAccentColor(3),
        );
      } else {
        throw Exception('No user returned from sign up');
      }

    } on AuthException catch (e) {
      LogService.e('❌ Auth error during sign up: ${e.message}', e);
      
      String errorMessage;
      switch (e.message) {
        case 'User already registered':
          errorMessage = 'Пользователь с таким email уже зарегистрирован';
          break;
        case 'Password should be at least 6 characters':
          errorMessage = 'Пароль должен содержать минимум 6 символов';
          break;
        case 'Invalid email':
          errorMessage = 'Некорректный email адрес';
          break;
        case 'Signup is disabled':
          errorMessage = 'Регистрация временно отключена';
          break;
        default:
          errorMessage = 'Ошибка регистрации: ${e.message}';
      }
      
      errorText.value = errorMessage;
      
      NotificationService.instance.showError(
        title: 'Ошибка регистрации',
        message: errorMessage,
        color: _getAccentColor(0),
      );
    } catch (e, stackTrace) {
      LogService.e('❌ Unexpected error during sign up: $e', e, stackTrace);
      
      errorText.value = 'Произошла ошибка. Попробуйте еще раз';
      
      NotificationService.instance.showError(
        title: 'Ошибка регистрации',
        message: 'Произошла ошибка. Попробуйте еще раз',
        color: _getAccentColor(0),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Отправить форму (вход или регистрация)
  void submitForm(GlobalKey<FormState> formKey) {
    if (isRegisterMode.value) {
      signUp();
    } else {
      signIn();
    }
  }

 
  /// Выйти из системы
  Future<void> signOut() async {
    try {
      LogService.i('🚪 Signing out...');
      
      await SupabaseService.instance.signOut();
      
      LogService.i('✅ Successfully signed out');
      
      NotificationService.instance.showInfo(
        title: 'До свидания!',
        message: 'Вы вышли из системы',
        color: _getAccentColor(2),
      );

    } catch (e, stackTrace) {
      LogService.e('❌ Sign out failed: $e', e, stackTrace);
      
      NotificationService.instance.showError(
        title: 'Ошибка выхода',
        message: 'Не удалось выйти из системы',
        color: _getAccentColor(0),
      );
    }
  }

  /// Войти как гость (для демонстрации)
  Future<void> signInAsGuest() async {
    try {
      isLoading.value = true;
      LogService.i('👤 Signing in as guest...');

      // Для демонстрации создаем временную сессию
      // В реальном приложении здесь будет логика гостевого входа
      await Future.delayed(const Duration(seconds: 1));
      
      LogService.i('✅ Successfully signed in as guest');
      
      NotificationService.instance.showInfo(
        title: 'Гостевой режим',
        message: 'Вы вошли как гость',
        color: _getAccentColor(2),
      );

    } catch (e, stackTrace) {
      LogService.e('❌ Guest sign in failed: $e', e, stackTrace);
      
      NotificationService.instance.showError(
        title: 'Ошибка',
        message: 'Не удалось войти как гость',
        color: _getAccentColor(0),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
