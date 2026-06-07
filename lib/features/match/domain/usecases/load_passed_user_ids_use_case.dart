import '../repositories/pass_repository.dart';

class LoadPassedUserIdsUseCase {
  const LoadPassedUserIdsUseCase({required this.repository});

  final PassRepository repository;

  /// Returns the set of user IDs that [currentUserId] has passed on.
  /// Returns an empty set if [currentUserId] is empty or if the load fails.
  Future<Set<String>> call(String currentUserId) async {
    if (currentUserId.isEmpty) return const {};
    try {
      return await repository.loadPassedUserIds(currentUserId);
    } catch (_) {
      return const {};
    }
  }
}
