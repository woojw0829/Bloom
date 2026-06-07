import '../models/like_record.dart';

abstract class LikeRepository {
  Future<void> recordLike({
    required String fromUserId,
    required String toUserId,
    required LikeType type,
  });

  Future<Set<String>> loadSentLikedUserIds(String fromUserId);
}
