import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/core.dart';

class AuthPasswordStrength extends StatelessWidget {
  const AuthPasswordStrength({
    super.key,
    required this.controller,
  });

  final dynamic controller; // LoginController

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return Obx(() {
      final isVisible = controller.isRegisterMode.value;
      final strength = controller.passwordStrength.value;
      final strengthText = controller.passwordStrengthText.value;
      final strengthColor = controller.passwordStrengthColor.value;

      return AnimatedSwitcher(
        duration: UIConstants.mediumAnimation,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1.0,
            child: child,
          ),
        ),
        child: isVisible
            ? Padding(
                key: const ValueKey('strength'),
                padding: const EdgeInsets.only(top: UIConstants.spacing8, bottom: UIConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strengthText.isNotEmpty
                          ? 'Надежность пароля: $strengthText'
                          : 'Надежность пароля',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: strengthColor,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacing4),
                    LinearProgressIndicator(
                      value: strength,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(UIConstants.radius4),
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(strengthColor),
                    ),
                  ],
                ),
              )
            : const SizedBox(key: ValueKey('no_strength'), height: 0),
      );
    });
  }
}
