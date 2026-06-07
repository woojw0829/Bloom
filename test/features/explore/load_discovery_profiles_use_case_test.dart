import 'package:bloom/features/explore/domain/models/discovery_filters.dart';
import 'package:bloom/features/explore/domain/repositories/discovery_repository.dart';
import 'package:bloom/features/explore/domain/usecases/load_discovery_profiles_use_case.dart';
import 'package:bloom/shared/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

UserModel _makeUser({
  String id = 'user-1',
  String geoHash = 'wxyz0',
  String profileVisibility = 'public',
  String accountStatus = 'active',
  List<String> profileImages = const ['https://example.com/photo.jpg'],
  int age = 29,
  String identity = 'Gay',
  String relationshipGoal = 'Serious Relationship',
  String verificationLevel = 'none',
}) {
  return UserModel(
    id: id,
    email: 'test@example.com',
    nickname: 'Test',
    birthDate: DateTime(1995, 1, 1),
    age: age,
    identity: identity,
    relationshipGoal: relationshipGoal,
    verificationLevel: verificationLevel,
    bio: '',
    city: 'Seoul',
    geoHash: geoHash,
    profileImages: profileImages,
    profileVisibility: profileVisibility,
    accountStatus: accountStatus,
    lastSeen: DateTime(2026, 1, 1),
    notificationSettings: const UserNotificationSettings(),
    compatibilityPreferences: const UserCompatibilityPreferences(),
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

// ── Fake repository ───────────────────────────────────────────────────────────

class _FakeDiscoveryRepository implements DiscoveryRepository {
  _FakeDiscoveryRepository({this.profiles = const [], this.throws = false});

  final List<UserModel> profiles;
  final bool throws;

  @override
  Future<DiscoveryPage> loadPage({
    required String currentUserId,
    QueryDocumentSnapshot<Map<String, dynamic>>? afterDocument,
    required int pageSize,
  }) async {
    if (throws) throw Exception('Firestore unavailable');
    final filtered =
        profiles.where((u) => u.id != currentUserId).take(pageSize).toList();
    // rawCount simulates the Firestore snapshot doc count (before current-user
    // exclusion but capped at the page limit).
    final rawCount = profiles.length < pageSize ? profiles.length : pageSize;
    return DiscoveryPage(
      profiles: filtered,
      lastDocument: null,
      rawCount: rawCount,
    );
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('LoadDiscoveryProfilesUseCase', () {
    // ── Baseline outcomes ───────────────────────────────────────────────────

    test('returns unauthenticated when currentUser is null', () async {
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(),
      );

      final result = await useCase.call(currentUser: null);

      expect(result, isA<LoadDiscoveryUnauthenticated>());
    });

    test('returns needsLocation when currentUser.geoHash is empty', () async {
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(),
      );
      final currentUser = _makeUser(geoHash: '');

      final result = await useCase.call(currentUser: currentUser);

      expect(result, isA<LoadDiscoveryNeedsLocation>());
    });

    test('returns success and excludes current user', () async {
      final currentUser = _makeUser(id: 'me', geoHash: 'wxyz0');
      final candidate = _makeUser(id: 'other', geoHash: 'wxyz0');
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(
          profiles: [currentUser, candidate],
        ),
      );

      final result = await useCase.call(currentUser: currentUser);

      expect(result, isA<LoadDiscoverySuccess>());
      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.any((p) => p.id == 'me'), isFalse);
      expect(success.profiles.any((p) => p.id == 'other'), isTrue);
    });

    test('excludes profiles with no profile images', () async {
      final currentUser = _makeUser(id: 'me');
      final withPhoto = _makeUser(id: 'has-photo');
      final withoutPhoto = _makeUser(id: 'no-photo', profileImages: const []);
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(
          profiles: [withPhoto, withoutPhoto],
        ),
      );

      final result = await useCase.call(currentUser: currentUser);

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.any((p) => p.id == 'has-photo'), isTrue);
      expect(success.profiles.any((p) => p.id == 'no-photo'), isFalse);
    });

    test('returns error when repository throws', () async {
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(throws: true),
      );
      final currentUser = _makeUser();

      final result = await useCase.call(currentUser: currentUser);

      expect(result, isA<LoadDiscoveryError>());
    });

    test('returns success with empty list when repository returns no profiles',
        () async {
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(profiles: []),
      );
      final currentUser = _makeUser();

      final result = await useCase.call(currentUser: currentUser);

      expect(result, isA<LoadDiscoverySuccess>());
      expect((result as LoadDiscoverySuccess).profiles, isEmpty);
    });

    test('hasMore is true when raw page is full', () async {
      const pageSize = 2;
      final currentUser = _makeUser(id: 'me');
      final candidates = [
        _makeUser(id: 'a'),
        _makeUser(id: 'b'),
      ];
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(profiles: candidates),
      );

      final result =
          await useCase.call(currentUser: currentUser, pageSize: pageSize);

      final success = result as LoadDiscoverySuccess;
      expect(success.hasMore, isTrue);
    });

    test('hasMore is false when page is under-full', () async {
      const pageSize = 20;
      final currentUser = _makeUser(id: 'me');
      final candidates = [_makeUser(id: 'only-one')];
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(profiles: candidates),
      );

      final result =
          await useCase.call(currentUser: currentUser, pageSize: pageSize);

      expect((result as LoadDiscoverySuccess).hasMore, isFalse);
    });

    // ── Age filter ──────────────────────────────────────────────────────────

    test('age filter excludes profiles outside min/max range', () async {
      final currentUser = _makeUser(id: 'me');
      final tooYoung = _makeUser(id: 'young', age: 17);
      final inRange = _makeUser(id: 'ok', age: 25);
      final tooOld = _makeUser(id: 'old', age: 55);
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(
          profiles: [tooYoung, inRange, tooOld],
        ),
      );

      final result = await useCase.call(
        currentUser: currentUser,
        filters: const DiscoveryFilters(minAge: 20, maxAge: 30),
      );

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.map((p) => p.id), equals(['ok']));
    });

    test('age filter with maxAge at maxAgeLimit does not exclude older profiles',
        () async {
      final currentUser = _makeUser(id: 'me');
      final older = _makeUser(id: 'older', age: 75);
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(profiles: [older]),
      );

      // maxAge = maxAgeLimit means "no upper age bound" (80+).
      final result = await useCase.call(
        currentUser: currentUser,
        filters: const DiscoveryFilters(
          minAge: DiscoveryFilters.minAgeLimit,
          maxAge: DiscoveryFilters.maxAgeLimit,
        ),
      );

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.any((p) => p.id == 'older'), isTrue);
    });

    // ── Identity filter ─────────────────────────────────────────────────────

    test('identity filter includes only selected identities', () async {
      final currentUser = _makeUser(id: 'me');
      final gay = _makeUser(id: 'gay', identity: 'Gay');
      final lesbian = _makeUser(id: 'lesbian', identity: 'Lesbian');
      final bisexual = _makeUser(id: 'bi', identity: 'Bisexual');
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(
          profiles: [gay, lesbian, bisexual],
        ),
      );

      final result = await useCase.call(
        currentUser: currentUser,
        filters: const DiscoveryFilters(identities: {'Gay', 'Lesbian'}),
      );

      final success = result as LoadDiscoverySuccess;
      final ids = success.profiles.map((p) => p.id).toList();
      expect(ids, containsAll(['gay', 'lesbian']));
      expect(ids, isNot(contains('bi')));
    });

    test('empty identity set shows all identities', () async {
      final currentUser = _makeUser(id: 'me');
      final profiles = [
        _makeUser(id: 'a', identity: 'Gay'),
        _makeUser(id: 'b', identity: 'Non-binary'),
        _makeUser(id: 'c', identity: 'Queer'),
      ];
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(profiles: profiles),
      );

      // Default filter: identities = {} (no filter).
      final result = await useCase.call(currentUser: currentUser);

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles, hasLength(3));
    });

    // ── Relationship goal filter ─────────────────────────────────────────────

    test('relationship goal filter includes only selected goals', () async {
      final currentUser = _makeUser(id: 'me');
      final serious = _makeUser(id: 's', relationshipGoal: 'Serious Relationship');
      final casual = _makeUser(id: 'c', relationshipGoal: 'Casual Dating');
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(profiles: [serious, casual]),
      );

      final result = await useCase.call(
        currentUser: currentUser,
        filters: const DiscoveryFilters(
          relationshipGoals: {'Serious Relationship'},
        ),
      );

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.map((p) => p.id), equals(['s']));
    });

    // ── Verified-only filter ─────────────────────────────────────────────────

    test('verifiedOnly filter excludes unverified profiles', () async {
      final currentUser = _makeUser(id: 'me');
      final unverified = _makeUser(id: 'unv', verificationLevel: 'none');
      final verified = _makeUser(id: 'ver', verificationLevel: 'basic');
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(profiles: [unverified, verified]),
      );

      final result = await useCase.call(
        currentUser: currentUser,
        filters: const DiscoveryFilters(verifiedOnly: true),
      );

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.any((p) => p.id == 'ver'), isTrue);
      expect(success.profiles.any((p) => p.id == 'unv'), isFalse);
    });

    // ── Distance filter ─────────────────────────────────────────────────────

    test('distance filter excludes profiles beyond maxDistanceKm', () async {
      // Seoul cell-center geoHash at precision 5: 'wydm5'
      // New York is ~11,000 km away — a different geoHash will decode far.
      const seoulGeoHash = 'wydm5';
      const nyGeoHash = 'dr5re'; // Manhattan geohash precision 5

      final currentUser = _makeUser(id: 'me', geoHash: seoulGeoHash);
      final nearUser = _makeUser(id: 'near', geoHash: seoulGeoHash);
      final farUser = _makeUser(id: 'far', geoHash: nyGeoHash);
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(
          profiles: [nearUser, farUser],
        ),
      );

      final result = await useCase.call(
        currentUser: currentUser,
        filters: const DiscoveryFilters(maxDistanceKm: 50),
      );

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.any((p) => p.id == 'near'), isTrue);
      expect(success.profiles.any((p) => p.id == 'far'), isFalse);
    });

    test('distance filter at maxDistanceKmLimit shows all profiles', () async {
      const seoulGeoHash = 'wydm5';
      const nyGeoHash = 'dr5re';

      final currentUser = _makeUser(id: 'me', geoHash: seoulGeoHash);
      final farUser = _makeUser(id: 'far', geoHash: nyGeoHash);
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(profiles: [farUser]),
      );

      // maxDistanceKmLimit = no distance filter.
      final result = await useCase.call(
        currentUser: currentUser,
        filters: const DiscoveryFilters(
          maxDistanceKm: DiscoveryFilters.maxDistanceKmLimit,
        ),
      );

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.any((p) => p.id == 'far'), isTrue);
    });

    test('distance filter includes profile when either geoHash is empty',
        () async {
      final currentUser = _makeUser(id: 'me', geoHash: 'wydm5');
      final noHash = _makeUser(id: 'nohash', geoHash: '');
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(profiles: [noHash]),
      );

      final result = await useCase.call(
        currentUser: currentUser,
        filters: const DiscoveryFilters(maxDistanceKm: 10),
      );

      // Cannot compute distance → include by default.
      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.any((p) => p.id == 'nohash'), isTrue);
    });
  });

  // ── Pass exclusion ──────────────────────────────────────────────────────────

  group('pass exclusion', () {
    test('passedUserIds excludes passed profiles from results', () async {
      final currentUser = _makeUser(id: 'me');
      final passed = _makeUser(id: 'already-passed');
      final notPassed = _makeUser(id: 'not-passed');
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(
          profiles: [passed, notPassed],
        ),
      );

      final result = await useCase.call(
        currentUser: currentUser,
        passedUserIds: const {'already-passed'},
      );

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.any((p) => p.id == 'not-passed'), isTrue);
      expect(success.profiles.any((p) => p.id == 'already-passed'), isFalse);
    });

    test('empty passedUserIds does not exclude any profiles', () async {
      final currentUser = _makeUser(id: 'me');
      final a = _makeUser(id: 'a');
      final b = _makeUser(id: 'b');
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(profiles: [a, b]),
      );

      final result = await useCase.call(
        currentUser: currentUser,
        passedUserIds: const {},
      );

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles, hasLength(2));
    });
  });

  // ── Like exclusion ──────────────────────────────────────────────────────────

  group('like exclusion', () {
    test('likedUserIds excludes liked profiles from results', () async {
      final currentUser = _makeUser(id: 'me');
      final liked = _makeUser(id: 'already-liked');
      final notLiked = _makeUser(id: 'not-liked');
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(
          profiles: [liked, notLiked],
        ),
      );

      final result = await useCase.call(
        currentUser: currentUser,
        likedUserIds: const {'already-liked'},
      );

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.any((p) => p.id == 'not-liked'), isTrue);
      expect(success.profiles.any((p) => p.id == 'already-liked'), isFalse);
    });

    test('empty likedUserIds does not exclude any profiles', () async {
      final currentUser = _makeUser(id: 'me');
      final a = _makeUser(id: 'a');
      final b = _makeUser(id: 'b');
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(profiles: [a, b]),
      );

      final result = await useCase.call(
        currentUser: currentUser,
        likedUserIds: const {},
      );

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles, hasLength(2));
    });

    test('passedUserIds and likedUserIds both exclude independently', () async {
      final currentUser = _makeUser(id: 'me');
      final passed = _makeUser(id: 'passed-user');
      final liked = _makeUser(id: 'liked-user');
      final visible = _makeUser(id: 'visible-user');
      final useCase = LoadDiscoveryProfilesUseCase(
        repository: _FakeDiscoveryRepository(
          profiles: [passed, liked, visible],
        ),
      );

      final result = await useCase.call(
        currentUser: currentUser,
        passedUserIds: const {'passed-user'},
        likedUserIds: const {'liked-user'},
      );

      final success = result as LoadDiscoverySuccess;
      expect(success.profiles.map((p) => p.id), equals(['visible-user']));
    });
  });

  // ── DiscoveryFilters model ──────────────────────────────────────────────────

  group('DiscoveryFilters', () {
    test('default instance isDefault returns true', () {
      const f = DiscoveryFilters();
      expect(f.isDefault, isTrue);
    });

    test('activeCount is 0 for default filters', () {
      const f = DiscoveryFilters();
      expect(f.activeCount, 0);
    });

    test('non-default age increments activeCount by 1', () {
      const f = DiscoveryFilters(minAge: 25);
      expect(f.activeCount, 1);
      expect(f.isDefault, isFalse);
    });

    test('identity selection increments activeCount by 1', () {
      const f = DiscoveryFilters(identities: {'Gay'});
      expect(f.activeCount, 1);
    });

    test('multiple different dimensions add to activeCount independently', () {
      const f = DiscoveryFilters(
        minAge: 25,
        identities: {'Gay'},
        verifiedOnly: true,
        maxDistanceKm: 30,
      );
      // age + identity + verifiedOnly + distance = 4
      expect(f.activeCount, 4);
    });

    test('copyWith preserves unmodified fields', () {
      const f = DiscoveryFilters(minAge: 25, identities: {'Gay'});
      final updated = f.copyWith(verifiedOnly: true);
      expect(updated.minAge, 25);
      expect(updated.identities, {'Gay'});
      expect(updated.verifiedOnly, isTrue);
    });
  });
}
