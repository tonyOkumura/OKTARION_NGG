import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:okta/shared/widgets/widgets.dart';

import '../../../../core/core.dart';
import '../controllers/login_controller.dart';

/// Экран подтверждения email
/// Показывается после регистрации, когда пользователь должен подтвердить email
class EmailConfirmationView extends StatelessWidget {
  const EmailConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Иконка подтверждения
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Заголовок
                Text(
                  'Ожидайте подтверждения',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Описание
                Text(
                  'Ваш аккаунт зарегистрирован, но требует подтверждения администратора.\n\nEmail: ${controller.emailController.text}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Инструкции
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Что происходит сейчас:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInstruction(
                          context,
                          Icons.admin_panel_settings_outlined,
                          '1. Ожидание администратора',
                          'Администратор проверит ваш аккаунт',
                        ),
                        const SizedBox(height: 12),
                        _buildInstruction(
                          context,
                          Icons.check_circle_outline,
                          '2. Подтверждение аккаунта',
                          'Администратор подтвердит ваш email',
                        ),
                        const SizedBox(height: 12),
                        _buildInstruction(
                          context,
                          Icons.login_outlined,
                          '3. Вход в приложение',
                          'После подтверждения вы сможете войти',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Кнопки действий
                Column(
                  children: [
                    // Проверить статус
                    SizedBox(
                      width: double.infinity,
                      child: GlassButton(
                        onPressed: () => _checkAccountStatus(controller),
                        child: const Text('Проверить статус аккаунта'),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Войти с другим email
                    SizedBox(
                      width: double.infinity,
                      child: GlassButton(
                        onPressed: () => _signOutAndReturnToLogin(controller),
                        child: const Text('Войти с другим email'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Информация о времени
                Obx(() => Text(
                  'Текущее время: ${_formatTime(controller.now.value)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstruction(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Проверить статус аккаунта
  Future<void> _checkAccountStatus(LoginController controller) async {
    try {
      LogService.i('🔍 Checking account status...');
      
      // Получаем текущего пользователя
      final user = SupabaseService.instance.currentUser;
      
      if (user != null) {
        // Проверяем, подтвержден ли email
        if (user.emailConfirmedAt != null) {
          NotificationService.instance.showSuccess(
            title: 'Аккаунт подтвержден!',
            message: 'Вы можете войти в приложение',
            color: Theme.of(Get.context!).primaryColor,
          );
          
          // Обновляем состояние аутентификации
          await SupabaseService.instance.client.auth.refreshSession();
        } else {
          NotificationService.instance.showInfo(
            title: 'Ожидание подтверждения',
            message: 'Администратор еще не подтвердил ваш аккаунт',
            color: Theme.of(Get.context!).colorScheme.secondary,
          );
        }
      } else {
        NotificationService.instance.showError(
          title: 'Ошибка',
          message: 'Не удалось получить информацию об аккаунте',
          color: Theme.of(Get.context!).colorScheme.error,
        );
      }
      
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to check account status: $e', e, stackTrace);
      
      NotificationService.instance.showError(
        title: 'Ошибка',
        message: 'Не удалось проверить статус аккаунта',
        color: Theme.of(Get.context!).colorScheme.error,
      );
    }
  }

  /// Выйти и вернуться к экрану входа
  Future<void> _signOutAndReturnToLogin(LoginController controller) async {
    try {
      LogService.i('🚪 Signing out to return to login...');
      
      await controller.signOut();
      
      // Очищаем поля формы
      controller.emailController.clear();
      controller.passwordController.clear();
      controller.errorText.value = null;
      
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to sign out: $e', e, stackTrace);
    }
  }
}
