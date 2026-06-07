import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/user_model.dart';
import '../../../match/presentation/providers/like_provider.dart';
import '../../../match/presentation/providers/pass_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../safety/presentation/providers/block_provider.dart';
import '../../domain/models/discovery_filters.dart';
import '../../domain/models/discovery_profile.dart';
import '../../domain/usecases/load_discovery_profiles_use_case.dart';
import 'discovery_feed_provider.dart';
import 'discovery_filters_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class BrowseFeedState {
  const BrowseFeedState({
    this.profiles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.needsLocation = false,
    this.hasMore = true,
    this.lastDocument,
  });

  final List<DiscoveryProfile> profiles;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;
  final bool needsLocation;
  final bool hasMore;
  final QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument;

  bool get isEmpty =>
      !isLoading && !isLoadingMore && !hasError && !needsLocation &&
      profiles.isEmpty;

  BrowseFeedState copyWith({
    List<DiscoveryProfile>? profiles,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
    bool? needsLocation,
    bool? hasMore,
  }) {
    return BrowseFeedState(
      profiles: profiles ?? this.profiles,
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

/// Non-autoDispose: the browse shell branch preserves state across tab
/// switches. Rebuilds when userId or active filters change.
final browseFeedProvider =
    NotifierProvider<BrowseFeedNotifier, BrowseFeedState>(
  BrowseFeedNotifier.new,
);

class BrowseFeedNotifier extends Notifier<BrowseFeedState> {
  var _disposed = false;

  @override
  BrowseFeedState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    // Rebuild when the authenticated userId changes (login / logout).
    ref.watch(currentUserProvider.select((a) => a.valueOrNull?.id));

    // Rebuild when active filters change — reloads from page 1.
    ref.watch(discoveryFiltersProvider);

    // Rebuild when the blocked-user set changes.
    ref.watch(blockedUserIdsProvider);

    Future.microtask(_loadInitial);
    return const BrowseFeedState(isLoading: true);
  }

  UserModel? get _currentUser => ref.read(currentUserProvider).valueOrNull;
  DiscoveryFilters get _filters => ref.read(discoveryFiltersProvider);

  LoadDiscoveryProfilesUseCase get _useCase => LoadDiscoveryProfilesUseCase(
        repository: ref.read(discoveryRepositoryProvider),
      );

  Future<void> _loadInitial() async {
    if (_disposed) return;
    state = const BrowseFeedState(isLoading: true);
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

  Future<void> refresh() async {
    if (state.isLoading || state.isLoadingMore) return;
    await _loadInitial();
  }

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

  void _applyOutcome(LoadDiscoveryOutcome outcome, {required bool isInitial}) {
    switch (outcome) {
      case LoadDiscoveryUnauthenticated():
        state = const BrowseFeedState();
      case LoadDiscoveryNeedsLocation():
        state = const BrowseFeedState(needsLocation: true);
      case LoadDiscoveryError():
        state = isInitial
            ? const BrowseFeedState(hasError: true)
            : BrowseFeedState(
                profiles: state.profiles,
                hasMore: state.hasMore,
                lastDocument: state.lastDocument,
                hasError: true,
              );
      case LoadDiscoverySuccess(:final profiles, :final lastDocument, :final hasMore):
        if (isInitial) {
          state = BrowseFeedState(
            profiles: profiles,
            lastDocument: lastDocument,
            hasMore: hasMore,
          );
        } else {
          state = BrowseFeedState(
            profiles: [...state.profiles, ...profiles],
            lastDocument: lastDocument,
            hasMore: hasMore,
          );
        }
    }
  }
}
