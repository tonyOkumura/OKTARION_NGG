import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/log_service.dart';
import '../models/notification_types.dart';
import '../../shared/widgets/glass_notification.dart';

/// Сервис для управления уведомлениями
/// Предоставляет методы для показа различных типов уведомлений
class NotificationService {
  NotificationService._();
  
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final List<NotificationConfig> _notifications = [];
  Timer? _timer;
  OverlayEntry? _overlayEntry;

  /// Показать уведомление
  void show(NotificationConfig config) {
    LogService.i('📢 Showing notification: ${config.title}');
    
    _notifications.add(config);
    _updateOverlay();
    
    // Автоматическое скрытие (если не загрузка)
    if (config.type != NotificationType.loading && config.duration != null) {
      _timer?.cancel();
      _timer = Timer(config.duration!, () {
        _dismissLast();
      });
    }
  }

  /// Показать уведомление об успехе
  void showSuccess({
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
    VoidCallback? onClose,
    Map<String, dynamic>? data,
    Color? color,
  }) {
    show(NotificationConfig.success(
      title: title,
      message: message,
      duration: duration,
      onTap: onTap,
      onClose: onClose,
      data: data,
      color: color,
    ));
  }

  /// Показать уведомление об ошибке
  void showError({
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
    VoidCallback? onClose,
    Map<String, dynamic>? data,
    Color? color,
  }) {
    show(NotificationConfig.error(
      title: title,
      message: message,
      duration: duration,
      onTap: onTap,
      onClose: onClose,
      data: data,
      color: color,
    ));
  }

  /// Показать предупреждающее уведомление
  void showWarning({
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
    VoidCallback? onClose,
    Map<String, dynamic>? data,
    Color? color,
  }) {
    show(NotificationConfig.warning(
      title: title,
      message: message,
      duration: duration,
      onTap: onTap,
      onClose: onClose,
      data: data,
      color: color,
    ));
  }

  /// Показать информационное уведомление
  void showInfo({
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
    VoidCallback? onClose,
    Map<String, dynamic>? data,
    Color? color,
  }) {
    show(NotificationConfig.info(
      title: title,
      message: message,
      duration: duration,
      onTap: onTap,
      onClose: onClose,
      data: data,
      color: color,
    ));
  }

  /// Показать уведомление с загрузкой
  void showLoading({
    required String title,
    String? message,
    VoidCallback? onClose,
    Map<String, dynamic>? data,
    Color? color,
  }) {
    show(NotificationConfig.loading(
      title: title,
      message: message,
      onClose: onClose,
      data: data,
      color: color,
    ));
  }

  /// Скрыть последнее уведомление
  void _dismissLast() {
    if (_notifications.isNotEmpty) {
      final config = _notifications.removeLast();
      LogService.d('📢 Dismissing notification: ${config.title}');
      _updateOverlay();
    }
  }

  /// Скрыть все уведомления
  void dismissAll() {
    LogService.d('📢 Dismissing all notifications');
    _notifications.clear();
    _timer?.cancel();
    _updateOverlay();
  }

  /// Скрыть уведомления загрузки
  void dismissLoading() {
    _notifications.removeWhere((config) => config.type == NotificationType.loading);
    _updateOverlay();
  }

  /// Обновить overlay с уведомлениями
  void _updateOverlay() {
    if (Get.context == null) return;

    // Удаляем существующий overlay
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    if (_notifications.isEmpty) return;

    // Создаем новый overlay
    final overlay = Overlay.of(Get.overlayContext!);
    _overlayEntry = OverlayEntry(
      builder: (context) => _NotificationOverlay(
        notifications: _notifications,
        onDismiss: _dismissLast,
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  /// Получить количество активных уведомлений
  int get notificationCount => _notifications.length;

  /// Проверить, есть ли уведомления загрузки
  bool get hasLoadingNotifications => 
      _notifications.any((config) => config.type == NotificationType.loading);
}

/// Overlay для отображения уведомлений
class _NotificationOverlay extends StatelessWidget {
  const _NotificationOverlay({
    required this.notifications,
    required this.onDismiss,
  });

  final List<NotificationConfig> notifications;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: notifications.asMap().entries.map((entry) {
          final index = entry.key;
          final config = entry.value;
          
          return Padding(
            padding: EdgeInsets.only(bottom: index < notifications.length - 1 ? 8 : 0),
            child: _AnimatedNotification(
              config: config,
              onDismiss: () {
                NotificationService.instance._dismissLast();
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Анимированное уведомление
class _AnimatedNotification extends StatefulWidget {
  const _AnimatedNotification({
    required this.config,
    required this.onDismiss,
  });

  final NotificationConfig config;
  final VoidCallback onDismiss;

  @override
  State<_AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: widget.config.onTap,
              child: GlassNotification(
                title: widget.config.title,
                message: widget.config.message,
                icon: widget.config.icon,
                color: widget.config.color,
                onClose: () {
                  _controller.reverse().then((_) {
                    widget.onDismiss();
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
