import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/core.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/animated_background/particles_widget.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  
  void _submitForm() {
    if (!controller.isLoading.value) {
      controller.submitForm(controller.formKey);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final passwordFocusNode = FocusNode();

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedBackground()),
          Positioned.fill(child: ParticlesWidget(30)),
              Obx(() {
                final dt = controller.now.value;
                final clock = ClockBlock(
                  time: DateFormatter.formatTime(dt),
                  dateLine: DateFormatter.formatDateLine(dt),
                  colorScheme: colorScheme,
                  seconds: controller.seconds.value,
                );

            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: UIConstants.spacing32),
                child: clock,
              ),
            );
          }),
          // Theme mode toggle (sun/moon) in top-right
          Positioned(
            top: UIConstants.spacing16,
            right: UIConstants.spacing16,
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return ClipRRect(
                borderRadius: BorderRadius.circular(UIConstants.radius12),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacing8,
                      vertical: UIConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(UIConstants.radius12),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        ThemeToggleButton(
                          active: !isDark,
                          icon: Icons.wb_sunny_outlined,
                          tooltip: 'Светлая тема',
                          colorScheme: colorScheme,
                          onTap: () => Get.changeThemeMode(ThemeMode.light),
                        ),
                        const SizedBox(width: UIConstants.spacing8),
                        ThemeToggleButton(
                          active: isDark,
                          icon: Icons.dark_mode_outlined,
                          tooltip: 'Тёмная тема',
                          colorScheme: colorScheme,
                          onTap: () => Get.changeThemeMode(ThemeMode.dark),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              },
            ),
          ),
          // Version card in bottom-right corner
          Positioned(
            bottom: UIConstants.spacing16,
            right: UIConstants.spacing16,
            child: const GlassVersionCard(),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: UIConstants.spacing32,
                horizontal: UIConstants.spacing16,
              ),
              child: AdaptiveFormContainer(
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(UIConstants.radius24),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: UIConstants.radius24,
                      offset: const Offset(0, UIConstants.radius12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(UIConstants.radius24),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(UIConstants.radius24),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          UIConstants.spacing28,
                          UIConstants.spacing28,
                          UIConstants.spacing28,
                          UIConstants.spacing24,
                        ),
                        child: Form(
                          key: controller.formKey,
                          child: Obx(
                            () => AnimatedSize(
                              duration: UIConstants.mediumAnimation,
                              curve: Curves.easeInOut,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lock_outline_rounded,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: UIConstants.spacing8),
                                    AdaptiveTitle(
                                      controller.isRegisterMode.value
                                          ? 'Регистрация'
                                          : 'Вход',
                                    ),
                                    ],
                                  ),
                                  const SizedBox(height: UIConstants.spacing20),
                                  // Поля
                                  AuthIdentifierField(
                                    controller: controller,
                                    passwordFocusNode: passwordFocusNode,
                                    onSubmitted: () => _submitForm(),
                                  ),
                                  const SizedBox(height: UIConstants.spacing12),
                                  // Полное имя не требуется для регистрации
                                  AuthPasswordField(
                                    controller: controller,
                                    focusNode: passwordFocusNode,
                                    onSubmitted: () => _submitForm(),
                                  ),
                                  AuthPasswordStrength(
                                    controller: controller,
                                  ),
                                  const SizedBox(height: UIConstants.spacing12),
                                  // Кнопка отправки
                                  Obx(
                                    () => AdaptiveButton(
                                      onPressed: (controller.isLoading.value || !controller.isFormValid.value)
                                          ? null
                                          : () => _submitForm(),
                                      isLoading: controller.isLoading.value,
                                      child: Text(
                                        controller.isRegisterMode.value
                                            ? 'Зарегистрироваться'
                                            : 'Войти',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: UIConstants.spacing8),
                                  // Переключатель режима
                                  Align(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      onPressed: controller.toggleRegisterMode,
                                      child: Obx(
                                        () => Text(
                                          controller.isRegisterMode.value
                                              ? 'Уже есть аккаунт? Войти'
                                              : 'Нет аккаунта? Зарегистрироваться',
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Ошибка
                                  Obx(() {
                                    final err = controller.errorText.value;
                                    if (err == null) return const SizedBox();
                                    return AnimatedOpacity(
                                      opacity: 1,
                                      duration: UIConstants.shortAnimation,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: UIConstants.spacing8,
                                        ),
                                          child: Text(
                                          err,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
