import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/user_model.dart';
import '../../../match/domain/models/like_record.dart';
import '../../../match/domain/models/swipe_action.dart';
import '../../../match/domain/usecases/record_like_use_case.dart';
import '../../../match/domain/usecases/record_pass_use_case.dart';
import '../../../match/presentation/providers/like_provider.dart';
import '../../../match/presentation/providers/match_celebration_provider.dart';
import '../../../match/presentation/providers/pass_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../safety/presentation/providers/block_provider.dart';
import '../../data/repositories/discovery_repository_impl.dart';
import '../../domain/models/discovery_filters.dart';
import '../../domain/models/discovery_profile.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../../domain/usecases/load_discovery_profiles_use_case.dart';
import 'discovery_filters_provider.dart';

// ── Supporting provider ───────────────────────────────────────────────────────

final discoveryRepositoryProvider = Provider<DiscoveryRepository>(
  (_) => DiscoveryRepositoryImpl(),
);

// ── State ─────────────────────────────────────────────────────────────────────

class DiscoveryFeedState {
  const DiscoveryFeedState({
    this.profiles = const [],
    this.visibleIndex = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.needsLocation = false,
    this.hasMore = true,
    this.lastDocument,
  });

  final List<DiscoveryProfile> profiles;

  /// Index into [profiles] of the current top-of-stack card.
  /// Incremented by [DiscoveryFeedNotifier.dismissTop]; never decremented.
  final int visibleIndex;

  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final bool needsLocation;
  final bool hasMore;
  final QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument;

  /// Profiles remaining in the visible stack (from [visibleIndex] onward).
  List<DiscoveryProfile> get remaining {
    final start = visibleIndex.clamp(0, profiles.length);
    return profiles.sublist(start);
  }

  bool get isEmpty =>
      !isLoading && !isLoadingMore && !hasError && !needsLocation &&
      remaining.isEmpty;

  DiscoveryFeedState copyWith({
    List<DiscoveryProfile>? profiles,
    int? visibleIndex,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    bool? needsLocation,
    bool? hasMore,
  }) {
    return DiscoveryFeedState(
      profiles: profiles ?? this.profiles,
      visibleIndex: visibleIndex ?? this.visibleIndex,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      needsLocation: needsLocation ?? this.needsLocation,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument,
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Non-autoDispose: the explore shell branch preserves state across tab
/// switches, so keeping the provider alive avoids redundant Firestore reads.
final discoveryFeedProvider =
    NotifierProvider<DiscoveryFeedNotifier, DiscoveryFeedState>(
  DiscoveryFeedNotifier.new,
);

class DiscoveryFeedNotifier extends Notifier<DiscoveryFeedState> {
  // Notifier does not expose `mounted`; track disposal manually.
  var _disposed = false;

  @override
  DiscoveryFeedState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    // Rebuild when the authenticated userId changes (login / logout).
    ref.watch(currentUserProvider.select((a) => a.valueOrNull?.id));

    // Rebuild when active filters change — reloads from page 1 with new
    // criteria. visibleIndex resets to 0 via the initial state returned below.
    ref.watch(discoveryFiltersProvider);

    // Rebuild when the blocked-user set changes so blocked profiles are
    // immediately removed from the visible stack on the next load.
    ref.watch(blockedUserIdsProvider);

    Future.microtask(_loadInitial);
    return const DiscoveryFeedState(isLoading: true);
  }

  UserModel? get _currentUser => ref.read(currentUserProvider).valueOrNull;
  DiscoveryFilters get _filters => ref.read(discoveryFiltersProvider);

  LoadDiscoveryProfilesUseCase get _useCase => LoadDiscoveryProfilesUseCase(
        repository: ref.read(discoveryRepositoryProvider),
      );

  Future<void> _loadInitial() async {
    if (_disposed) return;
    state = const DiscoveryFeedState(isLoading: true);

    final outcome = await _useCase.call(
      currentUser: _currentUser,
      filters: _filters,
      passedUserIds: ref.read(passedUserIdsNotifierProvider),
      likedUserIds: ref.read(likedUserIdsNotifierProvider),
      blockedUserIds: ref.read(blockedUserIdsProvider).valueOrNull ?? const {},
    );
    if (_disposed) return;

    _applyOutcome(outcome, isInitial: true);
  }

  /// Reloads the feed from the first page. No-ops while loading.
  Future<void> refresh() async {
    if (state.isLoading || state.isLoadingMore) return;
    await _loadInitial();
  }

  /// Appends the next page. Called automatically when near end of stack.
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;
    if (state.lastDocument == null) return;

    state = state.copyWith(isLoadingMore: true);

    final outcome = await _useCase.call(
      currentUser: _currentUser,
      afterDocument: state.lastDocument,
      filters: _filters,
      passedUserIds: ref.read(passedUserIdsNotifierProvider),
      likedUserIds: ref.read(likedUserIdsNotifierProvider),
      blockedUserIds: ref.read(blockedUserIdsProvider).valueOrNull ?? const {},
    );
    if (_disposed) return;

    _applyOutcome(outcome, isInitial: false);
  }

  /// Advances past the current top card with a semantic [action].
  ///
  /// For [SwipeAction.pass]: records the pass to Firestore and updates the
  /// in-memory passed-IDs set so the profile is excluded from future loads.
  /// For [SwipeAction.like] / [SwipeAction.superLike]: records the like to
  /// Firestore and updates the in-memory liked-IDs set.
  void dismissTopWithAction(SwipeAction action) {
    final remaining = state.remaining;
    if (remaining.isEmpty) return;

    switch (action) {
      case SwipeAction.pass:
        final targetId = remaining.first.id;
        ref.read(passedUserIdsNotifierProvider.notifier).addId(targetId);
        _recordPassSilently(targetId);
      case SwipeAction.like:
        final profile = remaining.first;
        ref.read(likedUserIdsNotifierProvider.notifier).addId(profile.id);
        ref
            .read(matchCelebrationProvider.notifier)
            .setPendingLike(userId: profile.id, profile: profile);
        _recordLikeSilently(profile.id, LikeType.like);
      case SwipeAction.superLike:
        final profile = remaining.first;
        ref.read(likedUserIdsNotifierProvider.notifier).addId(profile.id);
        ref
            .read(matchCelebrationProvider.notifier)
            .setPendingLike(userId: profile.id, profile: profile);
        _recordLikeSilently(profile.id, LikeType.superLike);
    }

    dismissTop();
  }

  Future<void> _recordPassSilently(String targetId) async {
    final currentUserId = _currentUser?.id;
    if (currentUserId == null || currentUserId.isEmpty) return;
    await RecordPassUseCase(
      repository: ref.read(passRepositoryProvider),
    ).call(
      currentUserId: currentUserId,
      targetUserId: targetId,
    );
    // RecordPassOutcome intentionally ignored.
  }

  Future<void> _recordLikeSilently(String targetId, LikeType type) async {
    final currentUserId = _currentUser?.id;
    if (currentUserId == null || currentUserId.isEmpty) return;
    await RecordLikeUseCase(
      repository: ref.read(likeRepositoryProvider),
    ).call(
      fromUserId: currentUserId,
      toUserId: targetId,
      type: type,
    );
    // RecordLikeOutcome intentionally ignored.
  }

  /// Advances past the current top card (in-memory only; no Firestore writes).
  /// Automatically prefetches the next page when the stack runs low.
  void dismissTop() {
    final remaining = state.remaining;
    if (remaining.isEmpty) return;

    // Prefetch when 3 or fewer cards remain in the visible stack.
    if (remaining.length <= 3 && state.hasMore && !state.isLoadingMore) {
      Future.microtask(loadMore);
    }

    state = state.copyWith(visibleIndex: state.visibleIndex + 1);
  }

  void _applyOutcome(LoadDiscoveryOutcome outcome, {required bool isInitial}) {
    switch (outcome) {
      case LoadDiscoveryUnauthenticated():
        state = const DiscoveryFeedState();
      case LoadDiscoveryNeedsLocation():
        state = const DiscoveryFeedState(needsLocation: true);
      case LoadDiscoveryError():
        state = isInitial
            ? const DiscoveryFeedState(hasError: true)
            : DiscoveryFeedState(
                profiles: state.profiles,
                visibleIndex: state.visibleIndex,
                hasMore: state.hasMore,
                lastDocument: state.lastDocument,
                hasError: true,
              );
      case LoadDiscoverySuccess(:final profiles, :final lastDocument, :final hasMore):
        if (isInitial) {
          state = DiscoveryFeedState(
            profiles: profiles,
            lastDocument: lastDocument,
            hasMore: hasMore,
          );
        } else {
          state = DiscoveryFeedState(
            profiles: [...state.profiles, ...profiles],
            visibleIndex: state.visibleIndex,
            lastDocument: lastDocument,
            hasMore: hasMore,
          );
        }
    }
  }
}
