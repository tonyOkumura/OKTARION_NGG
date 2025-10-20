class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    // Если ответ содержит поля success/data - это обернутый ответ
    if (json.containsKey('success')) {
      return ApiResponse<T>(
        success: json['success'] ?? false,
        data: json['data'] != null && fromJsonT != null 
            ? fromJsonT(json['data']) 
            : json['data'],
        message: json['message'],
        statusCode: json['status_code'],
        errors: json['errors'],
      );
    } else {
      // Если ответ не содержит success - это прямой ответ сервера
      return ApiResponse<T>(
        success: true, // Считаем успешным, если сервер ответил
        data: fromJsonT != null ? fromJsonT(json) : json as T,
        message: null,
        statusCode: null,
        errors: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'status_code': statusCode,
      'errors': errors,
    };
  }
}

class ApiError {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'Unknown error',
      statusCode: json['status_code'],
      details: json['details'],
    );
  }

  @override
  String toString() => message;
}

class RefreshTokenResponse {
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;

  const RefreshTokenResponse({
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'] ?? 3600,
    );
  }
}
