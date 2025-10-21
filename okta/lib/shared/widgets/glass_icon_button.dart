import 'package:flutter/material.dart';

/// Универсальная иконка-кнопка в стиле glass
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 18,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = 8,
    this.color,
    this.backgroundColor,
    this.borderColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final Color resolvedBg = backgroundColor ?? cs.primary.withValues(alpha: 0.1);
    final Color resolvedBorder = borderColor ?? cs.primary.withValues(alpha: 0.3);
    final Color resolvedIcon = color ?? cs.primary;

    final button = Container(
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: resolvedBorder,
          width: 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: Icon(
              icon,
              size: size,
              color: resolvedIcon,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    return button;
  }
}


