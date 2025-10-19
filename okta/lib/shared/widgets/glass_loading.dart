import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Стеклянный лоадер с анимацией
/// Используется в уведомлениях и других UI компонентах
class GlassLoading extends StatelessWidget {
  const GlassLoading({
    super.key,
    this.size = 44,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final Color ringColor = color ?? cs.primary;

    return LoadingAnimationWidget.threeArchedCircle(
      color: ringColor,
      size: size,
    );
  }
}
