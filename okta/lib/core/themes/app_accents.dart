import "package:flutter/material.dart";

@immutable
class AppAccents extends ThemeExtension<AppAccents> {
  final Color accent1;
  final Color accent2;
  final Color accent3;
  final Color accent4;
  final Color accent5;

  const AppAccents({
    required this.accent1,
    required this.accent2,
    required this.accent3,
    required this.accent4,
    required this.accent5,
  });

  factory AppAccents.fromScheme(ColorScheme cs) {
    // Fallback derivation if ever needed; prefer explicit per-theme palettes
    return AppAccents(
      accent1: cs.error,
      accent2: cs.tertiary,
      accent3: cs.primary,
      accent4: cs.secondary,
      accent5: cs.inversePrimary,
    );
  }

  @override
  AppAccents copyWith({
    Color? accent1,
    Color? accent2,
    Color? accent3,
    Color? accent4,
    Color? accent5,
  }) {
    return AppAccents(
      accent1: accent1 ?? this.accent1,
      accent2: accent2 ?? this.accent2,
      accent3: accent3 ?? this.accent3,
      accent4: accent4 ?? this.accent4,
      accent5: accent5 ?? this.accent5,
    );
  }

  @override
  AppAccents lerp(ThemeExtension<AppAccents>? other, double t) {
    if (other is! AppAccents) return this;
    return AppAccents(
      accent1: Color.lerp(accent1, other.accent1, t) ?? accent1,
      accent2: Color.lerp(accent2, other.accent2, t) ?? accent2,
      accent3: Color.lerp(accent3, other.accent3, t) ?? accent3,
      accent4: Color.lerp(accent4, other.accent4, t) ?? accent4,
      accent5: Color.lerp(accent5, other.accent5, t) ?? accent5,
    );
  }
}

extension AppAccentsX on ThemeData {
  AppAccents get accents =>
      extension<AppAccents>() ??
      const AppAccents(
        accent1: Color(0xffe53935),
        accent2: Color(0xffffb300),
        accent3: Color(0xff42a5f5),
        accent4: Color(0xff43a047),
        accent5: Color(0xff8e24aa),
      );
}
