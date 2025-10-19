import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/core.dart';
import '../../core/enums/app_enums.dart';
import 'glass_loading.dart';

class GlassAvatar extends StatelessWidget {
  const GlassAvatar({
    super.key,
    required this.label,
    this.avatarUrl,
    this.radius = 16,
    this.backgroundColor,
    this.textColor,
    this.borderWidth = 0,
    this.borderColor,
  });

  final String label;
  final String? avatarUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderWidth;
  final Color? borderColor;

  static int _accentIndexForLabel(String label) {
    if (label.isEmpty) return 0;
    int hash = 0;
    for (final int codeUnit in label.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash % 5; // map to 5 accent slots
  }

  static String _computeInitials(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) {
      final first = parts[0].characters.first;
      return first.toUpperCase();
    }
    final first = parts[0].characters.first;
    final second = parts[1].characters.first;
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String initials = _computeInitials(label);
    final double diameter = radius * 2;
    final int idx = _accentIndexForLabel(label);
    final Color baseColor = textColor ?? AppTheme.values[idx].primaryColor;
    final Color bgColor = backgroundColor ?? baseColor.withOpacity(0.25);

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipOval(
            child: Container(
              color: bgColor,
              decoration: borderWidth > 0
                  ? BoxDecoration(
                      border: Border.all(
                        color: borderColor ?? baseColor,
                        width: borderWidth,
                      ),
                    )
                  : null,
            ),
          ),
          if (avatarUrl != null && avatarUrl!.isNotEmpty)
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                width: diameter,
                height: diameter,
                filterQuality: FilterQuality.medium,
                placeholder: (context, url) => Center(
                  child: GlassLoading(size: radius * 1.25, color: baseColor),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: textColor ?? baseColor,
                      fontWeight: FontWeight.w700,
                      fontSize: (radius * 0.85).clamp(10.0, 18.0),
                    ),
                  ),
                ),
                // Настройки кэширования
                memCacheWidth: diameter.toInt(),
                memCacheHeight: diameter.toInt(),
                maxWidthDiskCache: diameter.toInt(),
                maxHeightDiskCache: diameter.toInt(),
              ),
            ),
          if (avatarUrl == null || avatarUrl!.isEmpty)
            Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: textColor ?? baseColor,
                  fontWeight: FontWeight.w700,
                  fontSize: (radius * 0.85).clamp(10.0, 18.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
