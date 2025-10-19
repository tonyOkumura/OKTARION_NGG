import 'dart:ui';
import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.blurSigma = 18.0,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blurSigma;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEnabled = onPressed != null && !isLoading;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor ?? 
                    (isEnabled 
                        ? cs.surface.withValues(alpha: 0.7)
                        : cs.surface.withValues(alpha: 0.3)),
                borderRadius: borderRadius ?? BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor ?? 
                      (isEnabled 
                          ? cs.outline.withValues(alpha: 0.15)
                          : cs.outline.withValues(alpha: 0.05)),
                ),
                boxShadow: isEnabled ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                      ),
                    )
                  : child,
            ),
          ),
        ),
      ),
    );
  }
}
