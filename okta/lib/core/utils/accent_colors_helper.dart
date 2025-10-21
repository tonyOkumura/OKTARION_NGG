import 'package:flutter/material.dart';
import '../themes/app_accents.dart';

/// Утилитарный класс для работы с акцентными цветами
class AccentColorsHelper {
  /// Получить список всех акцентных цветов из текущей темы
  static List<Color> getAccentColors(BuildContext context) {
    final theme = Theme.of(context);
    final accents = theme.accents;
    
    return [
      accents.accent1,
      accents.accent2,
      accents.accent3,
      accents.accent4,
      accents.accent5,
    ];
  }

  /// Получить акцентный цвет по индексу (0-4)
  static Color getAccentColorByIndex(BuildContext context, int index) {
    final accentColors = getAccentColors(context);
    return accentColors[index % accentColors.length];
  }

  /// Получить акцентный цвет по строке (хеширование)
  static Color getAccentColorByString(BuildContext context, String input) {
    final index = _getAccentIndexForString(input);
    return getAccentColorByIndex(context, index);
  }

  /// Вычислить индекс акцентного цвета для строки
  static int _getAccentIndexForString(String input) {
    if (input.isEmpty) return 0;
    int hash = 0;
    for (final int codeUnit in input.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash % 5; // map to 5 accent slots
  }

  /// Получить акцентный цвет с прозрачностью
  static Color getAccentColorWithOpacity(BuildContext context, int index, double opacity) {
    return getAccentColorByIndex(context, index).withOpacity(opacity);
  }

  /// Получить акцентный цвет по строке с прозрачностью
  static Color getAccentColorByStringWithOpacity(BuildContext context, String input, double opacity) {
    return getAccentColorByString(context, input).withOpacity(opacity);
  }

  /// Получить акцентный цвет по индексу из ThemeData (без BuildContext)
  static Color getAccentColorByIndexFromTheme(ThemeData theme, int index) {
    final accents = theme.accents;
    final List<Color> accentColors = [
      accents.accent1,
      accents.accent2,
      accents.accent3,
      accents.accent4,
      accents.accent5,
    ];
    return accentColors[index % accentColors.length];
  }
}
