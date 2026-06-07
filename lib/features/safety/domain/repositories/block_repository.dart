import '../models/blocked_user.dart';

abstract class BlockRepository {
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  });

  Future<bool> isBlocked({
    required String currentUserId,
    required String targetUserId,
  });

  Stream<Set<String>> watchBlockedUserIds({
    required String currentUserId,
  });

  Future<List<BlockedUser>> fetchBlockedUsers({
    required String currentUserId,
  });

  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  });
}
