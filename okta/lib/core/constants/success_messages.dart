/// Константы для сообщений об успехе
/// Содержит все тексты успешных операций, используемые в приложении
class SuccessMessages {
  SuccessMessages._();

  // ==================== AUTHENTICATION SUCCESS ====================
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String logoutSuccess = 'Logout successful';
  static const String passwordResetSuccess = 'Password reset successful';
  static const String emailVerificationSent = 'Verification email sent';
  static const String emailVerified = 'Email verified successfully';

  // ==================== PROFILE SUCCESS ====================
  static const String profileUpdated = 'Profile updated successfully';
  static const String avatarUpdated = 'Avatar updated successfully';
  static const String passwordChanged = 'Password changed successfully';
  static const String accountDeleted = 'Account deleted successfully';

  // ==================== SETTINGS SUCCESS ====================
  static const String settingsUpdated = 'Settings updated successfully';
  static const String notificationSettingsUpdated = 'Notification settings updated';
  static const String privacySettingsUpdated = 'Privacy settings updated';

  // ==================== DATA SUCCESS ====================
  static const String dataSaved = 'Data saved successfully';
  static const String dataUpdated = 'Data updated successfully';
  static const String dataDeleted = 'Data deleted successfully';
  static const String dataRetrieved = 'Data retrieved successfully';

  // ==================== FILE SUCCESS ====================
  static const String fileUploaded = 'File uploaded successfully';
  static const String fileDownloaded = 'File downloaded successfully';
  static const String fileDeleted = 'File deleted successfully';

  // ==================== GENERAL SUCCESS ====================
  static const String operationCompleted = 'Operation completed successfully';
  static const String changesSaved = 'Changes saved successfully';
  static const String actionCompleted = 'Action completed successfully';
  static const String requestProcessed = 'Request processed successfully';
}
