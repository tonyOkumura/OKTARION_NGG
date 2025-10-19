import 'package:get/get.dart';
import '../services/api_service.dart';
import '../repositories/api_repositories.dart';
import '../utils/log_service.dart';

class ApiInitializer {
  static Future<void> initialize() async {
    // Инициализируем API сервис
    Get.put<ApiService>(ApiService(), permanent: true);
    
    // Инициализируем репозитории
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<MessagesRepository>(MessagesRepository(), permanent: true);
    Get.put<TasksRepository>(TasksRepository(), permanent: true);
    Get.put<EventsRepository>(EventsRepository(), permanent: true);
    Get.put<FilesRepository>(FilesRepository(), permanent: true);
    Get.put<ContactsRepository>(ContactsRepository(), permanent: true);
    
    LogService.i('API services initialized successfully');
  }
}
