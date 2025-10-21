import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_icon_button.dart';

/// Базовый диалог в стиле glassmorphism
class GlassDialog extends StatelessWidget {
  const GlassDialog({
    super.key,
    required this.title,
    required this.child,
    this.width,
    this.height,
    this.onCancel,
    this.onConfirm,
  });

  final String title;
  final Widget child;
  final double? width;
  final double? height;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: width ?? 400,
            height: height,
            decoration: BoxDecoration(
              // Более полупрозрачный фон для выраженного glass-эффекта
              color: cs.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.primary.withValues(alpha: 0.25), width: 1),
              
              
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Заголовок
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      if (onConfirm != null) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GlassIconButton(
                            icon: Icons.check_rounded,
                            tooltip: 'Сохранить',
                            onPressed: () {
                              Navigator.of(context).pop();
                              onConfirm?.call();
                            },
                          ),
                        ),
                      ],
                      GlassIconButton(
                        icon: Icons.close_rounded,
                        tooltip: 'Закрыть',
                        color: Colors.red.withValues(alpha: 0.8),
                        onPressed: () {
                          Navigator.of(context).pop();
                          onCancel?.call();
                        },
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: cs.outline.withValues(alpha: 0.2),
                  height: 1,
                ),
                
                // Содержимое
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: child,
                  ),
                ),
                
                // Нижняя строка с кнопками удалена; используем иконку сохранения в шапке
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Утилиты для показа GlassDialog
class GlassDialogUtils {
  /// Показать диалог
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    required String title,
    double? width,
    double? height,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => GlassDialog(
        title: title,
        width: width,
        height: height,
        child: child,
      ),
    );
  }

  /// Показать диалог подтверждения
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    bool barrierDismissible = true,
  }) {
    return show<bool>(
      context: context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
