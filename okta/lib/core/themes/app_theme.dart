import 'package:flutter/material.dart';
import 'theme_1.dart';
import 'theme_2.dart';
import 'theme_3.dart';
import 'theme_4.dart';
import 'theme_5.dart';
import 'theme_6.dart';

enum AppTheme {
  theme1('Терракотовая', Theme1()),
  theme2('Синяя', Theme2()),
  theme3('Зеленая', Theme3()),
  theme4('Фиолетовая', Theme4()),
  theme5('Оранжевая', Theme5()),
  theme6('Розовая', Theme6());

  const AppTheme(this.displayName, this.themeClass);

  final String displayName;
  final dynamic themeClass;

  /// Получить светлую тему
  ThemeData get lightTheme => themeClass.light();

  /// Получить темную тему
  ThemeData get darkTheme => themeClass.dark();

  /// Получить основной цвет темы
  Color get primaryColor => lightTheme.colorScheme.primary;

  /// Получить цветовую схему для светлой темы
  ColorScheme get lightColorScheme => lightTheme.colorScheme;

  /// Получить цветовую схему для темной темы
  ColorScheme get darkColorScheme => darkTheme.colorScheme;

}
