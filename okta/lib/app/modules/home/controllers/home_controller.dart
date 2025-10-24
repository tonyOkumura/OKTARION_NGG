import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/core.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxnString errorText = RxnString();
  
  // Данные пользователя
  final RxnString userEmail = RxnString();
  final RxnString userName = RxnString();
  final RxnString userFirstName = RxnString();
  final RxnString userLastName = RxnString();
  final RxnString userUsername = RxnString();
  final RxnString userPhone = RxnString();
  final RxnString userPosition = RxnString();
  final RxnString userDepartment = RxnString();
  final RxnString userRank = RxnString();
  final RxnString userCompany = RxnString();
  final RxnString userStatusMessage = RxnString();
  final RxnString userAvatarUrl = RxnString();
  
  // Репозиторий для работы с API
  late final ContactsRepository _repository;

  @override
  void onInit() {
    super.onInit();
    _repository = Get.find<ContactsRepository>();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorText.value = null;
    try {
      LogService.i('🏠 Loading home data...');
      
      // Получаем данные пользователя из API
      await _loadUserDataFromApi();
      
      LogService.i('✅ Home data loaded successfully');
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to load home data: $e', e, stackTrace);
      errorText.value = 'Не удалось загрузить данные';
      
      // Fallback к данным из Supabase
      await _loadUserDataFromSupabase();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserDataFromApi() async {
    try {
      final response = await _repository.getMe();
      if (response.success && response.data != null) {
        final user = response.data!;
        
        userEmail.value = user.email;
        userName.value = user.displayNameOrUsername;
        userFirstName.value = user.firstName;
        userLastName.value = user.lastName;
        userUsername.value = user.username;
        userPhone.value = user.phone;
        userPosition.value = user.position;
        userDepartment.value = user.department;
        userRank.value = user.rank;
        userCompany.value = user.company;
        userStatusMessage.value = user.statusMessage;
        userAvatarUrl.value = user.avatarUrl;
        
        LogService.i('👤 User data loaded from API: ${user.displayNameOrUsername} (${user.email})');
      } else {
        throw Exception('Failed to get user data from API');
      }
    } catch (e) {
      LogService.e('❌ Failed to load user data from API: $e');
      rethrow;
    }
  }

  Future<void> _loadUserDataFromSupabase() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session?.user != null) {
        final user = session!.user;
        
        // Основные данные из auth
        userEmail.value = user.email;
        userName.value = user.userMetadata?['full_name'] ?? 
                        user.userMetadata?['name'] ?? 
                        user.email?.split('@').first ?? 'Пользователь';
        
        // Отдельные поля для имени и фамилии
        userFirstName.value = user.userMetadata?['first_name'];
        userLastName.value = user.userMetadata?['last_name'];
        userUsername.value = user.userMetadata?['username'] ?? user.email?.split('@').first;
        
        // Дополнительные данные из user_metadata
        userPhone.value = user.userMetadata?['phone'] ?? '+7 (999) 123-45-67';
        userPosition.value = user.userMetadata?['position'] ?? 'Senior Developer';
        userDepartment.value = user.userMetadata?['department'] ?? 'Разработка';
        userRank.value = user.userMetadata?['rank'];
        userCompany.value = user.userMetadata?['company'] ?? 'OKTARION';
        userStatusMessage.value = user.userMetadata?['status_message'] ?? 'Готов к новым проектам! 🚀';
        userAvatarUrl.value = user.userMetadata?['avatar_url'];
        
        LogService.i('👤 User data loaded from Supabase: ${userName.value} (${userEmail.value})');
      } else {
        LogService.w('⚠️ No user session found');

      }
    } catch (e) {
      LogService.e('❌ Failed to load user data from Supabase: $e');

    }
  }

  

  /// Обновить профиль пользователя
  Future<bool> updateProfile(UpdateProfileRequest request) async {
    try {
      isLoading.value = true;
      errorText.value = null;
      
      final response = await _repository.updateMe(request);
      
      if (response.success) {
        // Если сервер вернул обновленные данные контакта
        if (response.data != null) {
          final updatedUser = response.data!;
          
          // Обновляем локальные данные
          userEmail.value = updatedUser.email;
          userName.value = updatedUser.displayNameOrUsername;
          userFirstName.value = updatedUser.firstName;
          userLastName.value = updatedUser.lastName;
          userUsername.value = updatedUser.username;
          userPhone.value = updatedUser.phone;
          userPosition.value = updatedUser.position;
          userDepartment.value = updatedUser.department;
          userRank.value = updatedUser.rank;
          userCompany.value = updatedUser.company;
          userStatusMessage.value = updatedUser.statusMessage;
          userAvatarUrl.value = updatedUser.avatarUrl;
        } else {
          // Если сервер вернул только сообщение об успехе, обновляем данные из запроса
          
          // Обновляем каждое поле с логированием
          if (request.email != null) {
            userEmail.value = request.email!;
          }
          
          if (request.username != null) {
            userUsername.value = request.username!;
          }
          
          if (request.firstName != null) {
            userFirstName.value = request.firstName!;
          }
          
          if (request.lastName != null) {
            userLastName.value = request.lastName!;
          }
          
          if (request.displayName != null) {
            userName.value = request.displayName!;
          }
          
          if (request.phone != null) {
            userPhone.value = request.phone!;
          }
          
          if (request.position != null) {
            userPosition.value = request.position!;
          }
          
          if (request.department != null) {
            userDepartment.value = request.department!;
          }
          
          if (request.rank != null) {
            userRank.value = request.rank!;
          }
          
          if (request.company != null) {
            userCompany.value = request.company!;
          }
          
          if (request.statusMessage != null) {
            userStatusMessage.value = request.statusMessage!;
          }
        }
        
        return true;
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e, stackTrace) {
      LogService.e('❌ Failed to update profile: $e', e, stackTrace);
      errorText.value = 'Не удалось обновить профиль';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }
}
