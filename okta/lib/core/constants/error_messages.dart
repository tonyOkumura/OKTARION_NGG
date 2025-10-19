/// Константы для сообщений об ошибках
/// Содержит все тексты ошибок, используемые в приложении
class ErrorMessages {
  ErrorMessages._();

  // ==================== NETWORK ERRORS ====================
  static const String networkError = 'Network error occurred';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'Unknown error occurred';
  static const String timeoutError = 'Request timeout';
  static const String noInternetConnection = 'No internet connection';
  static const String connectionTimeout = 'Connection timeout';
  static const String receiveTimeout = 'Receive timeout';

  // ==================== AUTHENTICATION ERRORS ====================
  static const String invalidCredentials = 'Invalid email or password';
  static const String userNotFound = 'User not found';
  static const String accountDisabled = 'Account is disabled';
  static const String accountLocked = 'Account is locked';
  static const String tokenExpired = 'Session expired, please login again';
  static const String invalidToken = 'Invalid token';
  static const String unauthorizedAccess = 'Unauthorized access';

  // ==================== VALIDATION ERRORS ====================
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordTooLong = 'Password must be less than 50 characters';
  static const String usernameRequired = 'Username is required';
  static const String usernameTooShort = 'Username must be at least 3 characters';
  static const String usernameTooLong = 'Username must be less than 20 characters';
  static const String phoneInvalid = 'Please enter a valid phone number';
  static const String fieldRequired = 'This field is required';

  // ==================== REGISTRATION ERRORS ====================
  static const String emailAlreadyExists = 'Email already exists';
  static const String usernameAlreadyExists = 'Username already exists';
  static const String weakPassword = 'Password is too weak';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String termsNotAccepted = 'You must accept the terms and conditions';

  // ==================== PROFILE ERRORS ====================
  static const String profileUpdateFailed = 'Failed to update profile';
  static const String avatarUploadFailed = 'Failed to upload avatar';
  static const String passwordChangeFailed = 'Failed to change password';
  static const String currentPasswordIncorrect = 'Current password is incorrect';

  // ==================== FILE ERRORS ====================
  static const String fileNotFound = 'File not found';
  static const String fileUploadFailed = 'File upload failed';
  static const String fileDownloadFailed = 'File download failed';
  static const String fileSizeTooLarge = 'File size is too large';
  static const String unsupportedFileType = 'Unsupported file type';

  // ==================== GENERAL ERRORS ====================
  static const String operationFailed = 'Operation failed';
  static const String dataNotFound = 'Data not found';
  static const String permissionDenied = 'Permission denied';
  static const String featureNotAvailable = 'Feature not available';
  static const String maintenanceMode = 'Application is under maintenance';
}
