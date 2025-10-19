import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import 'app_accents.dart';

class Theme6 {
  const Theme6();

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff7e57c2),
      surfaceTint: Color(0xff7e57c2),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffede7ff),
      onPrimaryContainer: Color(0xff31006d),
      secondary: Color(0xff9575cd),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfff3e8ff),
      onSecondaryContainer: Color(0xff381e72),
      tertiary: Color(0xffba68c8),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffe4ff),
      onTertiaryContainer: Color(0xff4a148c),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffcfbff),
      onSurface: Color(0xff1c1b1f),
      onSurfaceVariant: Color(0xff49454f),
      outline: Color(0xff79747e),
      outlineVariant: Color(0xffcbc6d3),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313033),
      inversePrimary: Color(0xffcfbcff),
      primaryFixed: Color(0xffede7ff),
      onPrimaryFixed: Color(0xff31006d),
      primaryFixedDim: Color(0xffcfbcff),
      onPrimaryFixedVariant: Color(0xff623da8),
      secondaryFixed: Color(0xfff3e8ff),
      onSecondaryFixed: Color(0xff1e005d),
      secondaryFixedDim: Color(0xffdac7ff),
      onSecondaryFixedVariant: Color(0xff381e72),
      tertiaryFixed: Color(0xffffe4ff),
      onTertiaryFixed: Color(0xff38006b),
      tertiaryFixedDim: Color(0xffe8bbff),
      onTertiaryFixedVariant: Color(0xff4a148c),
      surfaceDim: Color(0xffdad9e0),
      surfaceBright: Color(0xfffcfbff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f5ff),
      surfaceContainer: Color(0xfff2f0fa),
      surfaceContainerHigh: Color(0xffeceaf4),
      surfaceContainerHighest: Color(0xffe6e4ee),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcfbcff),
      surfaceTint: Color(0xffcfbcff),
      onPrimary: Color(0xff4c2a85),
      primaryContainer: Color(0xff623da8),
      onPrimaryContainer: Color(0xffede7ff),
      secondary: Color(0xffdac7ff),
      onSecondary: Color(0xff331c6b),
      secondaryContainer: Color(0xff381e72),
      onSecondaryContainer: Color(0xfff3e8ff),
      tertiary: Color(0xffe8bbff),
      onTertiary: Color(0xff5c2877),
      tertiaryContainer: Color(0xff4a148c),
      onTertiaryContainer: Color(0xffffe4ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff121212),
      onSurface: Color(0xffe6e4ee),
      onSurfaceVariant: Color(0xffcbc6d3),
      outline: Color(0xff93909c),
      outlineVariant: Color(0xff49454f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e4ee),
      inversePrimary: Color(0xff7e57c2),
      primaryFixed: Color(0xffede7ff),
      onPrimaryFixed: Color(0xff31006d),
      primaryFixedDim: Color(0xffcfbcff),
      onPrimaryFixedVariant: Color(0xff623da8),
      secondaryFixed: Color(0xfff3e8ff),
      onSecondaryFixed: Color(0xff1e005d),
      secondaryFixedDim: Color(0xffdac7ff),
      onSecondaryFixedVariant: Color(0xff381e72),
      tertiaryFixed: Color(0xffffe4ff),
      onTertiaryFixed: Color(0xff38006b),
      tertiaryFixedDim: Color(0xffe8bbff),
      onTertiaryFixedVariant: Color(0xff4a148c),
      surfaceDim: Color(0xff121212),
      surfaceBright: Color(0xff383838),
      surfaceContainerLowest: Color(0xff0d0d0d),
      surfaceContainerLow: Color(0xff1c1b1f),
      surfaceContainer: Color(0xff202024),
      surfaceContainerHigh: Color(0xff2b2b30),
      surfaceContainerHighest: Color(0xff36363b),
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
          // Violet: ruby, amber, indigo, emerald, hotpink
          accent1: Color(0xffef5350),
          accent2: Color(0xffffc107),
          accent3: Color(0xff5c6bc0),
          accent4: Color(0xff2e7d32),
          accent5: Color(0xffec407a),
        ),
      ],
    );
  }
}
