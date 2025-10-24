import 'contact_model.dart';

/// Модель для обновления профиля пользователя
class UpdateProfileRequest {
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? email;
  final String? phone;
  final String? statusMessage;
  final String? department;
  final String? rank;
  final String? position;
  final String? company;

  const UpdateProfileRequest({
    this.username,
    this.firstName,
    this.lastName,
    this.displayName,
    this.email,
    this.phone,
    this.statusMessage,
    this.department,
    this.rank,
    this.position,
    this.company,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (username != null) data['username'] = username;
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (displayName != null) data['displayName'] = displayName;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (statusMessage != null) data['statusMessage'] = statusMessage;
    if (department != null) data['department'] = department;
    if (rank != null) data['rank'] = rank;
    if (position != null) data['position'] = position;
    if (company != null) data['company'] = company;
    
    return data;
  }

  /// Создать запрос из Contact модели
  factory UpdateProfileRequest.fromContact(Contact contact) {
    return UpdateProfileRequest(
      username: contact.username,
      firstName: contact.firstName,
      lastName: contact.lastName,
      displayName: contact.displayName,
      email: contact.email,
      phone: contact.phone,
      statusMessage: contact.statusMessage,
      department: contact.department,
      rank: contact.rank,
      position: contact.position,
      company: contact.company,
    );
  }

  /// Проверить, есть ли изменения
  bool get hasChanges {
    return username != null ||
           firstName != null ||
           lastName != null ||
           displayName != null ||
           email != null ||
           phone != null ||
           statusMessage != null ||
           department != null ||
           rank != null ||
           position != null ||
           company != null;
  }

  @override
  String toString() {
    return 'UpdateProfileRequest(${toJson()})';
  }
}
