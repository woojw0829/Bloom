import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image;

  static MessageType fromString(String? value) => MessageType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => MessageType.text,
      );
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.type,
    required this.content,
    this.imageUrl,
    required this.readBy,
    required this.deleted,
    this.createdAt,
  });

  final String id;
  final String senderId;
  final MessageType type;
  final String content;
  final String? imageUrl;
  final List<String> readBy;
  final bool deleted;
  final DateTime? createdAt;

  factory ChatMessage.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      type: MessageType.fromString(data['type'] as String?),
      content: data['content'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      readBy: (data['readBy'] as List?)?.whereType<String>().toList() ?? [],
      deleted: data['deleted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  bool isReadBy(String userId) => readBy.contains(userId);

  bool isReadByOtherParticipant(String currentUserId) =>
      readBy.any((id) => id != currentUserId);

  bool shouldMarkRead(String currentUserId) =>
      !deleted &&
      currentUserId.isNotEmpty &&
      senderId != currentUserId &&
      !isReadBy(currentUserId);
}
