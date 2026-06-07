import '../models/like_record.dart';
import '../repositories/like_repository.dart';

// ── Outcome sealed hierarchy ──────────────────────────────────────────────────

sealed class RecordLikeOutcome {
  const RecordLikeOutcome();
}

final class RecordLikeSuccess extends RecordLikeOutcome {
  const RecordLikeSuccess();
}

final class RecordLikeValidationError extends RecordLikeOutcome {
  const RecordLikeValidationError(this.reason);
  final String reason;
}

final class RecordLikeFailure extends RecordLikeOutcome {
  const RecordLikeFailure();
}

// ── Use case ──────────────────────────────────────────────────────────────────

class RecordLikeUseCase {
  const RecordLikeUseCase({required this.repository});

  final LikeRepository repository;

  Future<RecordLikeOutcome> call({
    required String fromUserId,
    required String toUserId,
    required LikeType type,
  }) async {
    if (fromUserId.isEmpty) {
      return const RecordLikeValidationError('fromUserId is empty');
    }
    if (toUserId.isEmpty) {
      return const RecordLikeValidationError('toUserId is empty');
    }
    if (fromUserId == toUserId) {
      return const RecordLikeValidationError('cannot like self');
    }
    try {
      await repository.recordLike(
        fromUserId: fromUserId,
        toUserId: toUserId,
        type: type,
      );
      return const RecordLikeSuccess();
    } catch (_) {
      return const RecordLikeFailure();
    }
  }
}
