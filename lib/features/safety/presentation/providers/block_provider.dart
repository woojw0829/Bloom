import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../match/presentation/providers/match_celebration_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/repositories/block_repository_impl.dart';
import '../../domain/repositories/block_repository.dart';
import '../../domain/usecases/block_user_use_case.dart';
import '../../domain/usecases/unblock_user_use_case.dart';

final blockRepositoryProvider = Provider<BlockRepository>(
  (_) => BlockRepositoryImpl(),
);

final blockUserUseCaseProvider = Provider<BlockUserUseCase>(
  (ref) => BlockUserUseCase(
    blockRepository: ref.watch(blockRepositoryProvider),
    matchRepository: ref.watch(matchRepositoryProvider),
  ),
);

final unblockUserUseCaseProvider = Provider<UnblockUserUseCase>(
  (ref) => UnblockUserUseCase(
    blockRepository: ref.watch(blockRepositoryProvider),
  ),
);

/// Streams the set of user IDs blocked by the current user.
///
/// Non-autoDispose: lives as long as the app, mirroring other feed providers.
/// Discovery feeds watch this provider and rebuild (reload) when new blocks
/// are added so blocked profiles disappear from all discovery surfaces.
final blockedUserIdsProvider = StreamProvider<Set<String>>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.id;
  if (uid == null || uid.isEmpty) return Stream.value(const {});
  return ref
      .watch(blockRepositoryProvider)
      .watchBlockedUserIds(currentUserId: uid);
});
