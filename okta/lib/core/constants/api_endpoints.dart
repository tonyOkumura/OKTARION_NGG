/// Константы для API endpoints
/// Содержит все пути к API endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // ==================== AUTH ENDPOINTS ====================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // ==================== USER ENDPOINTS ====================
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String deleteAccount = '/user/account';
  static const String changePassword = '/user/change-password';
  static const String uploadAvatar = '/user/avatar';

  // ==================== SETTINGS ENDPOINTS ====================
  static const String userSettings = '/user/settings';
  static const String updateSettings = '/user/settings';
  static const String notificationSettings = '/user/notifications';
  static const String privacySettings = '/user/privacy';

  // ==================== GENERAL ENDPOINTS ====================
  static const String healthCheck = '/health';
  static const String version = '/version';
  static const String uploadFile = '/upload';
  static const String downloadFile = '/download';

  // ==================== MODULE ENDPOINTS ====================
  static const String messages = '/messages';
  static const String tasks = '/tasks';
  static const String events = '/events';
  static const String files = '/files';
  static const String contacts = '/contacts';
}
