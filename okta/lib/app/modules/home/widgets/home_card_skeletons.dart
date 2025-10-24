import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/ui_constants.dart';

/// Скелетон для карточки HomeCard
class HomeCardSkeleton extends StatelessWidget {
  const HomeCardSkeleton({
    super.key,
    this.height = 300,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Shimmer.fromColors(
        baseColor: UIConstants.skeletonBaseColor(context),
        highlightColor: UIConstants.skeletonHighlightColor(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с иконкой
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: UIConstants.skeletonBaseColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: UIConstants.skeletonBaseColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Контент
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Строки контента
                    for (int i = 0; i < 4; i++) ...[
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: UIConstants.skeletonBaseColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    const Spacer(),
                    
                    // Статистический блок
                    Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        color: UIConstants.skeletonBaseColor(context),
                        borderRadius: BorderRadius.circular(8),
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

/// Скелетон для карточки профиля (аватар)
class HomeCardProfileSkeleton extends StatelessWidget {
  const HomeCardProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Shimmer.fromColors(
        baseColor: UIConstants.skeletonBaseColor(context),
        highlightColor: UIConstants.skeletonHighlightColor(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: UIConstants.skeletonBaseColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 60,
                    height: 20,
                    decoration: BoxDecoration(
                      color: UIConstants.skeletonBaseColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Центрированный аватар
              Expanded(
                child: Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: UIConstants.skeletonBaseColor(context),
                      shape: BoxShape.circle,
                    ),
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

/// Скелетон для карточки "О себе"
class HomeCardWelcomeSkeleton extends StatelessWidget {
  const HomeCardWelcomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Shimmer.fromColors(
        baseColor: UIConstants.skeletonBaseColor(context),
        highlightColor: UIConstants.skeletonHighlightColor(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: UIConstants.skeletonBaseColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 60,
                    height: 20,
                    decoration: BoxDecoration(
                      color: UIConstants.skeletonBaseColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Контент
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Строки информации
                    for (int i = 0; i < 6; i++) ...[
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: UIConstants.skeletonBaseColor(context),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 60,
                            height: 16,
                            decoration: BoxDecoration(
                              color: UIConstants.skeletonBaseColor(context),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: UIConstants.skeletonBaseColor(context),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Статусный контейнер
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: UIConstants.skeletonBaseColor(context),
                        borderRadius: BorderRadius.circular(8),
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
