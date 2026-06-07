import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  match,
  message,
  like,
  verification;

  static NotificationType fromString(String? value) =>
      NotificationType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => NotificationType.match,
      );
}

enum NotificationReferenceType {
  match,
  message,
  like,
  verificationRequest;

  /// Parses Firestore string values, including snake_case variant for
  /// verification_request.
  static NotificationReferenceType? fromString(String? value) {
    if (value == null) return null;
    final normalized =
        value == 'verification_request' ? 'verificationRequest' : value;
    return NotificationReferenceType.values.firstWhere(
      (t) => t.name == normalized,
      orElse: () => NotificationReferenceType.match,
    );
  }

  String toJson() =>
      this == NotificationReferenceType.verificationRequest
          ? 'verification_request'
          : name;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    this.referenceId,
    this.referenceType,
    this.createdAt,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final bool read;
  final String? referenceId;
  final NotificationReferenceType? referenceType;
  final DateTime? createdAt;

  factory AppNotification.fromFirestore(
    String docId,
    Map<String, dynamic> data,
  ) {
    return AppNotification(
      id: data['id'] as String? ?? docId,
      userId: data['userId'] as String? ?? '',
      type: NotificationType.fromString(data['type'] as String?),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      read: data['read'] as bool? ?? false,
      referenceId: data['referenceId'] as String?,
      referenceType: NotificationReferenceType.fromString(
        data['referenceType'] as String?,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'read': read,
      if (referenceId != null) 'referenceId': referenceId,
      if (referenceType != null) 'referenceType': referenceType!.toJson(),
    };
  }
}
