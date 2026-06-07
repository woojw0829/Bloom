abstract class PassRepository {
  /// Writes a pass record to users/{currentUserId}/passes/{targetUserId}.
  /// Uses set-with-overwrite so duplicate calls are idempotent.
  Future<void> recordPass({
    required String currentUserId,
    required String targetUserId,
  });

  /// Returns the set of user IDs that [currentUserId] has passed on.
  /// Document IDs under users/{currentUserId}/passes are the passed user IDs.
  Future<Set<String>> loadPassedUserIds(String currentUserId);
}
