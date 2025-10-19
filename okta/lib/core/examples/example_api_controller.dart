import 'package:get/get.dart';
import '../../core/repositories/api_repositories.dart';
import '../../core/utils/log_service.dart';

class ExampleApiController extends GetxController {
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
      
      LogService.i('Data loaded successfully');
    } catch (e) {
      LogService.e('Failed to load data: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось загрузить данные: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Загрузка сообщений
  Future<void> _loadMessages() async {
    try {
      final response = await _messagesRepository.getMessages(
        page: 1,
        limit: 20,
        filters: {
          'unread_only': false,
          'important_only': false,
        },
      );
      
      if (response.success && response.data != null) {
        messages.value = response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to load messages');
      }
    } catch (e) {
      LogService.e('Failed to load messages: $e');
      rethrow;
    }
  }

  // Загрузка задач
  Future<void> _loadTasks() async {
    try {
      final response = await _tasksRepository.getTasks(
        page: 1,
        limit: 20,
        filters: {
          'status': 'active',
          'priority': 'high',
        },
      );
      
      if (response.success && response.data != null) {
        tasks.value = response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to load tasks');
      }
    } catch (e) {
      LogService.e('Failed to load tasks: $e');
      rethrow;
    }
  }

  // Отправка сообщения
  Future<void> sendMessage(Map<String, dynamic> messageData) async {
    try {
      isLoading.value = true;
      
      final response = await _messagesRepository.sendMessage(messageData);
      
      if (response.success) {
        LogService.i('Message sent successfully');
        Get.snackbar(
          'Успех',
          'Сообщение отправлено',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Обновляем список сообщений
        await _loadMessages();
      } else {
        throw Exception(response.message ?? 'Failed to send message');
      }
    } catch (e) {
      LogService.e('Failed to send message: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось отправить сообщение: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Создание задачи
  Future<void> createTask(Map<String, dynamic> taskData) async {
    try {
      isLoading.value = true;
      
      final response = await _tasksRepository.createTask(taskData);
      
      if (response.success) {
        LogService.i('Task created successfully');
        Get.snackbar(
          'Успех',
          'Задача создана',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Обновляем список задач
        await _loadTasks();
      } else {
        throw Exception(response.message ?? 'Failed to create task');
      }
    } catch (e) {
      LogService.e('Failed to create task: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось создать задачу: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Обновление задачи
  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) async {
    try {
      isLoading.value = true;
      
      final response = await _tasksRepository.updateTask(taskId, taskData);
      
      if (response.success) {
        LogService.i('Task updated successfully');
        Get.snackbar(
          'Успех',
          'Задача обновлена',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Обновляем список задач
        await _loadTasks();
      } else {
        throw Exception(response.message ?? 'Failed to update task');
      }
    } catch (e) {
      LogService.e('Failed to update task: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось обновить задачу: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Удаление задачи
  Future<void> deleteTask(String taskId) async {
    try {
      isLoading.value = true;
      
      final response = await _tasksRepository.deleteTask(taskId);
      
      if (response.success) {
        LogService.i('Task deleted successfully');
        Get.snackbar(
          'Успех',
          'Задача удалена',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Обновляем список задач
        await _loadTasks();
      } else {
        throw Exception(response.message ?? 'Failed to delete task');
      }
    } catch (e) {
        LogService.e('Failed to delete task: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось удалить задачу: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Обновление данных
  Future<void> refresh() async {
    await loadData();
  }
}
