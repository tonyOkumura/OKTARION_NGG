import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../../../shared/widgets/widgets.dart';
import '../../../../core/models/contact_model.dart';
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
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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

/// Карточка аватара
class HomeCardProfile extends GetView<HomeController> {
  const HomeCardProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => HomeCard(
      title: 'Аватар',
      icon: Icons.person_outline,
      child: Center(
        child: GlassAvatar(
          label: controller.userName.value ?? 'Пользователь',
          avatarUrl: controller.userAvatarUrl.value,
          radius: 150,
        ),
      ),
    ));
  }
}


/// Карточка "О себе"
class HomeCardWelcome extends GetView<HomeController> {
  const HomeCardWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Obx(() => Stack(
      children: [
        HomeCard(
          title: 'О себе',
          icon: Icons.person_outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Имя пользователя
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                'Имя:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.userName.value ?? 'Пользователь',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Статус активности
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 18,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              Text(
                'Статус:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Активен',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Основная информация
          _buildInfoRow(
            theme,
            cs,
            Icons.email_outlined,
            'Email',
            controller.userEmail.value ?? 'user@example.com',
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow(
            theme,
            cs,
            Icons.phone_outlined,
            'Телефон',
            controller.userPhone.value ?? '+7 (999) 123-45-67',
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow(
            theme,
            cs,
            Icons.work_outline,
            'Должность',
            controller.userPosition.value ?? 'Developer',
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow(
            theme,
            cs,
            Icons.business_outlined,
            'Отдел',
            controller.userDepartment.value ?? 'Разработка',
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow(
            theme,
            cs,
            Icons.business,
            'Компания',
            controller.userCompany.value ?? 'OKTARION',
          ),
          const SizedBox(height: 16),
          
          // Статус сообщение
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Статус сообщение',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  controller.userStatusMessage.value ?? 'Добро пожаловать! 👋',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
        // Плавающая кнопка "Изменить"
        Positioned(
          bottom: 16,
          right: 16,
          child: GlassIconButton(
            icon: Icons.edit_outlined,
            onPressed: () => _showEditDialog(context),
            tooltip: 'Редактировать',
          ),
        ),
      ],
    ));
  }

  void _showEditDialog(BuildContext context) {
    // Создаем временный контакт из данных пользователя
    final userContact = Contact(
      id: 'current-user',
      username: controller.userName.value?.split('@').first ?? 'user',
      firstName: controller.userName.value?.split(' ').first,
      lastName: controller.userName.value != null && controller.userName.value!.split(' ').length > 1 
          ? controller.userName.value!.split(' ').skip(1).join(' ')
          : null,
      displayName: controller.userName.value,
      email: controller.userEmail.value,
      phone: controller.userPhone.value,
      isOnline: true,
      lastSeenAt: DateTime.now(),
      statusMessage: controller.userStatusMessage.value,
      role: 'user',
      department: controller.userDepartment.value,
      rank: null,
      position: controller.userPosition.value,
      company: controller.userCompany.value,
      avatarUrl: controller.userAvatarUrl.value,
      dateOfBirth: null,
      locale: 'ru',
      timezone: 'Europe/Moscow',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    showDialog(
      context: context,
      builder: (context) => ContactEditingDialog(
        contact: userContact,
        onSave: (updatedContact) {
          // TODO: Обновить данные пользователя через API
          Get.snackbar(
            'Успех',
            'Профиль обновлен',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
            colorText: Get.theme.colorScheme.primary,
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    ColorScheme cs,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: cs.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
