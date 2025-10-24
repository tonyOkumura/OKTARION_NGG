import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';
import 'home_common_widgets.dart';

/// Карточка обзора задач
class HomeCardTasksOverview extends StatelessWidget {
  const HomeCardTasksOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return HomeCard(
      title: 'Задачи',
      icon: Icons.task_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: cs.secondary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Активные задачи',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProgressItem(
            title: 'Завершить проект Alpha',
            priority: 'Высокий',
            priorityColor: cs.error,
            progress: 0.75,
          ),
          const SizedBox(height: 8),
          ProgressItem(
            title: 'Обновить документацию',
            priority: 'Средний',
            priorityColor: cs.primary,
            progress: 0.4,
          ),
          const SizedBox(height: 8),
          ProgressItem(
            title: 'Провести код-ревью',
            priority: 'Низкий',
            priorityColor: cs.secondary,
            progress: 0.9,
          ),
          const SizedBox(height: 16),
          StatsBlock(
            icon: Icons.timeline,
            text: '12 активных задач',
            backgroundColor: cs.secondaryContainer,
            borderColor: cs.secondary,
            iconColor: cs.secondary,
            textColor: cs.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}
