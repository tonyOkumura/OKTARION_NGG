import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/api_repositories.dart';
import '../utils/log_service.dart';

/// Сервис для работы с пользователями после регистрации
class UserPostRegistrationService extends GetxService {
  final ContactsRepository _contactsRepository = Get.find<ContactsRepository>();

  /// Создать контакт пользователя после успешной регистрации
  Future<bool> createUserContactAfterRegistration() async {
    try {
      // Получаем текущую сессию
      final session = Supabase.instance.client.auth.currentSession;
      if (session?.user?.email == null) {
        LogService.e('No user session found for contact creation');
        return false;
      }

      // Извлекаем username из email (до @)
      final email = session!.user!.email!;
      final username = _extractUsernameFromEmail(email);
      
      LogService.i('Creating user contact for: $username (from email: $email)');

      // Создаем контакт пользователя
      final response = await _contactsRepository.createUserContact(username);
      
      if (response.success) {
        LogService.i('User contact created successfully: $username');
        return true;
      } else {
        LogService.e('Failed to create user contact: ${response.message}');
        return false;
      }
    } catch (e) {
      LogService.e('Error creating user contact: $e');
      return false;
    }
  }

  /// Извлечь username из email (часть до @)
  String _extractUsernameFromEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex == -1) {
      // Если нет @, используем весь email
      return email;
    }
    return email.substring(0, atIndex);
  }

  /// Получить username текущего пользователя
  String? getCurrentUserUsername() {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session?.user?.email == null) {
        return null;
      }
      return _extractUsernameFromEmail(session!.user!.email!);
    } catch (e) {
      LogService.e('Error getting current user username: $e');
      return null;
    }
  }


  /// Полный процесс создания контакта с уведомлениями
  Future<void> handlePostRegistrationContactCreation() async {
    try {
  
      // Создаем контакт
      final success = await createUserContactAfterRegistration();
      
      if (success) {
        LogService.i('Post-registration contact creation completed successfully');
      } else {
        LogService.e('Post-registration contact creation failed');
      }
    } catch (e) {
      LogService.e('Error in post-registration contact creation: $e');
    }
  }
}
