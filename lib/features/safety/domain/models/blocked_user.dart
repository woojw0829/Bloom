import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedUser {
  const BlockedUser({
    required this.blockedUserId,
    this.createdAt,
  });

  final String blockedUserId;
  final DateTime? createdAt;

  factory BlockedUser.fromFirestore(String docId, Map<String, dynamic> data) {
    return BlockedUser(
      // Use field value when present; fall back to document ID.
      blockedUserId: data['blockedUserId'] is String
          ? data['blockedUserId'] as String
          : docId,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
