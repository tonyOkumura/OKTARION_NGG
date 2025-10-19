import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/widgets.dart';
import '../controllers/settings_controller.dart';

class PrivacySection extends StatelessWidget {
  const PrivacySection({super.key, required this.controller});
  
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return HomeCard(
      title: 'Приватность',
      icon: Icons.privacy_tip_outlined,
      height: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => SwitchListTile(
            title: Text(
              'Приватный режим',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              controller.privacyMode.value 
                  ? 'Дополнительная защита данных' 
                  : 'Стандартные настройки',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            value: controller.privacyMode.value,
            onChanged: (_) => controller.togglePrivacyMode(),
            activeColor: cs.error,
            contentPadding: EdgeInsets.zero,
          )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.error.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.security, color: cs.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Защитите свои данные и конфиденциальность',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onErrorContainer,
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
