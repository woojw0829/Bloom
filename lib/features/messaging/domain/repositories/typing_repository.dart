abstract class TypingRepository {
  Future<void> setTyping({
    required String matchId,
    required String userId,
    required bool isTyping,
  });

  Stream<Set<String>> watchTypingUserIds({required String matchId});
}
