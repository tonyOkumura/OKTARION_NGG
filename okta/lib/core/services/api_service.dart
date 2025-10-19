import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/api_config.dart';
import '../models/api_models.dart';
import '../utils/log_service.dart';


class ApiService extends GetxService {
  late dio.Dio _dio;
  
  // Состояние обновления токена
  final RxBool _isRefreshing = false.obs;
  final List<dio.RequestOptions> _pendingRequests = [];

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
        'Content-Type': ApiConfig.contentType,
        'Accept': ApiConfig.contentType,
      },
    ));

    // Добавляем интерцепторы
    _dio.interceptors.addAll([
      _authInterceptor,
      _loggingInterceptor,
      _errorInterceptor,
    ]);
  }

  // Интерцептор для аутентификации
  dio.Interceptor get _authInterceptor => dio.InterceptorsWrapper(
    onRequest: (options, handler) async {
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session?.accessToken != null) {
          options.headers[ApiConfig.authorizationHeader] = 
              '${ApiConfig.bearerPrefix}${session!.accessToken}';
        }
        handler.next(options);
      } catch (e) {
        LogService.e('Auth interceptor error: $e');
        handler.next(options);
      }
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == ApiConfig.unauthorizedCode) {
        LogService.w('Unauthorized request, attempting token refresh');
        
        try {
          await _handleTokenRefresh(error.requestOptions, handler);
        } catch (e) {
          LogService.e('Token refresh failed: $e');
          handler.next(error);
        }
      } else {
        handler.next(error);
      }
    },
  );

  // Интерцептор для логирования
  dio.Interceptor get _loggingInterceptor => dio.InterceptorsWrapper(
    onRequest: (options, handler) {
      LogService.i('API Request: ${options.method} ${options.path}');
      if (options.data != null) {
        LogService.d('Request data: ${options.data}');
      }
      handler.next(options);
    },
    onResponse: (response, handler) {
      LogService.i('API Response: ${response.statusCode} ${response.requestOptions.path}');
      LogService.d('Response data: ${response.data}');
      handler.next(response);
    },
    onError: (error, handler) {
      LogService.e('API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
      LogService.e('Error message: ${error.message}');
      handler.next(error);
    },
  );

  // Интерцептор для обработки ошибок
  dio.Interceptor get _errorInterceptor => dio.InterceptorsWrapper(
    onError: (error, handler) {
      final apiError = _parseApiError(error);
      handler.next(dio.DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: apiError,
        message: apiError.message,
      ));
    },
  );

  // Обработка обновления токена
  Future<void> _handleTokenRefresh(
    dio.RequestOptions requestOptions,
    dio.ErrorInterceptorHandler handler,
  ) async {
    if (_isRefreshing.value) {
      // Если уже обновляем токен, добавляем запрос в очередь
      _pendingRequests.add(requestOptions);
      return;
    }

    _isRefreshing.value = true;

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session?.refreshToken != null) {
        // Обновляем токен через Supabase
        final response = await Supabase.instance.client.auth.refreshSession();
        
        if (response.session != null) {
          LogService.i('Token refreshed successfully');
          
          // Обновляем заголовок авторизации
          requestOptions.headers[ApiConfig.authorizationHeader] = 
              '${ApiConfig.bearerPrefix}${response.session!.accessToken}';
          
          // Повторяем оригинальный запрос
          final retryResponse = await _dio.fetch(requestOptions);
          handler.resolve(retryResponse);
          
          // Обрабатываем ожидающие запросы
          await _processPendingRequests();
        } else {
          throw Exception('Failed to refresh token');
        }
      } else {
        throw Exception('No refresh token available');
      }
    } catch (e) {
      LogService.e('Token refresh failed: $e');
      // Если не удалось обновить токен, перенаправляем на логин
      _redirectToLogin();
      handler.reject(dio.DioException(
        requestOptions: requestOptions,
        error: e,
        message: 'Authentication failed',
      ));
    } finally {
      _isRefreshing.value = false;
    }
  }

  // Обработка ожидающих запросов
  Future<void> _processPendingRequests() async {
    final requests = List<dio.RequestOptions>.from(_pendingRequests);
    _pendingRequests.clear();

    for (final request in requests) {
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session?.accessToken != null) {
          request.headers[ApiConfig.authorizationHeader] = 
              '${ApiConfig.bearerPrefix}${session!.accessToken}';
          await _dio.fetch(request);
        }
      } catch (e) {
        LogService.e('Failed to process pending request: $e');
      }
    }
  }

  // Перенаправление на логин
  void _redirectToLogin() {
    LogService.w('Redirecting to login due to authentication failure');
    // Очищаем сессию Supabase
    Supabase.instance.client.auth.signOut();
    // Перенаправляем на логин
    Get.offAllNamed('/login');
  }

  // Парсинг ошибок API
  ApiError _parseApiError(dio.DioException error) {
    if (error.response?.data is Map<String, dynamic>) {
      return ApiError.fromJson(error.response!.data);
    }
    
    return ApiError(
      message: error.message ?? 'Unknown error occurred',
      statusCode: error.response?.statusCode,
    );
  }

  // GET запрос
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on dio.DioException catch (e) {
      throw _parseApiError(e);
    }
  }

  // POST запрос
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on dio.DioException catch (e) {
      throw _parseApiError(e);
    }
  }

  // PUT запрос
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on dio.DioException catch (e) {
      throw _parseApiError(e);
    }
  }

  // DELETE запрос
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on dio.DioException catch (e) {
      throw _parseApiError(e);
    }
  }

  // PATCH запрос
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on dio.DioException catch (e) {
      throw _parseApiError(e);
    }
  }

  // Загрузка файла
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? additionalData,
    dio.ProgressCallback? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final formData = dio.FormData.fromMap({
        fieldName: await dio.MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on dio.DioException catch (e) {
      throw _parseApiError(e);
    }
  }

  // Скачивание файла
  Future<void> downloadFile(
    String url,
    String savePath, {
    dio.ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(url, savePath, onReceiveProgress: onReceiveProgress);
    } on dio.DioException catch (e) {
      throw _parseApiError(e);
    }
  }

  // Получение текущего токена
  String? getCurrentToken() {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken;
  }

  // Проверка авторизации
  bool get isAuthenticated {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken != null;
  }

  // Очистка всех запросов
  void clearPendingRequests() {
    _pendingRequests.clear();
  }

  @override
  void onClose() {
    _dio.close();
    super.onClose();
  }
}
