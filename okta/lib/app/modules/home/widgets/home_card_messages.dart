import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';
import 'home_common_widgets.dart';

/// Карточка превью сообщений
class HomeCardMessagesPreview extends StatelessWidget {
  const HomeCardMessagesPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return HomeCard(
      title: 'Сообщения',
      icon: Icons.message_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: cs.tertiary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Последние сообщения',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MessageItem(
            sender: 'Анна Петрова',
            message: 'Привет! Как дела с проектом?',
            time: '10:30',
            isUnread: true,
          ),
          const SizedBox(height: 8),
          MessageItem(
            sender: 'Михаил Иванов',
            message: 'Отправил отчет по задаче #123',
            time: '09:15',
            isUnread: true,
          ),
          const SizedBox(height: 8),
          MessageItem(
            sender: 'Елена Сидорова',
            message: 'Спасибо за помощь с кодом!',
            time: 'Вчера',
            isUnread: false,
          ),
          const SizedBox(height: 16),
          StatsBlock(
            icon: Icons.mark_email_unread,
            text: '7 непрочитанных сообщений',
            backgroundColor: cs.tertiaryContainer,
            borderColor: cs.tertiary,
            iconColor: cs.tertiary,
            textColor: cs.onTertiaryContainer,
          ),
        ],
      ),
    );
  }
}
