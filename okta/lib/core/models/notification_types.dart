import 'package:flutter/material.dart';

import '../utils/accent_colors_helper.dart';

/// Типы уведомлений
enum NotificationType {
  success,
  error,
  warning,
  info,
  loading,
}

/// Конфигурация уведомления
class NotificationConfig {
  final String title;
  final String? message;
  final NotificationType type;
  final Duration? duration;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final Map<String, dynamic>? data;
  final Color? color; // Дополнительный цвет для кастомизации

  const NotificationConfig({
    required this.title,
    this.message,
    this.type = NotificationType.info,
    this.duration,
    this.onTap,
    this.onClose,
    this.data,
    this.color,
  });

  /// Создание уведомления об успехе
  factory NotificationConfig.success({
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
    VoidCallback? onClose,
    Map<String, dynamic>? data,
    Color? color,
  }) {
    return NotificationConfig(
      title: title,
      message: message,
      type: NotificationType.success,
      duration: duration ?? const Duration(seconds: 3),
      onTap: onTap,
      onClose: onClose,
      data: data,
      color: color,
    );
  }

  /// Создание уведомления об ошибке
  factory NotificationConfig.error({
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
    VoidCallback? onClose,
    Map<String, dynamic>? data,
    Color? color,
  }) {
    return NotificationConfig(
      title: title,
      message: message,
      type: NotificationType.error,
      duration: duration ?? const Duration(seconds: 5),
      onTap: onTap,
      onClose: onClose,
      data: data,
      color: color,
    );
  }

  /// Создание предупреждающего уведомления
  factory NotificationConfig.warning({
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
    VoidCallback? onClose,
    Map<String, dynamic>? data,
    Color? color,
  }) {
    return NotificationConfig(
      title: title,
      message: message,
      type: NotificationType.warning,
      duration: duration ?? const Duration(seconds: 4),
      onTap: onTap,
      onClose: onClose,
      data: data,
      color: color,
    );
  }

  /// Создание информационного уведомления
  factory NotificationConfig.info({
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
    VoidCallback? onClose,
    Map<String, dynamic>? data,
    Color? color,
  }) {
    return NotificationConfig(
      title: title,
      message: message,
      type: NotificationType.info,
      duration: duration ?? const Duration(seconds: 3),
      onTap: onTap,
      onClose: onClose,
      data: data,
      color: color,
    );
  }

  /// Создание уведомления с загрузкой
  factory NotificationConfig.loading({
    required String title,
    String? message,
    VoidCallback? onClose,
    Map<String, dynamic>? data,
    Color? color,
  }) {
    return NotificationConfig(
      title: title,
      message: message,
      type: NotificationType.loading,
      duration: null, // Загрузка не исчезает автоматически
      onClose: onClose,
      data: data,
      color: color,
    );
  }

  /// Получение иконки для типа уведомления
  IconData get icon {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.loading:
        return Icons.hourglass_empty;
    }
  }

  /// Получение цвета для типа уведомления
  /// Если передан кастомный цвет, используем его, иначе стандартный
  Color getColor(BuildContext context) {
    if (color != null) return color!;
    
    switch (type) {
      case NotificationType.success:
        return AccentColorsHelper.getAccentColorByIndex(context, 3); // Зеленый акцент
      case NotificationType.error:
        return AccentColorsHelper.getAccentColorByIndex(context, 0); // Красный акцент
      case NotificationType.warning:
        return AccentColorsHelper.getAccentColorByIndex(context, 1); // Оранжевый акцент
      case NotificationType.info:
        return AccentColorsHelper.getAccentColorByIndex(context, 2); // Синий акцент
      case NotificationType.loading:
        return AccentColorsHelper.getAccentColorByIndex(context, 4); // Фиолетовый акцент
    }
  }

  
}
