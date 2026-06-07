import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../domain/usecases/unblock_user_use_case.dart';
import 'block_provider.dart';

class BlockedUserPreview {
  const BlockedUserPreview({
    required this.userId,
    this.displayName,
    this.photoUrl,
  });

  final String userId;
  final String? displayName;
  final String? photoUrl;
}

class SafetyCenterNotifier
    extends AutoDisposeAsyncNotifier<List<BlockedUserPreview>> {
  @override
  Future<List<BlockedUserPreview>> build() async {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return [];

    final blockedUsers = await ref
        .read(blockRepositoryProvider)
        .fetchBlockedUsers(currentUserId: user.id);

    final userRepo = ref.read(userRepositoryProvider);
    final previews = <BlockedUserPreview>[];

    for (final blocked in blockedUsers) {
      final profile = await userRepo.getUserProfile(blocked.blockedUserId);
      previews.add(BlockedUserPreview(
        userId: blocked.blockedUserId,
        displayName: profile?.nickname,
        photoUrl: profile?.profileImages.isNotEmpty == true
            ? profile!.profileImages.first
            : null,
      ));
    }

    return previews;
  }

  Future<UnblockUserResult> unblock(String blockedUserId) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return UnblockUserFailure();

    final result = await ref.read(unblockUserUseCaseProvider).execute(
          currentUserId: user.id,
          blockedUserId: blockedUserId,
        );

    if (result is UnblockUserSuccess) {
      ref.invalidateSelf();
    }

    return result;
  }
}

final safetyCenterProvider = AutoDisposeAsyncNotifierProvider<
    SafetyCenterNotifier, List<BlockedUserPreview>>(
  SafetyCenterNotifier.new,
);
