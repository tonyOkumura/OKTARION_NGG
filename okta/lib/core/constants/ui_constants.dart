import 'package:flutter/material.dart';

/// Константы для UI элементов
/// Содержит размеры, цвета, стили и другие UI константы
class UIConstants {
  UIConstants._();

  // ==================== SIZES ====================
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 48.0;

  static const double buttonHeight = 48.0;
  static const double smallButtonHeight = 36.0;
  static const double largeButtonHeight = 56.0;

  static const double inputFieldHeight = 48.0;
  static const double smallInputFieldHeight = 40.0;
  static const double largeInputFieldHeight = 56.0;

  // ==================== SPACING ====================
  static const double spacing2 = 2.0;
  static const double spacing3 = 3.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing18 = 18.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing28 = 28.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // ==================== BORDER RADIUS ====================
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radius32 = 32.0;

  // ==================== ELEVATION ====================
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;

  // ==================== ANIMATION CONSTANTS ====================
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ==================== BREAKPOINTS ====================
  // Очень маленький (телефон) - до 480px
  static const double phoneBreakpoint = 480.0;
  
  // Маленький (больше телефона, но меньше планшета) - до 768px
  static const double mobileBreakpoint = 768.0;
  
  // Средний (планшет) - до 1024px
  static const double tabletBreakpoint = 1024.0;
  
  // Широкий (ноутбук) - до 1440px
  static const double laptopBreakpoint = 1440.0;
  
  // Очень широкий (монитор 27"+) - от 1440px
  static const double desktopBreakpoint = 1440.0;

  // ==================== ASPECT RATIOS ====================
  static const double cardAspectRatio = 16 / 9;
  static const double imageAspectRatio = 4 / 3;
  static const double avatarAspectRatio = 1 / 1;

  // ==================== FONT SIZES ====================
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeadline = 32.0;
  static const double fontSizeDisplay = 48.0;

  // ==================== CLOCK BLOCK SIZES ====================
  static const double clockTimeFontSizeCompact = 48.0;
  static const double clockTimeFontSizeMedium = 56.0;
  static const double clockTimeFontSizeLarge = 64.0;
  
  static const double clockDateFontSizeCompact = 18.0;
  static const double clockDateFontSizeMedium = 20.0;
  static const double clockDateFontSizeLarge = 24.0;

  static const EdgeInsets clockPaddingCompact = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const EdgeInsets clockPaddingMedium = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const EdgeInsets clockPaddingLarge = EdgeInsets.symmetric(horizontal: 20, vertical: 16);

  static const double clockSpacingCompact = 8.0;
  static const double clockSpacingMedium = 16.0;
  static const double clockSpacingLarge = 16.0;

  static const double clockBottomPaddingCompact = 4.0;
  static const double clockBottomPaddingMedium = 8.0;
  static const double clockBottomPaddingLarge = 8.0;

  // ==================== ADDITIONAL RADIUS CONSTANTS ====================
  static const double radius28 = 28.0;

  // ==================== VALIDATION CONSTANTS ====================
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int maxEmailLength = 100;

  // ==================== REGEX PATTERNS ====================
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';
  static const String usernameRegex = r'^[a-zA-Z0-9_]{3,20}$';

  // ==================== SKELETON COLORS ====================
  /// Базовый цвет для скелетонов - использует onSurface из темы
  static Color skeletonBaseColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);
  }
  
  /// Цвет подсветки для скелетонов - более яркий onSurface
  static Color skeletonHighlightColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
  }
}
