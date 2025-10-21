import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/api_models.dart';
import '../models/contacts_response_model.dart';
import '../constants/api_endpoints.dart';

// Базовый репозиторий
abstract class BaseRepository {
  final ApiService _apiService = Get.find<ApiService>();

  ApiService get api => _apiService;
}

// Репозиторий для контактов
class ContactsRepository extends BaseRepository {

  // Получить список контактов
  Future<ApiResponse<ContactsResponse>> getContacts({
    String? search,
    String? cursor,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (cursor != null) queryParams['cursor'] = cursor;
    if (limit != null) queryParams['limit'] = limit;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

    return await api.get<ContactsResponse>(
      ApiEndpoints.getContacts,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => ContactsResponse.fromJson(data as Map<String, dynamic>),
    );
  }

}