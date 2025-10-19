import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import 'app_accents.dart';

class Theme5 {
  const Theme5();

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff206487),
      surfaceTint: Color(0xff206487),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffc6e7ff),
      onPrimaryContainer: Color(0xff004c6b),
      secondary: Color(0xff4f616e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd2e5f4),
      onSecondaryContainer: Color(0xff374955),
      tertiary: Color(0xff62597c),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffe8ddff),
      onTertiaryContainer: Color(0xff4a4263),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff181c1f),
      onSurfaceVariant: Color(0xff41484d),
      outline: Color(0xff71787e),
      outlineVariant: Color(0xffc1c7ce),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3135),
      inversePrimary: Color(0xff92cef5),
      primaryFixed: Color(0xffc6e7ff),
      onPrimaryFixed: Color(0xff001e2d),
      primaryFixedDim: Color(0xff92cef5),
      onPrimaryFixedVariant: Color(0xff004c6b),
      secondaryFixed: Color(0xffd2e5f4),
      onSecondaryFixed: Color(0xff0a1d28),
      secondaryFixedDim: Color(0xffb6c9d8),
      onSecondaryFixedVariant: Color(0xff374955),
      tertiaryFixed: Color(0xffe8ddff),
      onTertiaryFixed: Color(0xff1e1635),
      tertiaryFixedDim: Color(0xffccc1e9),
      onTertiaryFixedVariant: Color(0xff4a4263),
      surfaceDim: Color(0xffd7dadf),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffebeef3),
      surfaceContainerHigh: Color(0xffe5e8ed),
      surfaceContainerHighest: Color(0xffdfe3e7),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff92cef5),
      surfaceTint: Color(0xff92cef5),
      onPrimary: Color(0xff00344b),
      primaryContainer: Color(0xff004c6b),
      onPrimaryContainer: Color(0xffc6e7ff),
      secondary: Color(0xffb6c9d8),
      onSecondary: Color(0xff21323e),
      secondaryContainer: Color(0xff374955),
      onSecondaryContainer: Color(0xffd2e5f4),
      tertiary: Color(0xffccc1e9),
      onTertiary: Color(0xff332c4b),
      tertiaryContainer: Color(0xff4a4263),
      onTertiaryContainer: Color(0xffe8ddff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffdfe3e7),
      onSurfaceVariant: Color(0xffc1c7ce),
      outline: Color(0xff8b9198),
      outlineVariant: Color(0xff41484d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff206487),
      primaryFixed: Color(0xffc6e7ff),
      onPrimaryFixed: Color(0xff001e2d),
      primaryFixedDim: Color(0xff92cef5),
      onPrimaryFixedVariant: Color(0xff004c6b),
      secondaryFixed: Color(0xffd2e5f4),
      onSecondaryFixed: Color(0xff0a1d28),
      secondaryFixedDim: Color(0xffb6c9d8),
      onSecondaryFixedVariant: Color(0xff374955),
      tertiaryFixed: Color(0xffe8ddff),
      onTertiaryFixed: Color(0xff1e1635),
      tertiaryFixedDim: Color(0xffccc1e9),
      onTertiaryFixedVariant: Color(0xff4a4263),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff353a3d),
      surfaceContainerLowest: Color(0xff0a0f12),
      surfaceContainerLow: Color(0xff181c1f),
      surfaceContainer: Color(0xff1c2024),
      surfaceContainerHigh: Color(0xff262a2e),
      surfaceContainerHighest: Color(0xff313539),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme:
          GoogleFonts.interTextTheme(
            ThemeData(brightness: colorScheme.brightness).textTheme,
          ).apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      extensions: <ThemeExtension<dynamic>>[
        const AppAccents(
          // Arctic: cherry, lemon, cyan, green, purple
          accent1: Color(0xffe53935),
          accent2: Color(0xffffd600),
          accent3: Color(0xff26c6da),
          accent4: Color(0xff43a047),
          accent5: Color(0xff8e24aa),
        ),
      ],
    );
  }
}
