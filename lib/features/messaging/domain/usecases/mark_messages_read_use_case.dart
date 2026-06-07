import '../repositories/message_repository.dart';

class MarkMessagesReadUseCase {
  const MarkMessagesReadUseCase(this._repository);

  final MessageRepository _repository;

  Future<void> execute({
    required String matchId,
    required String currentUserId,
    required List<String> messageIds,
  }) async {
    if (matchId.trim().isEmpty || currentUserId.trim().isEmpty) return;
    final unique = messageIds.toSet().toList();
    if (unique.isEmpty) return;
    try {
      await _repository.markMessagesAsRead(
        matchId: matchId,
        currentUserId: currentUserId,
        messageIds: unique,
      );
    } catch (_) {}
  }
}
