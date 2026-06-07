import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/repositories/like_repository_impl.dart';
import '../../domain/repositories/like_repository.dart';
import '../../domain/usecases/load_liked_user_ids_use_case.dart';

final likeRepositoryProvider = Provider<LikeRepository>(
  (_) => LikeRepositoryImpl(),
);

final likedUserIdsNotifierProvider =
    NotifierProvider<LikedUserIdsNotifier, Set<String>>(
  LikedUserIdsNotifier.new,
);

class LikedUserIdsNotifier extends Notifier<Set<String>> {
  var _disposed = false;

  @override
  Set<String> build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    ref.watch(currentUserProvider.select((a) => a.valueOrNull?.id));
    Future.microtask(_load);
    return const {};
  }

  Future<void> _load() async {
    final userId = ref.read(currentUserProvider).valueOrNull?.id;
    if (userId == null || userId.isEmpty || _disposed) return;
    final ids = await LoadLikedUserIdsUseCase(
      repository: ref.read(likeRepositoryProvider),
    ).call(userId);
    if (_disposed) return;
    state = ids;
  }

  void addId(String id) {
    if (id.isEmpty) return;
    state = {...state, id};
  }
}
