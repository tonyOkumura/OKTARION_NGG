import 'dart:ui';

import 'package:flutter/material.dart';
import 'glass_loading.dart';

/// Стеклянное уведомление с эффектом размытия
/// Предоставляет красивый UI для отображения уведомлений
class GlassNotification extends StatelessWidget {
  const GlassNotification({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.color,
    this.onClose,
    this.progress,
    this.breath,
    this.closingT,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onClose;
  final double? progress; // 0.0..1.0 remaining fraction
  final double? breath; // 0..1 breathing phase
  final double? closingT; // 0..1 fade scale factor for last ~360ms

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedColor = color ?? theme.colorScheme.primary;
    final baseOutline = theme.colorScheme.outline.withValues(alpha: 0.15);
    final fadeTarget = resolvedColor.withValues(alpha: 0.7);
    final t = (progress ?? 1.0).clamp(0.0, 1.0);
    final dynamicBorderColor = Color.lerp(baseOutline, fadeTarget, t)!;
    final glowPhase = (breath ?? 1.0).clamp(0.0, 1.0);
    final glowColor = resolvedColor.withValues(
      alpha: 0.18 + 0.18 * glowPhase * t,
    );
    final closePhase = (closingT ?? 1.0).clamp(0.0, 1.0);
    final contentOpacity = 0.6 + 0.4 * closePhase;
    final iconScale = 0.9 + 0.1 * closePhase;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 380,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dynamicBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: glowColor,
                blurRadius: 22 + 10 * glowPhase,
                spreadRadius: 0.5 + 0.8 * glowPhase,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Аккуратный стеклянный лоадер вместо размытого фона под иконкой
                    GlassLoading(
                      size: 36,
                      color: resolvedColor.withValues(alpha: 0.9),
                    ),
                    Transform.scale(
                      scale: iconScale,
                      child: Icon(icon ?? Icons.info, color: resolvedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Opacity(
                  opacity: contentOpacity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (message != null && message!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(message!, style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: contentOpacity,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 18,
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
