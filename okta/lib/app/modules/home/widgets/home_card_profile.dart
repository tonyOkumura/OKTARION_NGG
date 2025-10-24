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
        child: GlassAvatar(
          label: controller.userName.value ?? 'Пользователь',
          avatarUrl: controller.userAvatarUrl.value,
          radius: 150,
        ),
      ),
    ));
  }
}
