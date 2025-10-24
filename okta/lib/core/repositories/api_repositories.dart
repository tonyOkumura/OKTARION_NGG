import 'package:get/get.dart';
import 'package:okta/core/utils/log_service.dart';
import '../services/api_service.dart';
import '../models/api_models.dart';
import '../models/contacts_response_model.dart';
import '../models/contact_model.dart';
import '../models/update_profile_request.dart';
import '../constants/api_endpoints.dart';

// Базовый репозиторий
abstract class BaseRepository {
  final ApiService _apiService = Get.find<ApiService>();

  ApiService get api => _apiService;
}

// Репозиторий для контактов
class ContactsRepository extends BaseRepository {

  // Получить список контактов с пагинацией, поиском, фильтрацией и сортировкой
  Future<ApiResponse<ContactsResponse>> getContacts({
    String? search,
    String? cursor,
    int? limit,
    String? sortBy,
    String? sortOrder,
    // Параметры фильтрации
    String? role,
    String? department,
    String? company,
    bool? isOnline,
    String? locale,
    String? timezone,
    String? username,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? displayName,
    String? statusMessage,
    String? rank,
    String? position,
  }) async {
    final queryParams = <String, dynamic>{};
    
    // Поиск и пагинация
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (cursor != null) queryParams['cursor'] = cursor;
    if (limit != null) queryParams['limit'] = limit;
    
    // Сортировка
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
    
    // Фильтрация
    if (role != null) queryParams['role'] = role;
    if (department != null) queryParams['department'] = department;
    if (company != null) queryParams['company'] = company;
    if (isOnline != null) queryParams['is_online'] = isOnline;
    if (locale != null) queryParams['locale'] = locale;
    if (timezone != null) queryParams['timezone'] = timezone;
    if (username != null) queryParams['username'] = username;
    if (email != null) queryParams['email'] = email;
    if (phone != null) queryParams['phone'] = phone;
    if (firstName != null) queryParams['firstName'] = firstName;
    if (lastName != null) queryParams['lastName'] = lastName;
    if (displayName != null) queryParams['displayName'] = displayName;
    if (statusMessage != null) queryParams['statusMessage'] = statusMessage;
    if (rank != null) queryParams['rank'] = rank;
    if (position != null) queryParams['position'] = position;

    return await api.get<ContactsResponse>(
      ApiEndpoints.getContacts,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => ContactsResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  // Получить профиль текущего пользователя
  Future<ApiResponse<Contact>> getMe() async {
    return await api.get<Contact>(
      ApiEndpoints.getMe,
      fromJson: (data) => Contact.fromJson(data as Map<String, dynamic>),
    );
  }

  // Обновить профиль текущего пользователя
  Future<ApiResponse<Contact>> updateMe(UpdateProfileRequest request) async {
    final response = await api.put<Map<String, dynamic>>(
      ApiEndpoints.updateMe,
      data: request.toJson(),
      fromJson: (data) => data as Map<String, dynamic>,
    );
    
    // Если сервер вернул данные контакта, парсим их
    Contact? contact;
    if (response.data != null && response.data!.containsKey('id')) {
      try {
        contact = Contact.fromJson(response.data!);
      } catch (e) {
        LogService.w('⚠️ Failed to parse contact from response: $e');
      }
    }
    
    return ApiResponse<Contact>(
      success: response.success,
      data: contact,
      message: response.message,
      statusCode: response.statusCode,
      errors: response.errors,
    );
  }

}