import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/core.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxnString errorText = RxnString();
  
  // Данные пользователя
  final RxnString userEmail = RxnString();
  final RxnString userName = RxnString();
  final RxnString userPhone = RxnString();
  final RxnString userPosition = RxnString();
  final RxnString userDepartment = RxnString();
  final RxnString userCompany = RxnString();
  final RxnString userStatusMessage = RxnString();
  final RxnString userAvatarUrl = RxnString();

  Future<void> loadData() async {
    isLoading.value = true;
    errorText.value = null;
    try {
      LogService.i('🏠 Loading home data...');
      
      // Получаем данные пользователя из Supabase
      await _loadUserData();
      
      LogService.i('✅ Home data loaded successfully');
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to load home data: $e', e, stackTrace);
      errorText.value = 'Не удалось загрузить данные';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session?.user != null) {
        final user = session!.user;
        
        // Основные данные из auth
        userEmail.value = user.email;
        userName.value = user.userMetadata?['full_name'] ?? 
                        user.userMetadata?['name'] ?? 
                        user.email?.split('@').first ?? 'Пользователь';
        
        // Дополнительные данные из user_metadata
        userPhone.value = user.userMetadata?['phone'] ?? '+7 (999) 123-45-67';
        userPosition.value = user.userMetadata?['position'] ?? 'Senior Developer';
        userDepartment.value = user.userMetadata?['department'] ?? 'Разработка';
        userCompany.value = user.userMetadata?['company'] ?? 'OKTARION';
        userStatusMessage.value = user.userMetadata?['status_message'] ?? 'Готов к новым проектам! 🚀';
        userAvatarUrl.value = user.userMetadata?['avatar_url'];
        
        LogService.i('👤 User data loaded: ${userName.value} (${userEmail.value})');
      } else {
        LogService.w('⚠️ No user session found');
        // Устанавливаем значения по умолчанию
        _setDefaultUserData();
      }
    } catch (e) {
      LogService.e('❌ Failed to load user data: $e');
      _setDefaultUserData();
    }
  }

  void _setDefaultUserData() {
    userEmail.value = 'user@example.com';
    userName.value = 'Пользователь';
    userPhone.value = '+7 (999) 123-45-67';
    userPosition.value = 'Developer';
    userDepartment.value = 'Разработка';
    userCompany.value = 'OKTARION';
    userStatusMessage.value = 'Добро пожаловать! 👋';
    userAvatarUrl.value = null;
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }
}
