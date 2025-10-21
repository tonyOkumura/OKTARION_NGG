import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/core.dart';

class GlassVersionCard extends StatelessWidget {
  const GlassVersionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(UIConstants.radius12),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacing12,
            vertical: UIConstants.spacing8,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(UIConstants.radius12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            'v${AppConstants.appVersion}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
