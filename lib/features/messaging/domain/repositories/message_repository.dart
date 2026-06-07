import '../models/chat_message.dart';

abstract class MessageRepository {
  Stream<List<ChatMessage>> watchMessages({
    required String matchId,
    int limit = 50,
  });

  Future<void> sendTextMessage({
    required String matchId,
    required String senderId,
    required String content,
  });

  Future<void> sendImageMessage({
    required String matchId,
    required String senderId,
    required String imageFilePath,
  });

  Future<void> markMessagesAsRead({
    required String matchId,
    required String currentUserId,
    required List<String> messageIds,
  });
}
