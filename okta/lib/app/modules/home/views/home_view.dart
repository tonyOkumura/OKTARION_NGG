import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../../../shared/widgets/widgets.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: GlassLoading());
      }
      if (controller.errorText.value != null) {
        return Center(child: Text(controller.errorText.value!));
      }
      
      final theme = Theme.of(context);
      final cs = theme.colorScheme;
      
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
            ),
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxW = constraints.maxWidth;
                    const double spacing = 16;
                    const double minTileWidth = 420;

                    int cols = math.max(
                      1,
                      ((maxW + spacing) / (minTileWidth + spacing)).floor(),
                    );
                    final items = <Widget>[
                      const HomeCardProfile(),
                      const HomeCardWelcome(),
                      const HomeCardTasksOverview(),
                      const HomeCardMessagesPreview(),
                      const HomeCardCalendar(),
                      const HomeCardNotifications(),
                    ];

                    cols = cols.clamp(1, items.length);
                    final double fullRowTileWidth =
                        (maxW - spacing * (cols - 1)) / cols;

                    final int fullRows = items.length ~/ cols;
                    final int remainder = items.length % cols;
                    final double lastRowTileWidth = remainder > 0
                        ? (maxW - spacing * (remainder - 1)) / remainder
                        : fullRowTileWidth;

                    final List<double> widths = List<double>.generate(
                      items.length,
                      (i) {
                        final bool isLastRow =
                            (remainder > 0) && (i >= fullRows * cols);
                        return isLastRow ? lastRowTileWidth : fullRowTileWidth;
                      },
                    );

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (int i = 0; i < items.length; i++)
                          SizedBox(width: widths[i], child: items[i]),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Карточка профиля
class HomeCardProfile extends StatelessWidget {
  const HomeCardProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return HomeCard(
      title: 'Профиль',
      icon: Icons.person_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassAvatar(
                label: 'John Doe',
                radius: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'john.doe@example.com',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Активен',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Проекты',
                  value: '12',
                  icon: Icons.folder_outlined,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  label: 'Задачи',
                  value: '8',
                  icon: Icons.check_circle_outline,
                  color: cs.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Карточка приветствия
class HomeCardWelcome extends StatelessWidget {
  const HomeCardWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return HomeCard(
      title: 'Добро пожаловать',
      icon: Icons.home_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              Icons.dashboard_outlined,
              color: cs.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'OKTARION Dashboard',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ваш персональный дашборд готов к работе. Здесь вы можете управлять всеми аспектами вашей деятельности.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Все системы работают нормально',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          _TaskItem(
            title: 'Завершить проект Alpha',
            priority: 'Высокий',
            priorityColor: cs.error,
            progress: 0.75,
          ),
          const SizedBox(height: 8),
          _TaskItem(
            title: 'Обновить документацию',
            priority: 'Средний',
            priorityColor: cs.primary,
            progress: 0.4,
          ),
          const SizedBox(height: 8),
          _TaskItem(
            title: 'Провести код-ревью',
            priority: 'Низкий',
            priorityColor: cs.secondary,
            progress: 0.9,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.secondary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.timeline, color: cs.secondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '12 активных задач',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  const _TaskItem({
    required this.title,
    required this.priority,
    required this.priorityColor,
    required this.progress,
  });

  final String title;
  final String priority;
  final Color priorityColor;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  priority,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(priorityColor),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).round()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

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
          _MessageItem(
            sender: 'Анна Петрова',
            message: 'Привет! Как дела с проектом?',
            time: '10:30',
            isUnread: true,
          ),
          const SizedBox(height: 8),
          _MessageItem(
            sender: 'Михаил Иванов',
            message: 'Отправил отчет по задаче #123',
            time: '09:15',
            isUnread: true,
          ),
          const SizedBox(height: 8),
          _MessageItem(
            sender: 'Елена Сидорова',
            message: 'Спасибо за помощь с кодом!',
            time: 'Вчера',
            isUnread: false,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.tertiary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.mark_email_unread, color: cs.tertiary, size: 20),
                const SizedBox(width: 8),
                Expanded(
        child: Text(
                    '7 непрочитанных сообщений',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageItem extends StatelessWidget {
  const _MessageItem({
    required this.sender,
    required this.message,
    required this.time,
    required this.isUnread,
  });

  final String sender;
  final String message;
  final String time;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnread 
            ? cs.tertiaryContainer.withOpacity(0.2)
            : cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnread 
              ? cs.tertiary.withOpacity(0.3)
              : cs.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: cs.tertiary.withOpacity(0.3),
                child: Text(
                  sender[0].toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sender,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Text(
                time,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

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
          _EventItem(
            title: 'Совещание команды',
            time: '14:00',
            date: 'Сегодня',
            color: cs.primary,
          ),
          const SizedBox(height: 8),
          _EventItem(
            title: 'Презентация проекта',
            time: '16:30',
            date: 'Завтра',
            color: cs.secondary,
          ),
          const SizedBox(height: 8),
          _EventItem(
            title: 'Код-ревью',
            time: '10:00',
            date: 'Пт, 15 мар',
            color: cs.tertiary,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '2 события сегодня',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventItem extends StatelessWidget {
  const _EventItem({
    required this.title,
    required this.time,
    required this.date,
    required this.color,
  });

  final String title;
  final String time;
  final String date;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$time • $date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          _NotificationItem(
            title: 'Новая задача назначена',
            message: 'Вам назначена задача "Обновить API"',
            time: '5 мин назад',
            type: 'task',
            color: cs.primary,
          ),
          const SizedBox(height: 8),
          _NotificationItem(
            title: 'Сообщение от команды',
            message: 'Анна Петрова отправила сообщение',
            time: '15 мин назад',
            type: 'message',
            color: cs.secondary,
          ),
          const SizedBox(height: 8),
          _NotificationItem(
            title: 'Системное уведомление',
            message: 'Обновление системы завершено',
            time: '1 час назад',
            type: 'system',
            color: cs.tertiary,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.error.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active, color: cs.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '5 новых уведомлений',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.color,
  });

  final String title;
  final String message;
  final String time;
  final String type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    IconData icon;
    switch (type) {
      case 'task':
        icon = Icons.assignment;
        break;
      case 'message':
        icon = Icons.message;
        break;
      case 'system':
        icon = Icons.settings;
        break;
      default:
        icon = Icons.notifications;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
