import 'package:flutter/material.dart';

enum AppTheme {
  theme1,
  theme2,
  theme3,
  theme5,
}
enum RegisterIdType {
  username,
  email,
  phone,
}
enum ColorTweenBg {
  color1,
  color2,
}
extension AppThemeExtension on AppTheme {
  String get name {
    switch (this) {
      case AppTheme.theme1:
        return 'Синяя';
      case AppTheme.theme2:
        return 'Зеленая';
      case AppTheme.theme3:
        return 'Фиолетовая';
      case AppTheme.theme5:
        return 'Розовая';
    }
  }

  ThemeData get lightTheme {
    switch (this) {
      case AppTheme.theme1:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        );
      case AppTheme.theme2:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        );
      case AppTheme.theme3:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.light,
          ),
        );
      case AppTheme.theme5:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
            brightness: Brightness.light,
          ),
        );
    }
  }

  ThemeData get darkTheme {
    switch (this) {
      case AppTheme.theme1:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        );
      case AppTheme.theme2:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
        );
      case AppTheme.theme3:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark,
          ),
        );
      case AppTheme.theme5:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
            brightness: Brightness.dark,
          ),
        );
    }
  }

  Color get primaryColor {
    return lightTheme.colorScheme.primary;
  }
}