import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';
import '../repositories/api_repositories.dart';
import '../utils/log_service.dart';

class ApiInitializer {
  static Future<void> initialize() async {
    // Инициализируем API сервис
    Get.put<ApiService>(ApiService(), permanent: true);
    
    // Инициализируем File сервис
    Get.put<FileService>(FileService(), permanent: true);
    
    // Инициализируем репозитории
    Get.put<ContactsRepository>(ContactsRepository(), permanent: true);
    
    
    LogService.i('API services initialized successfully');
  }
}
