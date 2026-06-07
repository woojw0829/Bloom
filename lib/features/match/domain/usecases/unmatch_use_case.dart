import '../repositories/match_repository.dart';

sealed class UnmatchResult {}

class UnmatchSuccess extends UnmatchResult {}

class UnmatchValidationError extends UnmatchResult {}

class UnmatchFailure extends UnmatchResult {}

class UnmatchUseCase {
  const UnmatchUseCase(this._repository);

  final MatchRepository _repository;

  Future<UnmatchResult> execute({
    required String matchId,
    required String currentUserId,
  }) async {
    if (matchId.trim().isEmpty) return UnmatchValidationError();
    if (currentUserId.trim().isEmpty) return UnmatchValidationError();
    try {
      await _repository.unmatch(
        matchId: matchId,
        currentUserId: currentUserId,
      );
      return UnmatchSuccess();
    } catch (_) {
      return UnmatchFailure();
    }
  }
}
