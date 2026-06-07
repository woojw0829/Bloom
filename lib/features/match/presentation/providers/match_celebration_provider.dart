import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../explore/domain/models/discovery_profile.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/repositories/match_repository_impl.dart';
import '../../domain/models/match_record.dart';
import '../../domain/repositories/match_repository.dart';
import '../../domain/usecases/unmatch_use_case.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class MatchCelebrationState {
  const MatchCelebrationState({
    this.pendingLikedUserId,
    this.pendingLikedProfile,
    this.matchToShow,
  });

  final String? pendingLikedUserId;
  final DiscoveryProfile? pendingLikedProfile;

  /// Non-null means a new match is ready to celebrate.
  final MatchRecord? matchToShow;

  bool get hasCelebration => matchToShow != null;
}

// ── Providers ──────────────────────────────────────────────────────────────────

final matchRepositoryProvider = Provider<MatchRepository>(
  (_) => MatchRepositoryImpl(),
);

final unmatchUseCaseProvider = Provider<UnmatchUseCase>(
  (ref) => UnmatchUseCase(ref.watch(matchRepositoryProvider)),
);

final matchCelebrationProvider =
    NotifierProvider<MatchCelebrationNotifier, MatchCelebrationState>(
  MatchCelebrationNotifier.new,
);

// ── Notifier ───────────────────────────────────────────────────────────────────

class MatchCelebrationNotifier extends Notifier<MatchCelebrationState> {
  var _disposed = false;
  StreamSubscription<List<MatchRecord>>? _matchSub;
  final Set<String> _seenMatchIds = {};
  bool _initialSnapshotLoaded = false;

  @override
  MatchCelebrationState build() {
    _disposed = false;
    _seenMatchIds.clear();
    _initialSnapshotLoaded = false;

    ref.onDispose(() {
      _disposed = true;
      _matchSub?.cancel();
      _matchSub = null;
    });

    ref.watch(currentUserProvider.select((a) => a.valueOrNull?.id));
    Future.microtask(_initStream);
    return const MatchCelebrationState();
  }

  void _initStream() {
    if (_disposed) return;
    final currentUserId = ref.read(currentUserProvider).valueOrNull?.id;
    if (currentUserId == null || currentUserId.isEmpty) return;

    _matchSub?.cancel(); // fire-and-forget; subscription no longer receives events after cancel
    _matchSub = ref
        .read(matchRepositoryProvider)
        .watchActiveMatches(currentUserId)
        .listen(_onMatchesUpdate);
  }

  void _onMatchesUpdate(List<MatchRecord> matches) {
    if (_disposed) return;

    if (!_initialSnapshotLoaded) {
      // First emission — mark all existing matches as already seen.
      // Do not show celebration for matches created before this session.
      _seenMatchIds.addAll(matches.map((m) => m.id));
      _initialSnapshotLoaded = true;
      return;
    }

    final pending = state.pendingLikedUserId;
    for (final match in matches) {
      if (_seenMatchIds.contains(match.id)) continue;
      _seenMatchIds.add(match.id);
      if (pending != null && match.includesUser(pending)) {
        state = MatchCelebrationState(
          matchToShow: match,
          pendingLikedProfile: state.pendingLikedProfile,
        );
        return;
      }
    }
  }

  /// Registers a pending like target so that, if a match is created for them,
  /// the celebration UI will be shown. Replaces any previous pending target.
  void setPendingLike({
    required String userId,
    required DiscoveryProfile profile,
  }) {
    if (userId.isEmpty) return;
    state = MatchCelebrationState(
      pendingLikedUserId: userId,
      pendingLikedProfile: profile,
    );
  }

  /// Clears the celebration state after the user dismisses the sheet.
  void clearCelebration() {
    state = const MatchCelebrationState();
  }

  /// Exposed for unit tests only — calls [_onMatchesUpdate] directly without
  /// going through the Firestore stream, letting tests drive match events
  /// without complex async stream-setup timing.
  @visibleForTesting
  void emitMatchesForTesting(List<MatchRecord> matches) =>
      _onMatchesUpdate(matches);
}
