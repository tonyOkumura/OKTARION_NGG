import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Скелетон для ContactTile во время загрузки
class ContactTileSkeleton extends StatelessWidget {
  final EdgeInsetsGeometry? padding;

  const ContactTileSkeleton({
    super.key,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Shimmer.fromColors(
          baseColor: cs.surfaceVariant.withValues(alpha: 0.3),
          highlightColor: cs.surfaceVariant.withValues(alpha: 0.6),
          child: Row(
            children: [
              // Скелетон аватара
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Скелетон текста
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Скелетон имени
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Скелетон username
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Скелетон статуса (не всегда есть)
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: cs.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
