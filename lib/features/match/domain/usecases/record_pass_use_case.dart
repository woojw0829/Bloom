import '../repositories/pass_repository.dart';

sealed class RecordPassOutcome {
  const RecordPassOutcome();
}

final class RecordPassSuccess extends RecordPassOutcome {
  const RecordPassSuccess();
}

final class RecordPassValidationError extends RecordPassOutcome {
  const RecordPassValidationError(this.reason);
  final String reason;
}

final class RecordPassFailure extends RecordPassOutcome {
  const RecordPassFailure();
}

class RecordPassUseCase {
  const RecordPassUseCase({required this.repository});

  final PassRepository repository;

  Future<RecordPassOutcome> call({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (currentUserId.isEmpty) {
      return const RecordPassValidationError('currentUserId is empty');
    }
    if (targetUserId.isEmpty) {
      return const RecordPassValidationError('targetUserId is empty');
    }
    if (currentUserId == targetUserId) {
      return const RecordPassValidationError('cannot pass self');
    }
    try {
      await repository.recordPass(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
      return const RecordPassSuccess();
    } catch (_) {
      return const RecordPassFailure();
    }
  }
}
