/// Модель контакта
class Contact {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? email;
  final String? phone;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final String? statusMessage;
  final String role;
  final String? department;
  final String? rank;
  final String? position;
  final String? company;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String locale;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Contact({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.displayName,
    this.email,
    this.phone,
    required this.isOnline,
    this.lastSeenAt,
    this.statusMessage,
    required this.role,
    this.department,
    this.rank,
    this.position,
    this.company,
    this.avatarUrl,
    this.dateOfBirth,
    required this.locale,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isOnline: json['isOnline'] as bool,
      lastSeenAt: json['lastSeenAt'] != null 
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
      statusMessage: json['statusMessage'] as String?,
      role: json['role'] as String,
      department: json['department'] as String?,
      rank: json['rank'] as String?,
      position: json['position'] as String?,
      company: json['company'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      locale: json['locale'] as String,
      timezone: json['timezone'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'isOnline': isOnline,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'statusMessage': statusMessage,
      'role': role,
      'department': department,
      'rank': rank,
      'position': position,
      'company': company,
      'avatarUrl': avatarUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'locale': locale,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Получить отображаемое имя контакта
  String get displayNameOrUsername {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    return username;
  }

  /// Проверить, есть ли аватар
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Получить инициалы для аватара
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0].toUpperCase()}${lastName![0].toUpperCase()}';
    }
    if (firstName != null) {
      return firstName![0].toUpperCase();
    }
    return username[0].toUpperCase();
  }

  @override
  String toString() {
    return 'Contact(id: $id, username: $username, displayName: $displayNameOrUsername)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
