import '../repositories/block_repository.dart';

sealed class UnblockUserResult {}

class UnblockUserSuccess extends UnblockUserResult {}

class UnblockUserValidationError extends UnblockUserResult {
  UnblockUserValidationError(this.reason);
  final String reason;
}

class UnblockUserFailure extends UnblockUserResult {}

class UnblockUserUseCase {
  const UnblockUserUseCase({required this.blockRepository});

  final BlockRepository blockRepository;

  Future<UnblockUserResult> execute({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    if (currentUserId.trim().isEmpty) {
      return UnblockUserValidationError('currentUserId is empty');
    }
    if (blockedUserId.trim().isEmpty) {
      return UnblockUserValidationError('blockedUserId is empty');
    }
    if (currentUserId == blockedUserId) {
      return UnblockUserValidationError('cannot unblock self');
    }
    try {
      await blockRepository.unblockUser(
        currentUserId: currentUserId,
        blockedUserId: blockedUserId,
      );
    } catch (_) {
      return UnblockUserFailure();
    }
    return UnblockUserSuccess();
  }
}
