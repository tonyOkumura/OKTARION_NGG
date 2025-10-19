import 'package:flutter/material.dart';

import '../constants/ui_constants.dart';

/// Утилита для определения типа экрана на основе ширины
class ScreenTypeHelper {
  ScreenTypeHelper._();

  /// Определить тип экрана на основе ширины
  static ScreenType getScreenType(double width) {
    if (width < UIConstants.phoneBreakpoint) {
      return ScreenType.phone;
    } else if (width < UIConstants.mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < UIConstants.tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < UIConstants.laptopBreakpoint) {
      return ScreenType.laptop;
    } else {
      return ScreenType.desktop;
    }
  }

  /// Определить тип экрана из контекста
  static ScreenType getScreenTypeFromContext(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return getScreenType(width);
  }

  /// Проверить, является ли экран телефоном
  static bool isPhone(double width) => width < UIConstants.phoneBreakpoint;

  /// Проверить, является ли экран мобильным устройством
  static bool isMobile(double width) => width < UIConstants.mobileBreakpoint;

  /// Проверить, является ли экран планшетом
  static bool isTablet(double width) => 
      width >= UIConstants.mobileBreakpoint && width < UIConstants.tabletBreakpoint;

  /// Проверить, является ли экран ноутбуком
  static bool isLaptop(double width) => 
      width >= UIConstants.tabletBreakpoint && width < UIConstants.laptopBreakpoint;

  /// Проверить, является ли экран десктопом
  static bool isDesktop(double width) => width >= UIConstants.desktopBreakpoint;

  /// Получить адаптивную ширину формы в процентах
  static double getFormWidthFactor(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return 0.95; // 95% для очень маленьких экранов
      case ScreenType.mobile:
        return 0.9;  // 90% для мобильных
      case ScreenType.tablet:
        return 0.6;  // 60% для планшетов
      case ScreenType.laptop:
        return 0.4;  // 40% для ноутбуков
      case ScreenType.desktop:
        return 0.35; // 35% для больших мониторов
    }
  }

  /// Получить адаптивные отступы
  static EdgeInsets getAdaptivePadding(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return const EdgeInsets.all(UIConstants.spacing16);
      case ScreenType.mobile:
        return const EdgeInsets.all(UIConstants.spacing20);
      case ScreenType.tablet:
        return const EdgeInsets.all(UIConstants.spacing24);
      case ScreenType.laptop:
        return const EdgeInsets.all(UIConstants.spacing28);
      case ScreenType.desktop:
        return const EdgeInsets.all(UIConstants.spacing32);
    }
  }

  /// Получить адаптивный размер шрифта заголовка
  static double getAdaptiveTitleFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return UIConstants.fontSizeXLarge;
      case ScreenType.mobile:
        return UIConstants.fontSizeXXLarge;
      case ScreenType.tablet:
        return UIConstants.fontSizeTitle;
      case ScreenType.laptop:
        return UIConstants.fontSizeXXLarge; // Уменьшили с headline
      case ScreenType.desktop:
        return UIConstants.fontSizeTitle; // Уменьшили с display
    }
  }

  /// Получить количество колонок для сетки
  static int getGridColumns(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return 1;
      case ScreenType.mobile:
        return 2;
      case ScreenType.tablet:
        return 3;
      case ScreenType.laptop:
        return 4;
      case ScreenType.desktop:
        return 5;
    }
  }
}

/// Типы экранов
enum ScreenType {
  phone,    // Очень маленький (телефон)
  mobile,   // Маленький (больше телефона, но меньше планшета)
  tablet,   // Средний (планшет)
  laptop,   // Широкий (ноутбук)
  desktop,  // Очень широкий (монитор 27"+)
}
