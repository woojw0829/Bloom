import 'package:bloom/core/utils/geohash_utils.dart';
import 'package:bloom/features/explore/domain/models/discovery_profile.dart';
import 'package:bloom/features/explore/domain/models/map_discovery_profile.dart';
import 'package:bloom/features/explore/domain/models/nearby_user_count.dart';
import 'package:bloom/features/explore/domain/repositories/discovery_repository.dart';
import 'package:bloom/features/explore/presentation/providers/discovery_feed_provider.dart';
import 'package:bloom/features/explore/presentation/providers/map_discovery_provider.dart';
import 'package:bloom/features/profile/presentation/providers/profile_providers.dart';
import 'package:bloom/shared/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

UserModel _makeUser({
  String id = 'me',
  String geoHash = 'wydm5',
}) {
  return UserModel(
    id: id,
    email: '$id@example.com',
    nickname: 'Me',
    birthDate: DateTime(1995, 1, 1),
    age: 29,
    identity: 'Gay',
    relationshipGoal: 'Serious Relationship',
    bio: '',
    city: 'Seoul',
    geoHash: geoHash,
    interests: const ['Hiking'],
    profileImages: const ['https://example.com/me.jpg'],
    profileVisibility: 'public',
    accountStatus: 'active',
    lastSeen: DateTime(2026, 1, 1),
    notificationSettings: const UserNotificationSettings(),
    compatibilityPreferences: const UserCompatibilityPreferences(),
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

UserModel _makeCandidate({
  required String id,
  String geoHash = 'wydm5',
  List<String> profileImages = const ['https://example.com/photo.jpg'],
}) {
  return UserModel(
    id: id,
    email: '$id@example.com',
    nickname: 'User $id',
    birthDate: DateTime(1997, 1, 1),
    age: 27,
    identity: 'Gay',
    relationshipGoal: 'Serious Relationship',
    bio: '',
    city: 'Seoul',
    geoHash: geoHash,
    interests: const ['Hiking'],
    profileImages: profileImages,
    profileVisibility: 'public',
    accountStatus: 'active',
    lastSeen: DateTime(2026, 1, 1),
    notificationSettings: const UserNotificationSettings(),
    compatibilityPreferences: const UserCompatibilityPreferences(),
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

// Kept for model-level tests below — the type still exists and is used for
// currentUserPoint in MapDiscoveryState.
DiscoveryProfile _makeProfile({
  String id = 'p1',
  String geoHash = 'wydm5',
}) {
  return DiscoveryProfile(
    id: id,
    nickname: 'Profile',
    age: 27,
    identity: 'Gay',
    relationshipGoal: 'Serious Relationship',
    bio: '',
    interests: const ['Hiking'],
    profileImages: const ['https://example.com/photo.jpg'],
    verificationLevel: 'none',
    premium: false,
    premiumBadgeVisible: false,
    city: 'Seoul',
    geoHash: geoHash,
    updatedAt: DateTime(2026, 1, 1),
  );
}

class _MockDiscoveryRepository implements DiscoveryRepository {
  const _MockDiscoveryRepository({required this.profiles});

  final List<UserModel> profiles;

  @override
  Future<DiscoveryPage> loadPage({
    required String currentUserId,
    QueryDocumentSnapshot<Map<String, dynamic>>? afterDocument,
    required int pageSize,
  }) async {
    final filtered = profiles
        .where((p) => p.id != currentUserId)
        .take(pageSize)
        .toList();
    return DiscoveryPage(profiles: filtered, rawCount: profiles.length);
  }
}

/// Waits for the provider to leave the loading state.
Future<void> _waitForLoad(ProviderContainer container) async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
    if (!container.read(mapDiscoveryProvider).isLoading) return;
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── MapApproximatePoint model ─────────────────────────────────────────────

  group('MapApproximatePoint', () {
    test('stores lat and lng', () {
      const point = MapApproximatePoint(lat: 37.5665, lng: 126.9780);
      expect(point.lat, 37.5665);
      expect(point.lng, 126.9780);
    });

    test('is a typed value object — does not convert to coordinate string', () {
      const point = MapApproximatePoint(lat: 37.5665, lng: 126.9780);
      expect(point, isA<MapApproximatePoint>());
      expect(point.lat, isA<double>());
      expect(point.lng, isA<double>());
    });
  });

  // ── MapDiscoveryProfile model ─────────────────────────────────────────────

  group('MapDiscoveryProfile', () {
    test('wraps profile and approximatePoint with optional score', () {
      final profile = _makeProfile();
      const point = MapApproximatePoint(lat: 37.5, lng: 127.0);
      final mp = MapDiscoveryProfile(profile: profile, approximatePoint: point);

      expect(mp.profile, profile);
      expect(mp.approximatePoint, point);
      expect(mp.score, isNull);
    });

    test('exposes only DiscoveryProfile (no private fields)', () {
      final profile = _makeProfile();
      const point = MapApproximatePoint(lat: 37.5, lng: 127.0);
      final mp = MapDiscoveryProfile(profile: profile, approximatePoint: point);

      // Type hierarchy guarantees: no email, fcmToken, private location exposed
      expect(mp.profile, isA<DiscoveryProfile>());
      expect(mp.approximatePoint, isA<MapApproximatePoint>());
    });

    test('Seoul geoHash decodes to a plausible cell centre', () {
      const seoulHash = 'wydm5';
      final (lat, lng) = GeoHashUtils.decodeCellCenter(seoulHash);
      // Cell centre should be within a broad Seoul bounding box
      expect(lat, inInclusiveRange(37.0, 38.5));
      expect(lng, inInclusiveRange(126.0, 128.0));
    });

    test('empty geoHash decodes to sentinel (0, 0)', () {
      final (lat, lng) = GeoHashUtils.decodeCellCenter('');
      expect(lat, 0.0);
      expect(lng, 0.0);
    });
  });

  // ── MapDiscoveryState model ───────────────────────────────────────────────

  group('MapDiscoveryState', () {
    test('isEmpty when no nearbyCount, not loading, no error, no needsLocation',
        () {
      const state = MapDiscoveryState();
      expect(state.isEmpty, isTrue);
    });

    test('not isEmpty when isLoading', () {
      const state = MapDiscoveryState(isLoading: true);
      expect(state.isEmpty, isFalse);
    });

    test('not isEmpty when needsLocation', () {
      const state = MapDiscoveryState(needsLocation: true);
      expect(state.isEmpty, isFalse);
    });

    test('not isEmpty when hasError', () {
      const state = MapDiscoveryState(hasError: true);
      expect(state.isEmpty, isFalse);
    });

    test('not isEmpty when nearbyCount is set', () {
      const count = NearbyUserCount(
        rawCount: 3,
        radiusKm: 5,
        bucket: NearbyCountBucket.fewerThanFive,
      );
      const state = MapDiscoveryState(nearbyCount: count);
      expect(state.isEmpty, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      const original = MapDiscoveryState(isLoading: true);
      final updated = original.copyWith(isLoading: false, hasError: true);
      expect(updated.isLoading, isFalse);
      expect(updated.hasError, isTrue);
      expect(updated.needsLocation, isFalse);
      expect(updated.nearbyCount, isNull);
    });
  });

  // ── MapDiscoveryNotifier ──────────────────────────────────────────────────

  group('MapDiscoveryNotifier', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    test('returns needsLocation when currentUser.geoHash is empty', () async {
      final user = _makeUser(geoHash: '');
      container = ProviderContainer(overrides: [
        currentUserProvider.overrideWith((_) => Stream.value(user)),
        discoveryRepositoryProvider.overrideWithValue(
          const _MockDiscoveryRepository(profiles: []),
        ),
      ]);

      await _waitForLoad(container);

      expect(container.read(mapDiscoveryProvider).needsLocation, isTrue);
    });

    test('returns safe empty state when currentUser is null (unauthenticated)',
        () async {
      container = ProviderContainer(overrides: [
        currentUserProvider.overrideWith((_) => Stream.value(null)),
        discoveryRepositoryProvider.overrideWithValue(
          const _MockDiscoveryRepository(profiles: []),
        ),
      ]);

      await _waitForLoad(container);

      final state = container.read(mapDiscoveryProvider);
      expect(state.isLoading, isFalse);
      expect(state.needsLocation, isFalse);
      expect(state.hasError, isFalse);
      expect(state.nearbyCount, isNull);
    });

    test('returns nearbyCount on success with candidates', () async {
      final currentUser = _makeUser(geoHash: 'wydm5');
      final candidate = _makeCandidate(id: 'p1', geoHash: 'wydm5');

      container = ProviderContainer(overrides: [
        currentUserProvider.overrideWith((_) => Stream.value(currentUser)),
        discoveryRepositoryProvider.overrideWithValue(
          _MockDiscoveryRepository(profiles: [candidate]),
        ),
      ]);

      await _waitForLoad(container);

      final state = container.read(mapDiscoveryProvider);
      expect(state.nearbyCount, isNotNull);
      expect(state.nearbyCount!.radiusKm, 5);
      expect(state.nearbyCount!.rawCount, greaterThanOrEqualTo(0));
    });

    test('nearbyCount is zero when no candidates share the geoHash area',
        () async {
      final currentUser = _makeUser(geoHash: 'wydm5');
      // Candidate in a very distant location (Europe vs Seoul).
      final distant = _makeCandidate(id: 'p1', geoHash: 'u09t');

      container = ProviderContainer(overrides: [
        currentUserProvider.overrideWith((_) => Stream.value(currentUser)),
        discoveryRepositoryProvider.overrideWithValue(
          _MockDiscoveryRepository(profiles: [distant]),
        ),
      ]);

      await _waitForLoad(container);

      final state = container.read(mapDiscoveryProvider);
      expect(state.nearbyCount, isNotNull);
      expect(state.nearbyCount!.rawCount, 0);
      expect(state.nearbyCount!.bucket, NearbyCountBucket.none);
    });

    test('excludes candidates without profileImages from count', () async {
      final currentUser = _makeUser(geoHash: 'wydm5');
      final noPhoto = _makeCandidate(
        id: 'p1',
        geoHash: 'wydm5',
        profileImages: const [],
      );

      container = ProviderContainer(overrides: [
        currentUserProvider.overrideWith((_) => Stream.value(currentUser)),
        discoveryRepositoryProvider.overrideWithValue(
          _MockDiscoveryRepository(profiles: [noPhoto]),
        ),
      ]);

      await _waitForLoad(container);

      expect(
          container.read(mapDiscoveryProvider).nearbyCount!.rawCount, 0);
    });

    test('excludes candidates without geoHash from count', () async {
      final currentUser = _makeUser(geoHash: 'wydm5');
      final noHash = _makeCandidate(id: 'p1', geoHash: '');

      container = ProviderContainer(overrides: [
        currentUserProvider.overrideWith((_) => Stream.value(currentUser)),
        discoveryRepositoryProvider.overrideWithValue(
          _MockDiscoveryRepository(profiles: [noHash]),
        ),
      ]);

      await _waitForLoad(container);

      expect(
          container.read(mapDiscoveryProvider).nearbyCount!.rawCount, 0);
    });

    test('currentUserPoint is set from currentUser.geoHash', () async {
      const seoulHash = 'wydm5';
      final currentUser = _makeUser(geoHash: seoulHash);

      container = ProviderContainer(overrides: [
        currentUserProvider.overrideWith((_) => Stream.value(currentUser)),
        discoveryRepositoryProvider.overrideWithValue(
          const _MockDiscoveryRepository(profiles: []),
        ),
      ]);

      await _waitForLoad(container);

      final state = container.read(mapDiscoveryProvider);
      expect(state.currentUserPoint, isNotNull);
      final (lat, lng) = GeoHashUtils.decodeCellCenter(seoulHash);
      expect(state.currentUserPoint!.lat, closeTo(lat, 0.001));
      expect(state.currentUserPoint!.lng, closeTo(lng, 0.001));
    });

    test('no profile list or user IDs are exposed in state', () async {
      final currentUser = _makeUser(geoHash: 'wydm5');
      final candidate = _makeCandidate(id: 'secret_user_id', geoHash: 'wydm5');

      container = ProviderContainer(overrides: [
        currentUserProvider.overrideWith((_) => Stream.value(currentUser)),
        discoveryRepositoryProvider.overrideWithValue(
          _MockDiscoveryRepository(profiles: [candidate]),
        ),
      ]);

      await _waitForLoad(container);

      final state = container.read(mapDiscoveryProvider);
      // State must NOT expose a profile list or user IDs.
      expect(state.nearbyCount, isNotNull);
      // nearbyCount has no userIds field — only rawCount, radiusKm, bucket.
      expect(state.nearbyCount!.rawCount, isA<int>());
      expect(state.nearbyCount!.bucket, isA<NearbyCountBucket>());
    });

    test('does not crash when candidate has invalid geoHash characters',
        () async {
      final currentUser = _makeUser(geoHash: 'wydm5');
      final badHash = _makeCandidate(id: 'p1', geoHash: '!!!!!');

      container = ProviderContainer(overrides: [
        currentUserProvider.overrideWith((_) => Stream.value(currentUser)),
        discoveryRepositoryProvider.overrideWithValue(
          _MockDiscoveryRepository(profiles: [badHash]),
        ),
      ]);

      await _waitForLoad(container);

      final state = container.read(mapDiscoveryProvider);
      expect(state.hasError, isFalse);
      expect(state.nearbyCount, isNotNull);
      // Invalid geoHash is skipped — excluded from count
      expect(state.nearbyCount!.rawCount, 0);
    });

    test('refresh() reloads state without crashing', () async {
      final currentUser = _makeUser(geoHash: 'wydm5');

      container = ProviderContainer(overrides: [
        currentUserProvider.overrideWith((_) => Stream.value(currentUser)),
        discoveryRepositoryProvider.overrideWithValue(
          const _MockDiscoveryRepository(profiles: []),
        ),
      ]);

      await _waitForLoad(container);
      expect(container.read(mapDiscoveryProvider).isLoading, isFalse);

      await container.read(mapDiscoveryProvider.notifier).refresh();
      await _waitForLoad(container);

      expect(container.read(mapDiscoveryProvider).isLoading, isFalse);
    });
  });
}
