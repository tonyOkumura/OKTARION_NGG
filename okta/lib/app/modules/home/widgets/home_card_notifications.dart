import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';
import 'home_common_widgets.dart';

/// Карточка уведомлений
class HomeCardNotifications extends StatelessWidget {
  const HomeCardNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return HomeCard(
      title: 'Уведомления',
      icon: Icons.notifications_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_outlined, color: cs.error, size: 24),
              const SizedBox(width: 8),
              Text(
                'Последние уведомления',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NotificationItem(
            title: 'Новая задача назначена',
            message: 'Вам назначена задача "Обновить API"',
            time: '5 мин назад',
            type: 'task',
            color: cs.primary,
          ),
          const SizedBox(height: 8),
          NotificationItem(
            title: 'Сообщение от команды',
            message: 'Анна Петрова отправила сообщение',
            time: '15 мин назад',
            type: 'message',
            color: cs.secondary,
          ),
          const SizedBox(height: 8),
          NotificationItem(
            title: 'Системное уведомление',
            message: 'Обновление системы завершено',
            time: '1 час назад',
            type: 'system',
            color: cs.tertiary,
          ),
          const SizedBox(height: 16),
          StatsBlock(
            icon: Icons.notifications_active,
            text: '5 новых уведомлений',
            backgroundColor: cs.errorContainer,
            borderColor: cs.error,
            iconColor: cs.error,
            textColor: cs.onErrorContainer,
          ),
        ],
      ),
    );
  }
}
