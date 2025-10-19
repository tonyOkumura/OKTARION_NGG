import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../services/api_service.dart';
import '../models/api_models.dart';
import '../constants/api_endpoints.dart';

// Базовый репозиторий
abstract class BaseRepository {
  final ApiService _apiService = Get.find<ApiService>();

  ApiService get api => _apiService;
}

// Репозиторий для пользователей
class UserRepository extends BaseRepository {
  static const String _basePath = '/users';

  // Получить профиль пользователя
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    return await api.get<Map<String, dynamic>>('$_basePath/profile');
  }

  // Обновить профиль пользователя
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    return await api.put<Map<String, dynamic>>(
      '$_basePath/profile',
      data: profileData,
    );
  }

  // Загрузить аватар
  Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(String imagePath) async {
    return await api.uploadFile<Map<String, dynamic>>(
      '$_basePath/avatar',
      imagePath,
      fieldName: 'avatar',
    );
  }
}

// Репозиторий для сообщений
class MessagesRepository extends BaseRepository {
  static const String _basePath = ApiEndpoints.messages;

  // Получить список сообщений
  Future<ApiResponse<List<Map<String, dynamic>>>> getMessages({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      ...?filters,
    };
    return await api.get<List<Map<String, dynamic>>>(
      _basePath,
      queryParameters: queryParams,
      fromJson: (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  // Отправить сообщение
  Future<ApiResponse<Map<String, dynamic>>> sendMessage(
    Map<String, dynamic> messageData,
  ) async {
    return await api.post<Map<String, dynamic>>(
      _basePath,
      data: messageData,
    );
  }

  // Получить сообщение по ID
  Future<ApiResponse<Map<String, dynamic>>> getMessage(String messageId) async {
    return await api.get<Map<String, dynamic>>('$_basePath/$messageId');
  }

  // Обновить сообщение
  Future<ApiResponse<Map<String, dynamic>>> updateMessage(
    String messageId,
    Map<String, dynamic> messageData,
  ) async {
    return await api.put<Map<String, dynamic>>(
      '$_basePath/$messageId',
      data: messageData,
    );
  }

  // Удалить сообщение
  Future<ApiResponse<void>> deleteMessage(String messageId) async {
    return await api.delete<void>('$_basePath/$messageId');
  }
}

// Репозиторий для задач
class TasksRepository extends BaseRepository {
  static const String _basePath = ApiEndpoints.tasks;

  // Получить список задач
  Future<ApiResponse<List<Map<String, dynamic>>>> getTasks({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      ...?filters,
    };
    return await api.get<List<Map<String, dynamic>>>(
      _basePath,
      queryParameters: queryParams,
      fromJson: (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  // Создать задачу
  Future<ApiResponse<Map<String, dynamic>>> createTask(
    Map<String, dynamic> taskData,
  ) async {
    return await api.post<Map<String, dynamic>>(
      _basePath,
      data: taskData,
    );
  }

  // Обновить задачу
  Future<ApiResponse<Map<String, dynamic>>> updateTask(
    String taskId,
    Map<String, dynamic> taskData,
  ) async {
    return await api.put<Map<String, dynamic>>(
      '$_basePath/$taskId',
      data: taskData,
    );
  }

  // Удалить задачу
  Future<ApiResponse<void>> deleteTask(String taskId) async {
    return await api.delete<void>('$_basePath/$taskId');
  }
}

// Репозиторий для событий
class EventsRepository extends BaseRepository {
  static const String _basePath = ApiEndpoints.events;

  // Получить список событий
  Future<ApiResponse<List<Map<String, dynamic>>>> getEvents({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      ...?filters,
    };
    return await api.get<List<Map<String, dynamic>>>(
      _basePath,
      queryParameters: queryParams,
      fromJson: (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  // Создать событие
  Future<ApiResponse<Map<String, dynamic>>> createEvent(
    Map<String, dynamic> eventData,
  ) async {
    return await api.post<Map<String, dynamic>>(
      _basePath,
      data: eventData,
    );
  }

  // Обновить событие
  Future<ApiResponse<Map<String, dynamic>>> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    return await api.put<Map<String, dynamic>>(
      '$_basePath/$eventId',
      data: eventData,
    );
  }

  // Удалить событие
  Future<ApiResponse<void>> deleteEvent(String eventId) async {
    return await api.delete<void>('$_basePath/$eventId');
  }
}

// Репозиторий для файлов
class FilesRepository extends BaseRepository {
  static const String _basePath = ApiEndpoints.files;

  // Получить список файлов
  Future<ApiResponse<List<Map<String, dynamic>>>> getFiles({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      ...?filters,
    };
    return await api.get<List<Map<String, dynamic>>>(
      _basePath,
      queryParameters: queryParams,
      fromJson: (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  // Загрузить файл
  Future<ApiResponse<Map<String, dynamic>>> uploadFile(
    String filePath, {
    Map<String, dynamic>? metadata,
    dio.ProgressCallback? onProgress,
  }) async {
    return await api.uploadFile<Map<String, dynamic>>(
      _basePath,
      filePath,
      additionalData: metadata,
      onSendProgress: onProgress,
    );
  }

  // Скачать файл
  Future<void> downloadFile(
    String fileId,
    String savePath, {
    dio.ProgressCallback? onProgress,
  }) async {
    await api.downloadFile(
      '$_basePath/$fileId/download',
      savePath,
      onReceiveProgress: onProgress,
    );
  }

  // Удалить файл
  Future<ApiResponse<void>> deleteFile(String fileId) async {
    return await api.delete<void>('$_basePath/$fileId');
  }
}

// Репозиторий для контактов
class ContactsRepository extends BaseRepository {
  static const String _basePath = ApiEndpoints.contacts;

  // Получить список контактов
  Future<ApiResponse<List<Map<String, dynamic>>>> getContacts({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      ...?filters,
    };
    return await api.get<List<Map<String, dynamic>>>(
      _basePath,
      queryParameters: queryParams,
      fromJson: (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  // Создать контакт
  Future<ApiResponse<Map<String, dynamic>>> createContact(
    Map<String, dynamic> contactData,
  ) async {
    return await api.post<Map<String, dynamic>>(
      _basePath,
      data: contactData,
    );
  }

  // Обновить контакт
  Future<ApiResponse<Map<String, dynamic>>> updateContact(
    String contactId,
    Map<String, dynamic> contactData,
  ) async {
    return await api.put<Map<String, dynamic>>(
      '$_basePath/$contactId',
      data: contactData,
    );
  }

  // Удалить контакт
  Future<ApiResponse<void>> deleteContact(String contactId) async {
    return await api.delete<void>('$_basePath/$contactId');
  }
}
