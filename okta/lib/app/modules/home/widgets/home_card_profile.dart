import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/widgets.dart';
import '../controllers/home_controller.dart';

/// Карточка аватара
class HomeCardProfile extends GetView<HomeController> {
  const HomeCardProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => HomeCard(
      title: 'Аватар',
      icon: Icons.person_outline,
      child: Center(
        child: GestureDetector(
          onTap: () => controller.uploadAvatar(),
          child: Stack(
            children: [
              GlassAvatar(
                label: controller.userName.value ?? 'Пользователь',
                avatarUrl: controller.userAvatarUrl.value,
                radius: 150,
              ),
              // Индикатор загрузки
              if (controller.isLoading.value)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              // Иконка камеры для указания возможности загрузки
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
