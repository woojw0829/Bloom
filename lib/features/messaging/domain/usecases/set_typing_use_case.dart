import '../repositories/typing_repository.dart';

class SetTypingUseCase {
  const SetTypingUseCase(this._repository);

  final TypingRepository _repository;

  Future<void> execute({
    required String matchId,
    required String userId,
    required bool isTyping,
  }) async {
    if (matchId.trim().isEmpty || userId.trim().isEmpty) return;
    try {
      await _repository.setTyping(
        matchId: matchId,
        userId: userId,
        isTyping: isTyping,
      );
    } catch (_) {
      // Typing errors are non-critical; swallow silently.
    }
  }
}
