import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/api_config.dart';
import '../models/api_models.dart';
import '../utils/log_service.dart';

/// Сервис для работы с файлами
class FileService extends GetxService {
  late dio.Dio _dio;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      },
    ));

    // Добавляем интерцептор для аутентификации
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final session = Supabase.instance.client.auth.currentSession;
          if (session?.accessToken != null) {
            options.headers[ApiConfig.authorizationHeader] = 
                '${ApiConfig.bearerPrefix}${session!.accessToken}';
          }
          handler.next(options);
        } catch (e) {
          LogService.e('File service auth interceptor error: $e');
          handler.next(options);
        }
      },
    ));
  }

  /// Загрузить аватарку пользователя
  Future<ApiResponse<Map<String, dynamic>>> uploadAvatar(File imageFile) async {
    try {
      LogService.i('📤 Uploading avatar...');
      
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: path.basename(imageFile.path),
        ),
      });

      final response = await _dio.post(
        '/files/avatars',
        data: formData,
      );

      LogService.i('✅ Avatar uploaded successfully');
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } on dio.DioException catch (e) {
      LogService.e('❌ Failed to upload avatar: ${e.message}');
      throw _parseApiError(e);
    }
  }

  /// Получить информацию об аватарке пользователя
  Future<ApiResponse<Map<String, dynamic>>> getAvatarInfo() async {
    try {
      LogService.i('📥 Getting avatar info...');
      
      final response = await _dio.get('/files/avatars');
      
      LogService.i('✅ Avatar info retrieved successfully');
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } on dio.DioException catch (e) {
      LogService.e('❌ Failed to get avatar info: ${e.message}');
      throw _parseApiError(e);
    }
  }

  /// Выбрать изображение из галереи
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      LogService.e('❌ Failed to pick image from gallery: $e');
      return null;
    }
  }

  /// Сделать фото с камеры
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      LogService.e('❌ Failed to pick image from camera: $e');
      return null;
    }
  }

  /// Показать диалог выбора источника изображения
  Future<File?> showImageSourceDialog() async {
    return await Get.dialog<File?>(
      AlertDialog(
        title: const Text('Выберите источник'),
        content: const Text('Откуда вы хотите выбрать изображение?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final file = await pickImageFromGallery();
              Get.back(result: file);
            },
            child: const Text('Галерея'),
          ),
          TextButton(
            onPressed: () async {
              final file = await pickImageFromCamera();
              Get.back(result: file);
            },
            child: const Text('Камера'),
          ),
        ],
      ),
    );
  }

  /// Создать временный файл
  Future<File> createTempFile(String fileName) async {
    final tempDir = await getTemporaryDirectory();
    return File(path.join(tempDir.path, fileName));
  }

  /// Парсинг ошибок API
  ApiError _parseApiError(dio.DioException error) {
    if (error.response?.data is Map<String, dynamic>) {
      return ApiError.fromJson(error.response!.data);
    }
    
    return ApiError(
      message: error.message ?? 'Unknown error occurred',
      statusCode: error.response?.statusCode,
    );
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}
