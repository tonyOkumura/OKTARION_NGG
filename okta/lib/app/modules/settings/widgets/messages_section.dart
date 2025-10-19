import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';

class MessagesSection extends StatelessWidget {
  const MessagesSection({super.key, required this.controller});
  
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message_outlined, color: cs.tertiary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Сообщения',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => SwitchListTile(
            title: Text(
              'Включить сообщения',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              controller.messagesEnabled.value 
                  ? 'Получать сообщения от команды' 
                  : 'Сообщения отключены',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            value: controller.messagesEnabled.value,
            onChanged: (_) => controller.toggleMessages(),
            activeColor: cs.tertiary,
            contentPadding: EdgeInsets.zero,
          )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.tertiary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: cs.tertiary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Общайтесь с командой и получайте важные обновления',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onTertiaryContainer,
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
