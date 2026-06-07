import '../repositories/like_repository.dart';

class LoadLikedUserIdsUseCase {
  const LoadLikedUserIdsUseCase({required this.repository});

  final LikeRepository repository;

  Future<Set<String>> call(String fromUserId) async {
    if (fromUserId.isEmpty) return const {};
    try {
      return await repository.loadSentLikedUserIds(fromUserId);
    } catch (_) {
      return const {};
    }
  }
}
