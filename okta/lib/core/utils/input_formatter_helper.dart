import 'package:flutter/services.dart';

import '../constants/ui_constants.dart';
import '../enums/app_enums.dart';

/// Вспомогательный класс для форматирования ввода
class InputFormatterHelper {
  /// Форматтер без пробелов
  static final noSpacesFormatter = FilteringTextInputFormatter.deny(RegExp(r'\s'));

  /// Получить форматтеры для типа регистрации
  static List<TextInputFormatter> getFormatters(RegisterIdType type) {
    switch (type) {
      case RegisterIdType.username:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
          LengthLimitingTextInputFormatter(UIConstants.maxUsernameLength),
        ];
      case RegisterIdType.email:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          LengthLimitingTextInputFormatter(UIConstants.maxEmailLength),
        ];
      case RegisterIdType.phone:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\(\)\s]')),
          LengthLimitingTextInputFormatter(20),
        ];
    }
  }

  /// Форматировать ввод в зависимости от типа
  static String formatInput(String raw, RegisterIdType type, bool isLogin) {
    if (isLogin) {
      // Для логина просто убираем пробелы
      return raw.replaceAll(' ', '');
    }

    switch (type) {
      case RegisterIdType.username:
        // Убираем все кроме букв, цифр и _
        return raw.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
      case RegisterIdType.email:
        // Убираем пробелы
        return raw.replaceAll(' ', '');
      case RegisterIdType.phone:
        // Форматируем телефон (простая версия)
        final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
        if (digits.length <= 3) {
          return digits;
        } else if (digits.length <= 6) {
          return '${digits.substring(0, 3)}-${digits.substring(3)}';
        } else if (digits.length <= 10) {
          return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
        } else {
          return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6, 10)}';
        }
    }
  }
}
