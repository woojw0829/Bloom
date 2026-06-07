import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../match/presentation/providers/match_celebration_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../domain/models/conversation_preview.dart';

/// Watches the current user's active matches and enriches each with the
/// matched user's public profile to build a [ConversationPreview] list.
///
/// Reads:  matches (participants only), users/{otherUserId} (public doc)
/// Writes: nothing
final conversationListProvider =
    StreamProvider<List<ConversationPreview>>((ref) {
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  if (currentUser == null) return Stream.value(const []);

  final matchRepo = ref.watch(matchRepositoryProvider);
  final userRepo = ref.read(userRepositoryProvider);

  return matchRepo
      .watchActiveMatches(currentUser.id)
      .asyncMap((matches) async {
    final results = await Future.wait(
      matches.map((match) async {
        final otherUserId = match.otherUserId(currentUser.id);
        if (otherUserId == null) return null;
        final profile = await userRepo.getUserProfile(otherUserId);
        return ConversationPreview.fromMatchAndProfile(
          match: match,
          otherUserId: otherUserId,
          profile: profile,
        );
      }),
    );
    return results.whereType<ConversationPreview>().toList();
  });
});
