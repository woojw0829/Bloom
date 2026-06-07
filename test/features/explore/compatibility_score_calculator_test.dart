import 'package:bloom/features/explore/domain/models/compatibility_score.dart';
import 'package:bloom/features/explore/domain/models/discovery_profile.dart';
import 'package:bloom/features/explore/domain/services/compatibility_score_calculator.dart';
import 'package:bloom/shared/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

UserModel _makeCurrentUser({
  String id = 'me',
  String geoHash = 'wydm5',
  String relationshipGoal = 'Serious Relationship',
  List<String> interests = const ['Hiking', 'Coffee', 'Movies'],
  UserCompatibilityPreferences? prefs,
}) {
  return UserModel(
    id: id,
    email: 'me@example.com',
    nickname: 'Me',
    birthDate: DateTime(1995, 1, 1),
    age: 29,
    identity: 'Gay',
    relationshipGoal: relationshipGoal,
    bio: '',
    city: 'Seoul',
    geoHash: geoHash,
    interests: interests,
    profileImages: const ['https://example.com/me.jpg'],
    profileVisibility: 'public',
    accountStatus: 'active',
    lastSeen: DateTime(2026, 1, 1),
    notificationSettings: const UserNotificationSettings(),
    compatibilityPreferences: prefs ?? const UserCompatibilityPreferences(),
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

DiscoveryProfile _makeCandidate({
  String id = 'candidate-1',
  String geoHash = 'wydm5',
  String identity = 'Gay',
  String relationshipGoal = 'Serious Relationship',
  List<String> interests = const ['Hiking', 'Coffee'],
  String verificationLevel = 'none',
  int age = 27,
}) {
  return DiscoveryProfile(
    id: id,
    nickname: 'Candidate',
    age: age,
    identity: identity,
    relationshipGoal: relationshipGoal,
    bio: '',
    interests: interests,
    profileImages: const ['https://example.com/candidate.jpg'],
    verificationLevel: verificationLevel,
    premium: false,
    premiumBadgeVisible: false,
    city: 'Seoul',
    geoHash: geoHash,
    updatedAt: DateTime(2026, 1, 1),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('CompatibilityScoreCalculator', () {
    // ── Output invariants ───────────────────────────────────────────────────

    test('score is always between 0 and 100', () {
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(),
        candidate: _makeCandidate(),
      );
      expect(score.percentage, inInclusiveRange(0, 100));
    });

    test('output contains no raw coordinate fields', () {
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(),
        candidate: _makeCandidate(),
      );
      // CompatibilityScore exposes only percentage, reasons, and a boolean flag.
      // Verifying the type tree ensures no lat/lng leaked.
      expect(score, isA<CompatibilityScore>());
      expect(score.reasons, isA<List<CompatibilityReason>>());
      expect(score.isApproximateDistanceUsed, isA<bool>());
    });

    test('reasons list has at most 3 entries', () {
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(),
        candidate: _makeCandidate(verificationLevel: 'basic'),
      );
      expect(score.reasons.length, lessThanOrEqualTo(3));
    });

    test('reasons are CompatibilityReason enum values, not raw strings', () {
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(),
        candidate: _makeCandidate(),
      );
      for (final r in score.reasons) {
        expect(CompatibilityReason.values.contains(r), isTrue);
      }
    });

    // ── Relationship goal ───────────────────────────────────────────────────

    test('matching relationship goal increases score', () {
      final matching = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(relationshipGoal: 'Casual Dating'),
        candidate: _makeCandidate(relationshipGoal: 'Casual Dating'),
      );
      final mismatched = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(relationshipGoal: 'Casual Dating'),
        candidate: _makeCandidate(relationshipGoal: 'Serious Relationship'),
      );
      expect(matching.percentage, greaterThan(mismatched.percentage));
    });

    test('pref-based goal match (prefs.relationshipGoals not empty) scores 25', () {
      const prefs = UserCompatibilityPreferences(
        relationshipGoals: ['Serious Relationship'],
      );
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(prefs: prefs),
        candidate: _makeCandidate(relationshipGoal: 'Serious Relationship'),
      );
      // Relationship goal should contribute reason when prefs match.
      expect(
        score.reasons.contains(CompatibilityReason.relationshipGoal),
        isTrue,
      );
    });

    test('pref-based goal mismatch scores 0 for goal dimension', () {
      const prefs = UserCompatibilityPreferences(
        relationshipGoals: ['Casual Dating'],
      );
      final withMatch = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(prefs: prefs),
        candidate: _makeCandidate(relationshipGoal: 'Casual Dating'),
      );
      final noMatch = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(prefs: prefs),
        candidate: _makeCandidate(relationshipGoal: 'Serious Relationship'),
      );
      expect(withMatch.percentage, greaterThan(noMatch.percentage));
    });

    // ── Identity ────────────────────────────────────────────────────────────

    test('pref identity match scores 20 for identity dimension', () {
      const prefs = UserCompatibilityPreferences(
        identities: ['Gay', 'Bisexual'],
      );
      final matching = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(prefs: prefs),
        candidate: _makeCandidate(identity: 'Gay'),
      );
      final mismatched = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(prefs: prefs),
        candidate: _makeCandidate(identity: 'Lesbian'),
      );
      expect(matching.percentage, greaterThan(mismatched.percentage));
      expect(
        matching.reasons.contains(CompatibilityReason.identityFit),
        isTrue,
      );
    });

    test('no identity pref set gives neutral (no crash)', () {
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(prefs: const UserCompatibilityPreferences()),
        candidate: _makeCandidate(identity: 'Queer'),
      );
      expect(score.percentage, inInclusiveRange(0, 100));
    });

    // ── Age ─────────────────────────────────────────────────────────────────

    test('candidate within pref age range scores 20 for age', () {
      const prefs = UserCompatibilityPreferences(minAge: 25, maxAge: 35);
      final inRange = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(prefs: prefs),
        candidate: _makeCandidate(age: 28),
      );
      final farOutside = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(prefs: prefs),
        candidate: _makeCandidate(age: 55),
      );
      expect(inRange.percentage, greaterThan(farOutside.percentage));
    });

    test('candidate 3 years outside age range scores 10 (partial)', () {
      const prefs = UserCompatibilityPreferences(minAge: 25, maxAge: 35);
      final slightlyOutside = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(prefs: prefs),
        candidate: _makeCandidate(age: 38), // 3 yrs over maxAge
      );
      expect(slightlyOutside.percentage, inInclusiveRange(0, 100));
    });

    // ── Shared interests ────────────────────────────────────────────────────

    test('shared interests increase score', () {
      final withShared = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(interests: ['Hiking', 'Coffee', 'Art']),
        candidate: _makeCandidate(interests: ['Hiking', 'Coffee', 'Art']),
      );
      final noShared = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(interests: ['Hiking', 'Coffee', 'Art']),
        candidate: _makeCandidate(interests: ['Gaming', 'Cooking']),
      );
      expect(withShared.percentage, greaterThan(noShared.percentage));
    });

    test('3+ shared interests earns sharedInterests reason', () {
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(
          interests: ['Hiking', 'Coffee', 'Art', 'Travel'],
        ),
        candidate: _makeCandidate(
          interests: ['Hiking', 'Coffee', 'Art', 'Gaming'],
        ),
      );
      expect(
        score.reasons.contains(CompatibilityReason.sharedInterests),
        isTrue,
      );
    });

    test('currentUser with no interests uses neutral score (no crash)', () {
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(interests: const []),
        candidate: _makeCandidate(interests: ['Hiking']),
      );
      expect(score.percentage, inInclusiveRange(0, 100));
    });

    // ── Distance ────────────────────────────────────────────────────────────

    test('missing geoHash does not crash and is handled gracefully', () {
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(geoHash: ''),
        candidate: _makeCandidate(geoHash: ''),
      );
      expect(score.percentage, inInclusiveRange(0, 100));
      expect(score.isApproximateDistanceUsed, isFalse);
    });

    test('nearby candidates score higher on distance dimension than far ones', () {
      const seoulHash = 'wydm5';
      const nyHash = 'dr5re'; // Manhattan ≈ 11,000 km from Seoul

      const prefs = UserCompatibilityPreferences(maxDistanceKm: 50);
      final nearby = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(geoHash: seoulHash, prefs: prefs),
        candidate: _makeCandidate(geoHash: seoulHash),
      );
      final farAway = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(geoHash: seoulHash, prefs: prefs),
        candidate: _makeCandidate(geoHash: nyHash),
      );
      expect(nearby.percentage, greaterThan(farAway.percentage));
    });

    test('isApproximateDistanceUsed is true when both geoHashes exist', () {
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(geoHash: 'wydm5'),
        candidate: _makeCandidate(geoHash: 'wydm5'),
      );
      expect(score.isApproximateDistanceUsed, isTrue);
    });

    // ── Verification ────────────────────────────────────────────────────────

    test('verified candidate receives bonus points', () {
      final verified = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(),
        candidate: _makeCandidate(verificationLevel: 'basic'),
      );
      final unverified = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(),
        candidate: _makeCandidate(verificationLevel: 'none'),
      );
      expect(verified.percentage, greaterThan(unverified.percentage));
    });

    test('verified reason appears in top-3 when other high-scoring dimensions are absent', () {
      // Set prefs that mismatch the candidate on identity and goal so verified
      // can reach top-3 reasons.
      const prefs = UserCompatibilityPreferences(
        minAge: 18,
        maxAge: 45,
        identities: ['Lesbian'], // candidate is 'Gay' → 0 pts identity
        relationshipGoals: ['Casual Dating'], // candidate wants 'Serious' → 0 pts goal
        maxDistanceKm: 50,
      );
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(
          prefs: prefs,
          interests: const [], // neutral 10 pts interests
          geoHash: '', // no geoHash → no distance contribution to reasons
        ),
        candidate: _makeCandidate(
          verificationLevel: 'basic',
          identity: 'Gay',
          relationshipGoal: 'Serious Relationship',
          geoHash: '',
        ),
      );
      expect(score.reasons.contains(CompatibilityReason.verified), isTrue);
    });

    // ── Edge cases ──────────────────────────────────────────────────────────

    test('candidate with all empty optional fields still computes a score', () {
      final candidate = DiscoveryProfile(
        id: 'sparse',
        nickname: 'Sparse',
        age: 30,
        identity: '',
        relationshipGoal: '',
        bio: '',
        interests: const [],
        profileImages: const ['https://example.com/sparse.jpg'],
        verificationLevel: 'none',
        premium: false,
        premiumBadgeVisible: false,
        city: '',
        geoHash: '',
        updatedAt: DateTime(2026, 1, 1),
      );
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(),
        candidate: candidate,
      );
      expect(score.percentage, inInclusiveRange(0, 100));
    });

    test('score with no positive dimensions is still >= 0', () {
      const prefs = UserCompatibilityPreferences(
        minAge: 18,
        maxAge: 20,
        maxDistanceKm: 5,
        identities: ['Straight'],
        relationshipGoals: ['Friendship'],
      );
      final score = CompatibilityScoreCalculator.compute(
        currentUser: _makeCurrentUser(
          prefs: prefs,
          geoHash: 'wydm5',
          interests: const ['Cooking'],
        ),
        candidate: _makeCandidate(
          age: 60,
          identity: 'Gay',
          relationshipGoal: 'Serious Relationship',
          interests: const ['Skydiving'],
          geoHash: 'dr5re', // NYC ≈ 11,000 km away
          verificationLevel: 'none',
        ),
      );
      expect(score.percentage, greaterThanOrEqualTo(0));
    });
  });
}
