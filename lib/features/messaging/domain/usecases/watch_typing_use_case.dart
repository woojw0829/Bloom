import '../repositories/typing_repository.dart';

class WatchTypingUseCase {
  const WatchTypingUseCase(this._repository);

  final TypingRepository _repository;

  Stream<bool> execute({
    required String matchId,
    required String currentUserId,
  }) {
    if (matchId.trim().isEmpty || currentUserId.trim().isEmpty) {
      return Stream.value(false);
    }
    return _repository
        .watchTypingUserIds(matchId: matchId)
        .map((ids) => ids.any((id) => id != currentUserId))
        .handleError((Object _) {});
  }
}
