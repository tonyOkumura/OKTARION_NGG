import 'package:flutter/material.dart';

import '../../core/core.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({
    super.key,
    required this.active,
    required this.icon,
    required this.tooltip,
    required this.colorScheme,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String tooltip;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AnimatedContainer(
        duration: UIConstants.mediumAnimation,
        decoration: BoxDecoration(
          color: active
              ? colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.radius12),
          border: Border.all(
            color: active
                ? colorScheme.primary.withValues(alpha: 0.35)
                : colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: IconButton(
          onPressed: onTap,
          icon: AnimatedSwitcher(
            duration: UIConstants.mediumAnimation,
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Icon(
              icon,
              key: ValueKey<bool>(active),
              color: active
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
