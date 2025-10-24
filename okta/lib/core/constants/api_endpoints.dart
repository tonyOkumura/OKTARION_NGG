/// Константы для API endpoints
/// Содержит все пути к API endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // ==================== USER PROFILE ====================
  static const String getMe = '/contacts/me';
  static const String updateMe = '/contacts/me';
  
  // ==================== USER CONTACT CREATION ====================
  static const String createUserContact = '/contacts/';
  
  // ==================== CONTACTS MANAGEMENT ====================
  static const String getContacts = '/contacts/';
}
