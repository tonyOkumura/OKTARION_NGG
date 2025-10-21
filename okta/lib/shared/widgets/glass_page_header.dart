import 'dart:ui';

import 'package:flutter/material.dart';

class GlassPageHeader extends StatelessWidget {
  const GlassPageHeader({
    super.key,
    this.leading,
    this.middle,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final Widget? leading;
  final Widget? middle;
  final List<Widget>? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
          padding: padding,
          child: Row(
            children: [
              if (leading != null) leading!,
              if (leading != null) const SizedBox(width: 8),
              if (middle != null) ...[
                Expanded(child: middle!),
                const SizedBox(width: 8),
              ] else ...[
                const Spacer(),
              ],
              ..._buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTrailing() {
    final items = trailing ?? const <Widget>[];
    if (items.isEmpty) return const <Widget>[];
    final spaced = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) spaced.add(const SizedBox(width: 8));
      spaced.add(items[i]);
    }
    return spaced;
  }
}
