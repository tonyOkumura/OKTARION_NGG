import 'package:get/get.dart';
import '../repositories/api_repositories.dart';
import '../constants/api_endpoints.dart';
import '../constants/success_messages.dart';
import '../constants/error_messages.dart';
import '../utils/log_service.dart';

/// Пример контроллера, демонстрирующий использование всех констант
class ExampleUsageController extends GetxController {
  final MessagesRepository _messagesRepository = Get.find<MessagesRepository>();
  final TasksRepository _tasksRepository = Get.find<TasksRepository>();

  // Состояние загрузки
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> tasks = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Загрузка данных
  Future<void> loadData() async {
    isLoading.value = true;
    
    try {
      // Загружаем сообщения и задачи параллельно
      await Future.wait([
        _loadMessages(),
        _loadTasks(),
      ]);
      
      // Используем константы для успешных сообщений
      Get.snackbar(
        'Успех',
        SuccessMessages.dataRetrieved,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      LogService.i(SuccessMessages.dataRetrieved);
    } catch (e) {
      // Используем константы для ошибок
      Get.snackbar(
        'Ошибка',
        ErrorMessages.networkError,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      LogService.e('Failed to load data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Загрузка сообщений
  Future<void> _loadMessages() async {
    try {
      final response = await _messagesRepository.getMessages();
      if (response.success && response.data != null) {
        messages.value = response.data!;
        LogService.i('Messages loaded from ${ApiEndpoints.messages}');
      }
    } catch (e) {
      LogService.e('Failed to load messages: $e');
      throw Exception(ErrorMessages.dataNotFound);
    }
  }

  // Загрузка задач
  Future<void> _loadTasks() async {
    try {
      final response = await _tasksRepository.getTasks();
      if (response.success && response.data != null) {
        tasks.value = response.data!;
        LogService.i('Tasks loaded from ${ApiEndpoints.tasks}');
      }
    } catch (e) {
      LogService.e('Failed to load tasks: $e');
      throw Exception(ErrorMessages.dataNotFound);
    }
  }

  // Отправка сообщения
  Future<void> sendMessage(Map<String, dynamic> messageData) async {
    try {
      final response = await _messagesRepository.sendMessage(messageData);
      if (response.success) {
        Get.snackbar(
          'Успех',
          SuccessMessages.dataSaved,
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadData(); // Перезагружаем данные
      }
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        ErrorMessages.operationFailed,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Создание задачи
  Future<void> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await _tasksRepository.createTask(taskData);
      if (response.success) {
        Get.snackbar(
          'Успех',
          SuccessMessages.dataSaved,
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadData(); // Перезагружаем данные
      }
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        ErrorMessages.operationFailed,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Обновление задачи
  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) async {
    try {
      final response = await _tasksRepository.updateTask(taskId, taskData);
      if (response.success) {
        Get.snackbar(
          'Успех',
          SuccessMessages.dataUpdated,
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadData(); // Перезагружаем данные
      }
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        ErrorMessages.operationFailed,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Удаление задачи
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksRepository.deleteTask(taskId);
      Get.snackbar(
        'Успех',
        SuccessMessages.dataDeleted,
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadData(); // Перезагружаем данные
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        ErrorMessages.operationFailed,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Обновление данных
  Future<void> refresh() async {
    await loadData();
  }
}
