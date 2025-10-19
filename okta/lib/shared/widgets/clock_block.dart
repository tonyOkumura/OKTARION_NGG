import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../core/core.dart';

class ClockBlock extends StatelessWidget {
  const ClockBlock({
    super.key,
    required this.time,
    required this.dateLine,
    required this.colorScheme,
    this.seconds,
  });

  final String time;
  final String dateLine;
  final ColorScheme colorScheme;
  final int? seconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenType = ScreenTypeHelper.getScreenTypeFromContext(context);

    // Определяем, что показывать в зависимости от размера экрана
    final clockConfig = _getClockConfig(screenType);
    final shouldShowSeconds = _shouldShowSeconds(screenType);
    final shouldShowWeekday = _shouldShowWeekday(screenType);
    final shouldShowDayMonth = _shouldShowDayMonth(screenType);

    return AnimatedContainer(
      duration: UIConstants.mediumAnimation,
      curve: Curves.easeInOut,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(clockConfig.borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: clockConfig.blurRadius, sigmaY: clockConfig.blurRadius),
          child: Container(
            padding: clockConfig.padding,
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(clockConfig.backgroundOpacity),
              borderRadius: BorderRadius.circular(clockConfig.borderRadius),
              border: Border.all(
                color: colorScheme.outline.withOpacity(clockConfig.borderOpacity),
                width: clockConfig.borderWidth,
              ),
            ),
            child: AnimatedSize(
              duration: UIConstants.mediumAnimation,
              curve: Curves.easeInOut,
              child: _buildClockContent(
                theme, 
                clockConfig, 
                shouldShowSeconds, 
                shouldShowWeekday, 
                shouldShowDayMonth
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Определить, показывать ли секунды
  bool _shouldShowSeconds(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return false; // На телефонах не показываем секунды
      case ScreenType.mobile:
        return false; // На мобильных не показываем секунды
      case ScreenType.tablet:
        return true; // На планшетах показываем
      case ScreenType.laptop:
        return true; // На ноутбуках показываем
      case ScreenType.desktop:
        return true; // На десктопах показываем
    }
  }

  /// Определить, показывать ли день недели
  bool _shouldShowWeekday(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return false; // На телефонах не показываем день недели
      case ScreenType.mobile:
        return false; // На мобильных не показываем день недели
      case ScreenType.tablet:
        return false; // На планшетах не показываем (сначала скрываем понедельник)
      case ScreenType.laptop:
        return true; // На ноутбуках показываем
      case ScreenType.desktop:
        return true; // На десктопах показываем
    }
  }

  /// Определить, показывать ли день и месяц
  bool _shouldShowDayMonth(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return true; // На телефонах показываем день и месяц
      case ScreenType.mobile:
        return true; // На мобильных показываем день и месяц
      case ScreenType.tablet:
        return true; // На планшетах показываем
      case ScreenType.laptop:
        return true; // На ноутбуках показываем
      case ScreenType.desktop:
        return true; // На десктопах показываем
    }
  }

  /// Получить конфигурацию часов для типа экрана
  _ClockConfig _getClockConfig(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.phone:
        return _ClockConfig(
          timeFontSize: UIConstants.clockTimeFontSizeCompact,
          dateFontSize: UIConstants.clockTimeFontSizeCompact * 0.4, // Пропорционально времени
          secondsFontSize: UIConstants.clockTimeFontSizeCompact * 0.6,
          padding: UIConstants.clockPaddingCompact,
          spacing: UIConstants.clockSpacingCompact,
          borderRadius: UIConstants.radius20,
          blurRadius: 20,
          backgroundOpacity: 0.25,
          borderOpacity: 0.1,
          borderWidth: 1,
        );
      case ScreenType.mobile:
        return _ClockConfig(
          timeFontSize: UIConstants.clockTimeFontSizeMedium,
          dateFontSize: UIConstants.clockTimeFontSizeMedium * 0.4, // Пропорционально времени
          secondsFontSize: UIConstants.clockTimeFontSizeMedium * 0.6,
          padding: UIConstants.clockPaddingMedium,
          spacing: UIConstants.clockSpacingMedium,
          borderRadius: UIConstants.radius20,
          blurRadius: 20,
          backgroundOpacity: 0.25,
          borderOpacity: 0.1,
          borderWidth: 1,
        );
      case ScreenType.tablet:
        return _ClockConfig(
          timeFontSize: UIConstants.clockTimeFontSizeLarge,
          dateFontSize: UIConstants.clockTimeFontSizeLarge * 0.4, // Пропорционально времени
          secondsFontSize: UIConstants.clockTimeFontSizeLarge * 0.6,
          padding: UIConstants.clockPaddingLarge,
          spacing: UIConstants.clockSpacingLarge,
          borderRadius: UIConstants.radius20,
          blurRadius: 20,
          backgroundOpacity: 0.25,
          borderOpacity: 0.1,
          borderWidth: 1,
        );
      case ScreenType.laptop:
        return _ClockConfig(
          timeFontSize: UIConstants.clockTimeFontSizeLarge + 8,
          dateFontSize: (UIConstants.clockTimeFontSizeLarge + 8) * 0.4, // Пропорционально времени
          secondsFontSize: (UIConstants.clockTimeFontSizeLarge + 8) * 0.6,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          spacing: 20,
          borderRadius: UIConstants.radius20,
          blurRadius: 20,
          backgroundOpacity: 0.25,
          borderOpacity: 0.1,
          borderWidth: 1,
        );
      case ScreenType.desktop:
        return _ClockConfig(
          timeFontSize: UIConstants.clockTimeFontSizeLarge + 16,
          dateFontSize: (UIConstants.clockTimeFontSizeLarge + 16) * 0.4, // Пропорционально времени
          secondsFontSize: (UIConstants.clockTimeFontSizeLarge + 16) * 0.6,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          spacing: 24,
          borderRadius: UIConstants.radius20,
          blurRadius: 20,
          backgroundOpacity: 0.25,
          borderOpacity: 0.1,
          borderWidth: 1,
        );
    }
  }

  /// Построить содержимое часов в одну строчку
  Widget _buildClockContent(
    ThemeData theme, 
    _ClockConfig config, 
    bool showSeconds, 
    bool showWeekday, 
    bool showDayMonth
  ) {
    final List<Widget> children = [];

    // Время
    children.add(
      Text(
        time,
        style: theme.textTheme.displayLarge?.copyWith(
          fontSize: config.timeFontSize,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          height: 1.0, // Фиксированная высота строки
        ),
      ),
    );

    // Секунды (если нужно)
    if (showSeconds && seconds != null) {
      children.add(
        SizedBox(width: config.spacing * 0.2),
      );
      children.add(
        AnimatedSwitcher(
          duration: UIConstants.shortAnimation,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: child,
            ),
          ),
          child: Text(
            ':${seconds.toString().padLeft(2, '0')}',
            key: ValueKey('seconds'),
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: config.timeFontSize, // Тот же размер что и время
              fontWeight: FontWeight.w700, // Тот же вес что и время
              color: colorScheme.onSurface.withOpacity(0.7),
              height: 1.0, // Фиксированная высота строки
            ),
          ),
        ),
      );
    }

    // День недели (если нужно)
    if (showWeekday) {
      children.add(
        SizedBox(width: config.spacing),
      );
      children.add(
        AnimatedSwitcher(
          duration: UIConstants.shortAnimation,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: child,
            ),
          ),
          child: Text(
            DateFormatter.formatWeekday(DateTime.now()),
            key: ValueKey('weekday'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: config.dateFontSize,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.0, // Фиксированная высота строки
            ),
          ),
        ),
      );
    }

    // День и месяц (если нужно)
    if (showDayMonth) {
      children.add(
        SizedBox(width: config.spacing),
      );
      children.add(
        AnimatedSwitcher(
          duration: UIConstants.shortAnimation,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: child,
            ),
          ),
          child: Text(
            DateFormatter.formatDayMonth(DateTime.now()),
            key: ValueKey('daymonth'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: config.dateFontSize,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.0, // Фиксированная высота строки
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: children,
    );
  }
}

/// Конфигурация часов
class _ClockConfig {
  const _ClockConfig({
    required this.timeFontSize,
    required this.dateFontSize,
    required this.secondsFontSize,
    required this.padding,
    required this.spacing,
    required this.borderRadius,
    required this.blurRadius,
    required this.backgroundOpacity,
    required this.borderOpacity,
    required this.borderWidth,
  });

  final double timeFontSize;
  final double dateFontSize;
  final double secondsFontSize;
  final EdgeInsets padding;
  final double spacing;
  final double borderRadius;
  final double blurRadius;
  final double backgroundOpacity;
  final double borderOpacity;
  final double borderWidth;
}