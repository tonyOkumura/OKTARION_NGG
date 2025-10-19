import '../constants/ui_constants.dart';

/// Вспомогательный класс для валидации полей
class ValidationHelper {
  /// Проверка обязательного поля
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Это поле обязательно для заполнения';
    }
    return null;
  }

  /// Валидация email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email обязателен';
    }
    
    final emailRegex = RegExp(UIConstants.emailRegex);
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Введите корректный email';
    }
    
    return null;
  }

  /// Валидация имени пользователя
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Имя пользователя обязательно';
    }
    
    if (value.length < UIConstants.minUsernameLength) {
      return 'Имя пользователя должно содержать минимум ${UIConstants.minUsernameLength} символа';
    }
    
    if (value.length > UIConstants.maxUsernameLength) {
      return 'Имя пользователя не должно превышать ${UIConstants.maxUsernameLength} символов';
    }
    
    final usernameRegex = RegExp(UIConstants.usernameRegex);
    if (!usernameRegex.hasMatch(value)) {
      return 'Имя пользователя может содержать только буквы, цифры и _';
    }
    
    return null;
  }

  /// Валидация телефона
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Телефон обязателен';
    }
    
    // Убираем все кроме цифр и +
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleanPhone.length < 10) {
      return 'Телефон должен содержать минимум 10 цифр';
    }
    
    return null;
  }

  /// Валидация пароля
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль обязателен';
    }
    
    if (value.length < UIConstants.minPasswordLength) {
      return 'Пароль должен содержать минимум ${UIConstants.minPasswordLength} символов';
    }
    
    if (value.length > UIConstants.maxPasswordLength) {
      return 'Пароль не должен превышать ${UIConstants.maxPasswordLength} символов';
    }
    
    return null;
  }
}
