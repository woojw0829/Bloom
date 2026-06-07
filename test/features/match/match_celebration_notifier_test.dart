import 'package:bloom/features/explore/domain/models/discovery_profile.dart';
import 'package:bloom/features/match/domain/models/match_record.dart';
import 'package:bloom/features/match/domain/repositories/match_repository.dart';
import 'package:bloom/features/match/presentation/providers/match_celebration_provider.dart';
import 'package:bloom/features/profile/presentation/providers/profile_providers.dart';
import 'package:bloom/shared/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Stub repository ───────────────────────────────────────────────────────────

class _StubMatchRepository implements MatchRepository {
  @override
  Stream<List<MatchRecord>> watchActiveMatches(String _) =>
      const Stream.empty();

  @override
  Future<void> unmatch({
    required String matchId,
    required String currentUserId,
  }) async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

final _fakeUser = UserModel(
  id: 'userA',
  email: 'a@test.com',
  nickname: 'Alice',
  birthDate: DateTime(1995),
  age: 29,
  identity: 'Gay',
  relationshipGoal: 'Serious',
  bio: '',
  city: 'Seoul',
  geoHash: 'abc',
  lastSeen: DateTime(2024),
  notificationSettings: const UserNotificationSettings(),
  compatibilityPreferences: const UserCompatibilityPreferences(),
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

DiscoveryProfile _profile(String id, String nickname) => DiscoveryProfile(
      id: id,
      nickname: nickname,
      age: 25,
      identity: 'Gay',
      relationshipGoal: 'Serious',
      bio: '',
      interests: const [],
      profileImages: const [],
      verificationLevel: 'none',
      premium: false,
      premiumBadgeVisible: false,
      city: 'Seoul',
      geoHash: 'abc',
      updatedAt: DateTime(2024),
    );

MatchRecord _match(String id, List<String> users) => MatchRecord(
      id: id,
      users: users,
      compatibilityScore: 0,
      lastMessagePreview: '',
      active: true,
    );

// Using an always-empty stream avoids async stream-setup timing issues.
// Tests drive match events via emitMatchesForTesting() to test the logic layer
// directly.
ProviderContainer _makeContainer() {
  return ProviderContainer(
    overrides: [
      matchRepositoryProvider
          .overrideWithValue(_StubMatchRepository()),
      currentUserProvider
          .overrideWith((_) => Stream.value(_fakeUser)),
    ],
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  group('MatchCelebrationNotifier', () {
    test('initial state has no celebration and no pending user', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final state = container.read(matchCelebrationProvider);
      expect(state.hasCelebration, isFalse);
      expect(state.pendingLikedUserId, isNull);
    });

    test('setPendingLike stores pending user and profile', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(matchCelebrationProvider.notifier);
      notifier.setPendingLike(userId: 'userB', profile: _profile('userB', 'Bob'));

      final state = container.read(matchCelebrationProvider);
      expect(state.pendingLikedUserId, equals('userB'));
      expect(state.pendingLikedProfile?.nickname, equals('Bob'));
      expect(state.hasCelebration, isFalse);
    });

    test('setPendingLike ignores empty userId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(matchCelebrationProvider.notifier);
      notifier.setPendingLike(userId: '', profile: _profile('', 'Nobody'));

      expect(container.read(matchCelebrationProvider).pendingLikedUserId, isNull);
    });

    test('clearCelebration resets state', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(matchCelebrationProvider.notifier);
      notifier.setPendingLike(userId: 'userB', profile: _profile('userB', 'Bob'));
      notifier.clearCelebration();

      final state = container.read(matchCelebrationProvider);
      expect(state.pendingLikedUserId, isNull);
      expect(state.hasCelebration, isFalse);
    });

    group('emitMatchesForTesting (matches-update logic)', () {
      test('first emission marks existing matches as seen — no celebration', () {
        final container = _makeContainer();
        addTearDown(container.dispose);

        final notifier = container.read(matchCelebrationProvider.notifier);
        notifier.setPendingLike(userId: 'userB', profile: _profile('userB', 'Bob'));

        // First emission is the startup snapshot.
        notifier.emitMatchesForTesting(
            [_match('userA_userB', ['userA', 'userB'])]);

        expect(container.read(matchCelebrationProvider).hasCelebration, isFalse);
      });

      test('new match with pending target triggers celebration', () {
        final container = _makeContainer();
        addTearDown(container.dispose);

        final notifier = container.read(matchCelebrationProvider.notifier);

        // Startup snapshot: no matches.
        notifier.emitMatchesForTesting([]);

        // User likes userB.
        notifier.setPendingLike(userId: 'userB', profile: _profile('userB', 'Bob'));

        // Cloud Function creates match → new emission.
        notifier
            .emitMatchesForTesting([_match('userA_userB', ['userA', 'userB'])]);

        final state = container.read(matchCelebrationProvider);
        expect(state.hasCelebration, isTrue);
        expect(state.matchToShow?.id, equals('userA_userB'));
        expect(state.pendingLikedProfile?.nickname, equals('Bob'));
      });

      test('new match with different user does not trigger celebration', () {
        final container = _makeContainer();
        addTearDown(container.dispose);

        final notifier = container.read(matchCelebrationProvider.notifier);
        notifier.emitMatchesForTesting([]); // startup
        notifier.setPendingLike(userId: 'userB', profile: _profile('userB', 'Bob'));

        // Match with userC — not the pending userB.
        notifier.emitMatchesForTesting([_match('userA_userC', ['userA', 'userC'])]);

        expect(container.read(matchCelebrationProvider).hasCelebration, isFalse);
      });

      test('celebration is not shown twice for the same match', () {
        final container = _makeContainer();
        addTearDown(container.dispose);

        final notifier = container.read(matchCelebrationProvider.notifier);
        notifier.emitMatchesForTesting([]); // startup
        notifier.setPendingLike(userId: 'userB', profile: _profile('userB', 'Bob'));

        // First emission — celebration fires.
        notifier
            .emitMatchesForTesting([_match('userA_userB', ['userA', 'userB'])]);
        expect(container.read(matchCelebrationProvider).hasCelebration, isTrue);

        notifier.clearCelebration();
        expect(container.read(matchCelebrationProvider).hasCelebration, isFalse);

        // Same match emitted again — already seen, no new celebration.
        notifier
            .emitMatchesForTesting([_match('userA_userB', ['userA', 'userB'])]);
        expect(container.read(matchCelebrationProvider).hasCelebration, isFalse);
      });

      test('no pending like means no celebration even for new matches', () {
        final container = _makeContainer();
        addTearDown(container.dispose);

        final notifier = container.read(matchCelebrationProvider.notifier);
        notifier.emitMatchesForTesting([]); // startup
        // No setPendingLike.
        notifier
            .emitMatchesForTesting([_match('userA_userB', ['userA', 'userB'])]);

        expect(container.read(matchCelebrationProvider).hasCelebration, isFalse);
      });
    });
  });
}
