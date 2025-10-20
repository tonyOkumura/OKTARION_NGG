import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/user_post_registration_service.dart';
import '../repositories/api_repositories.dart';
import '../utils/log_service.dart';

class ApiInitializer {
  static Future<void> initialize() async {
    // Инициализируем API сервис
    Get.put<ApiService>(ApiService(), permanent: true);
    
    // Инициализируем репозитории
    Get.put<ContactsRepository>(ContactsRepository(), permanent: true);
    
    // Инициализируем дополнительные сервисы
    Get.put<UserPostRegistrationService>(UserPostRegistrationService(), permanent: true);
    
    LogService.i('API services initialized successfully');
  }
}
