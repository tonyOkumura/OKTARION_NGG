import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/widgets.dart';
import '../controllers/settings_controller.dart';

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key, required this.controller});
  
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return HomeCard(
      title: 'Уведомления',
      icon: Icons.notifications_outlined,
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => SwitchListTile(
            title: Text(
              'Включить уведомления',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              controller.notificationsEnabled.value 
                  ? 'Получать все уведомления' 
                  : 'Уведомления отключены',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            value: controller.notificationsEnabled.value,
            onChanged: (_) => controller.toggleNotifications(),
            activeColor: cs.secondary,
            contentPadding: EdgeInsets.zero,
          )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.secondary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.secondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Уведомления помогают быть в курсе важных событий',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSecondaryContainer,
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
