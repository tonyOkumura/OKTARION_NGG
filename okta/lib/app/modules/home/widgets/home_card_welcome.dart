import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/widgets.dart';
import '../../../../core/models/contact_model.dart';
import '../../../../core/models/update_profile_request.dart';
import '../controllers/home_controller.dart';
import 'home_common_widgets.dart';

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
              InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: controller.userEmail.value ?? 'user@example.com',
              ),
              const SizedBox(height: 12),
              
              InfoRow(
                icon: Icons.phone_outlined,
                label: 'Телефон',
                value: controller.userPhone.value ?? '+7 (999) 123-45-67',
              ),
              const SizedBox(height: 12),
              
              InfoRow(
                icon: Icons.work_outline,
                label: 'Должность',
                value: controller.userPosition.value ?? 'Developer',
              ),
              const SizedBox(height: 12),
              
              InfoRow(
                icon: Icons.business_outlined,
                label: 'Отдел',
                value: controller.userDepartment.value ?? 'Разработка',
              ),
              const SizedBox(height: 12),
              
              InfoRow(
                icon: Icons.business,
                label: 'Компания',
                value: controller.userCompany.value ?? 'OKTARION',
              ),
              const SizedBox(height: 16),
              
              // Статус сообщение
              StatusContainer(
                icon: Icons.message_outlined,
                title: 'Статус сообщение',
                message: controller.userStatusMessage.value ?? 'Добро пожаловать! 👋',
                backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderColor: cs.outline.withValues(alpha: 0.2),
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
      username: controller.userUsername.value ?? 'user',
      firstName: controller.userFirstName.value,
      lastName: controller.userLastName.value,
      displayName: controller.userName.value,
      email: controller.userEmail.value,
      phone: controller.userPhone.value,
      isOnline: true,
      lastSeenAt: DateTime.now(),
      statusMessage: controller.userStatusMessage.value,
      role: 'user',
      department: controller.userDepartment.value,
      rank: controller.userRank.value,
      position: controller.userPosition.value,
      company: controller.userCompany.value,
      avatarUrl: controller.userAvatarUrl.value,
      dateOfBirth: null,
      locale: 'ru',
      timezone: 'Europe/Moscow',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Get.dialog(
      ContactEditingDialog(
        contact: userContact,
        onSave: (updatedContact) async {
          try {
            // Создаем запрос для обновления профиля
            final request = UpdateProfileRequest(
              username: updatedContact.username,
              firstName: updatedContact.firstName,
              lastName: updatedContact.lastName,
              displayName: updatedContact.displayName,
              email: updatedContact.email,
              phone: updatedContact.phone,
              statusMessage: updatedContact.statusMessage,
              department: updatedContact.department,
              rank: updatedContact.rank,
              position: updatedContact.position,
              company: updatedContact.company,
            );

            // Обновляем профиль через API
            final success = await controller.updateProfile(request);
            if (success) {
              Get.snackbar(
                'Успех',
                'Профиль обновлен',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
                colorText: Get.theme.colorScheme.primary,
              );
            } else {
              Get.snackbar(
                'Ошибка',
                'Не удалось обновить профиль',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
                colorText: Get.theme.colorScheme.error,
              );
            }
          } catch (e) {
            Get.snackbar(
              'Ошибка',
              'Произошла ошибка при обновлении профиля',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
              colorText: Get.theme.colorScheme.error,
            );
          }
        },
      ),
    );
  }
}
