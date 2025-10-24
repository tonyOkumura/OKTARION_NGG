import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';
import 'home_common_widgets.dart';

/// Карточка календаря
class HomeCardCalendar extends StatelessWidget {
  const HomeCardCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return HomeCard(
      title: 'События',
      icon: Icons.event_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_outlined, color: cs.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Ближайшие события',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          EventItem(
            title: 'Совещание команды',
            time: '14:00',
            date: 'Сегодня',
            color: cs.primary,
          ),
          const SizedBox(height: 8),
          EventItem(
            title: 'Презентация проекта',
            time: '16:30',
            date: 'Завтра',
            color: cs.secondary,
          ),
          const SizedBox(height: 8),
          EventItem(
            title: 'Код-ревью',
            time: '10:00',
            date: 'Пт, 15 мар',
            color: cs.tertiary,
          ),
          const SizedBox(height: 16),
          StatsBlock(
            icon: Icons.calendar_today,
            text: '2 события сегодня',
            backgroundColor: cs.primaryContainer,
            borderColor: cs.primary,
            iconColor: cs.primary,
            textColor: cs.onPrimaryContainer,
          ),
        ],
      ),
    );
  }
}
