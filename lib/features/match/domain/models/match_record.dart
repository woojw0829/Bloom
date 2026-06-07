import 'package:cloud_firestore/cloud_firestore.dart';

class MatchRecord {
  const MatchRecord({
    required this.id,
    required this.users,
    required this.compatibilityScore,
    this.createdAt,
    this.lastMessageAt,
    required this.lastMessagePreview,
    required this.active,
  });

  final String id;
  final List<String> users;
  final int compatibilityScore;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;
  final String lastMessagePreview;
  final bool active;

  bool includesUser(String userId) => users.contains(userId);

  String? otherUserId(String currentUserId) {
    if (!includesUser(currentUserId)) return null;
    for (final uid in users) {
      if (uid != currentUserId) return uid;
    }
    return null;
  }

  factory MatchRecord.fromFirestore(Map<String, dynamic> data) {
    final rawUsers = data['users'];
    final users = rawUsers is List
        ? rawUsers
            .whereType<String>()
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];
    return MatchRecord(
      id: data['id'] is String ? data['id'] as String : '',
      users: List.unmodifiable(users),
      compatibilityScore:
          data['compatibilityScore'] is int ? data['compatibilityScore'] as int : 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastMessagePreview: data['lastMessagePreview'] is String
          ? data['lastMessagePreview'] as String
          : '',
      active: data['active'] is bool ? data['active'] as bool : false,
    );
  }
}
