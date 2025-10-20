import 'contact_model.dart';

/// Модель ответа с контактами
class ContactsResponse {
  final List<Contact> contacts;
  final bool hasMore;
  final String? nextCursor;
  final int? totalCount;

  const ContactsResponse({
    required this.contacts,
    required this.hasMore,
    this.nextCursor,
    this.totalCount,
  });

  factory ContactsResponse.fromJson(Map<String, dynamic> json) {
    return ContactsResponse(
      contacts: (json['contacts'] as List)
          .map((contactJson) => Contact.fromJson(contactJson as Map<String, dynamic>))
          .toList(),
      hasMore: json['hasMore'] as bool,
      nextCursor: json['nextCursor'] as String?,
      totalCount: json['totalCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contacts': contacts.map((contact) => contact.toJson()).toList(),
      'hasMore': hasMore,
      'nextCursor': nextCursor,
      'totalCount': totalCount,
    };
  }

  @override
  String toString() {
    return 'ContactsResponse(contacts: ${contacts.length}, hasMore: $hasMore)';
  }
}
