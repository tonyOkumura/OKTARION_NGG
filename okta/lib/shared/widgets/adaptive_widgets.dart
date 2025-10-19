import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../core/core.dart';
import 'glass_loading.dart';

/// Адаптивный контейнер для форм
class AdaptiveFormContainer extends StatelessWidget {
  const AdaptiveFormContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final screenType = ScreenTypeHelper.getScreenTypeFromContext(context);
    final adaptivePadding = ScreenTypeHelper.getAdaptivePadding(screenType);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _getMaxWidth(context, screenType),
        ),
        child: Container(
          margin: margin,
          padding: padding ?? adaptivePadding,
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }

  /// Получить максимальную ширину для контейнера
  double _getMaxWidth(BuildContext context, ScreenType screenType) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Ограничиваем минимальную и максимальную ширину
    switch (screenType) {
      case ScreenType.phone:
        return screenWidth * 0.95; // 95% от ширины экрана
      case ScreenType.mobile:
        return screenWidth * 0.9;  // 90% от ширины экрана
      case ScreenType.tablet:
        return 650; // Увеличили с 600 до 650
      case ScreenType.laptop:
        return 550; // Увеличили с 500 до 550
      case ScreenType.desktop:
        return 500; // Увеличили с 450 до 500
    }
  }
}

/// Адаптивная сетка
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.spacing = UIConstants.spacing16,
    this.runSpacing = UIConstants.spacing16,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final screenType = ScreenTypeHelper.getScreenTypeFromContext(context);
    final columns = ScreenTypeHelper.getGridColumns(screenType);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (columns == 1) {
          // Для одной колонки используем Column
          return Column(
            children: children.map((child) => Padding(
              padding: EdgeInsets.only(bottom: runSpacing),
              child: child,
            )).toList(),
          );
        } else {
          // Для нескольких колонок используем Wrap
          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children,
          );
        }
      },
    );
  }
}

/// Адаптивный текст
class AdaptiveText extends StatelessWidget {
  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.isTitle = false,
    this.isSubtitle = false,
    this.isBody = false,
    this.isCaption = false,
    this.isLabel = false,
    this.fontWeight,
    this.color,
    this.backgroundColor,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.shadows,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isTitle;
  final bool isSubtitle;
  final bool isBody;
  final bool isCaption;
  final bool isLabel;
  final FontWeight? fontWeight;
  final Color? color;
  final Color? backgroundColor;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final screenType = ScreenTypeHelper.getScreenTypeFromContext(context);
    final theme = Theme.of(context);

    TextStyle? adaptiveStyle;

    if (isTitle) {
      final fontSize = ScreenTypeHelper.getAdaptiveTitleFontSize(screenType);
      adaptiveStyle = theme.textTheme.headlineMedium?.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color,
        backgroundColor: backgroundColor,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        shadows: shadows,
      );
    } else if (isSubtitle) {
      final fontSize = _getAdaptiveSubtitleFontSize(screenType);
      adaptiveStyle = theme.textTheme.titleMedium?.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color,
        backgroundColor: backgroundColor,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        shadows: shadows,
      );
    } else if (isBody) {
      final fontSize = _getAdaptiveBodyFontSize(screenType);
      adaptiveStyle = theme.textTheme.bodyMedium?.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        backgroundColor: backgroundColor,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        shadows: shadows,
      );
    } else if (isCaption) {
      final fontSize = _getAdaptiveCaptionFontSize(screenType);
      adaptiveStyle = theme.textTheme.bodySmall?.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        backgroundColor: backgroundColor,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        shadows: shadows,
      );
    } else if (isLabel) {
      final fontSize = _getAdaptiveLabelFontSize(screenType);
      adaptiveStyle = theme.textTheme.labelMedium?.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color,
        backgroundColor: backgroundColor,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        shadows: shadows,
      );
    } else {
      // Если не указан тип, используем переданный стиль или bodyMedium
      adaptiveStyle = style ?? theme.textTheme.bodyMedium?.copyWith(
        fontWeight: fontWeight,
        color: color,
        backgroundColor: backgroundColor,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        shadows: shadows,
      );
    }

    return Text(
      text,
      style: adaptiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Получить адаптивный размер шрифта для подзаголовка
  double _getAdaptiveSubtitleFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return UIConstants.fontSizeLarge;
      case ScreenType.mobile:
        return UIConstants.fontSizeXLarge;
      case ScreenType.tablet:
        return UIConstants.fontSizeXXLarge;
      case ScreenType.laptop:
        return UIConstants.fontSizeXLarge; // Уменьшили с title
      case ScreenType.desktop:
        return UIConstants.fontSizeXXLarge; // Уменьшили с headline
    }
  }

  /// Получить адаптивный размер шрифта для основного текста
  double _getAdaptiveBodyFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return UIConstants.fontSizeMedium;
      case ScreenType.mobile:
        return UIConstants.fontSizeLarge;
      case ScreenType.tablet:
        return UIConstants.fontSizeXLarge;
      case ScreenType.laptop:
        return UIConstants.fontSizeLarge; // Уменьшили с XXLarge
      case ScreenType.desktop:
        return UIConstants.fontSizeXLarge; // Уменьшили с title
    }
  }

  /// Получить адаптивный размер шрифта для подписи
  double _getAdaptiveCaptionFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return UIConstants.fontSizeSmall;
      case ScreenType.mobile:
        return UIConstants.fontSizeMedium;
      case ScreenType.tablet:
        return UIConstants.fontSizeLarge;
      case ScreenType.laptop:
        return UIConstants.fontSizeMedium; // Уменьшили с XLarge
      case ScreenType.desktop:
        return UIConstants.fontSizeLarge; // Уменьшили с XXLarge
    }
  }

  /// Получить адаптивный размер шрифта для меток
  double _getAdaptiveLabelFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return UIConstants.fontSizeSmall;
      case ScreenType.mobile:
        return UIConstants.fontSizeMedium;
      case ScreenType.tablet:
        return UIConstants.fontSizeLarge;
      case ScreenType.laptop:
        return UIConstants.fontSizeMedium; // Уменьшили с XLarge
      case ScreenType.desktop:
        return UIConstants.fontSizeLarge; // Уменьшили с XXLarge
    }
  }
}

/// Адаптивный заголовок
class AdaptiveTitle extends StatelessWidget {
  const AdaptiveTitle(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return AdaptiveText(
      text,
      isTitle: true,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Адаптивный подзаголовок
class AdaptiveSubtitle extends StatelessWidget {
  const AdaptiveSubtitle(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return AdaptiveText(
      text,
      isSubtitle: true,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Адаптивный основной текст
class AdaptiveBody extends StatelessWidget {
  const AdaptiveBody(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return AdaptiveText(
      text,
      isBody: true,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Адаптивная подпись
class AdaptiveCaption extends StatelessWidget {
  const AdaptiveCaption(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return AdaptiveText(
      text,
      isCaption: true,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Адаптивная метка
class AdaptiveLabel extends StatelessWidget {
  const AdaptiveLabel(
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return AdaptiveText(
      text,
      isLabel: true,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Адаптивная кнопка
class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenType = ScreenTypeHelper.getScreenTypeFromContext(context);
    
    double height;
    EdgeInsets padding;
    double borderRadius;
    
    switch (screenType) {
      case ScreenType.phone:
        height = UIConstants.buttonHeight;
        padding = const EdgeInsets.symmetric(
          horizontal: UIConstants.spacing16,
          vertical: UIConstants.spacing8,
        );
        borderRadius = UIConstants.radius12;
        break;
      case ScreenType.mobile:
        height = UIConstants.buttonHeight;
        padding = const EdgeInsets.symmetric(
          horizontal: UIConstants.spacing20,
          vertical: UIConstants.spacing10,
        );
        borderRadius = UIConstants.radius16;
        break;
      case ScreenType.tablet:
        height = UIConstants.largeButtonHeight;
        padding = const EdgeInsets.symmetric(
          horizontal: UIConstants.spacing24,
          vertical: UIConstants.spacing12,
        );
        borderRadius = UIConstants.radius20;
        break;
      case ScreenType.laptop:
      case ScreenType.desktop:
        height = UIConstants.largeButtonHeight;
        padding = const EdgeInsets.symmetric(
          horizontal: UIConstants.spacing28,
          vertical: UIConstants.spacing14,
        );
        borderRadius = UIConstants.radius24;
        break;
    }

    return AnimatedContainer(
      duration: UIConstants.mediumAnimation,
      curve: Curves.easeInOut,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: onPressed != null
                    ? [
                        colorScheme.primary.withOpacity(0.8),
                        colorScheme.primary.withOpacity(0.6),
                      ]
                    : [
                        colorScheme.surface.withOpacity(0.3),
                        colorScheme.surface.withOpacity(0.2),
                      ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: onPressed != null
                    ? colorScheme.primary.withOpacity(0.3)
                    : colorScheme.outline.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: onPressed != null
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Container(
                  padding: padding,
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: GlassLoading(),
                          )
                        : DefaultTextStyle(
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: onPressed != null
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ) ?? const TextStyle(),
                            child: child,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
