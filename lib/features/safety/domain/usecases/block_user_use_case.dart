import '../../../match/domain/repositories/match_repository.dart';
import '../repositories/block_repository.dart';

sealed class BlockUserResult {}

class BlockUserSuccess extends BlockUserResult {}

class BlockUserValidationError extends BlockUserResult {
  BlockUserValidationError(this.reason);
  final String reason;
}

class BlockUserFailure extends BlockUserResult {}

/// Package-visible for testing. Mirrors Cloud Function makeMatchId:
/// sorts the two user IDs and joins with underscore.
String blockMakeMatchId(String a, String b) {
  final sorted = [a, b]..sort();
  return '${sorted[0]}_${sorted[1]}';
}

class BlockUserUseCase {
  const BlockUserUseCase({
    required this.blockRepository,
    required this.matchRepository,
  });

  final BlockRepository blockRepository;
  final MatchRepository matchRepository;

  Future<BlockUserResult> execute({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    if (currentUserId.trim().isEmpty) {
      return BlockUserValidationError('currentUserId is empty');
    }
    if (blockedUserId.trim().isEmpty) {
      return BlockUserValidationError('blockedUserId is empty');
    }
    if (currentUserId == blockedUserId) {
      return BlockUserValidationError('cannot block self');
    }

    try {
      await blockRepository.blockUser(
        currentUserId: currentUserId,
        blockedUserId: blockedUserId,
      );
    } catch (_) {
      return BlockUserFailure();
    }

    // Best-effort: deactivate any active match between the two users.
    // The match ID is deterministic (sorted IDs joined by '_'), mirroring the
    // Cloud Function. If no match exists or it is already inactive, the
    // Firestore update throws — we catch and continue silently.
    final matchId = blockMakeMatchId(currentUserId, blockedUserId);
    try {
      await matchRepository.unmatch(
        matchId: matchId,
        currentUserId: currentUserId,
      );
    } catch (_) {
      // No active match exists or it is already inactive; not an error.
    }

    return BlockUserSuccess();
  }
}
