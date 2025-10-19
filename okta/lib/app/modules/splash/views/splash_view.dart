import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';
import '../../../../shared/widgets/glass_loading.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Большой GlassLoading вокруг иконки
            GlassLoading(size: 300),
            // Статичная иконка в центре
            Icon(
              Icons.bubble_chart_outlined,
              size: 200,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}