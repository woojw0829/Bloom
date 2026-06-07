import '../../../../core/utils/distance_utils.dart';
import '../../../../core/utils/geohash_utils.dart';
import '../../../../shared/models/user_model.dart';
import '../models/compatibility_score.dart';
import '../models/discovery_profile.dart';

/// Computes an MVP "profile fit" score from the current user's perspective.
///
/// ## Scoring formula (100 pts total)
/// | Dimension              | Max pts | Notes                                    |
/// |------------------------|---------|------------------------------------------|
/// | Relationship goal      | 25      | Prefs-based; soft fallback on own goal   |
/// | Identity fit           | 20      | Prefs-based; neutral when no pref set    |
/// | Age preference         | 20      | Within prefs range = full; ±5 yr = half  |
/// | Shared interests       | 20      | Scaled: 3+ shared = full 20              |
/// | Approximate distance   | 10      | geoHash cell-centre, ≈ ±2.5 km accuracy |
/// | Verification bonus     |  5      | candidate.verificationLevel != 'none'    |
///
/// ## Privacy guarantees
/// - Only current user's own fields and public [DiscoveryProfile] are used.
/// - Distance uses [GeoHashUtils.decodeCellCenter] (cell centre, not exact
///   coordinates). Internal lat/lng values are never stored, returned, or logged.
/// - Candidate's private subcollections are never accessed.
/// - No Firestore reads or writes are performed.
abstract final class CompatibilityScoreCalculator {
  /// Returns a [CompatibilityScore] for [candidate] from [currentUser]'s POV.
  ///
  /// Never crashes on missing or empty fields — omitted data yields a neutral
  /// contribution rather than 0.
  static CompatibilityScore compute({
    required UserModel currentUser,
    required DiscoveryProfile candidate,
  }) {
    final prefs = currentUser.compatibilityPreferences;
    var total = 0;

    // Track (points, reason) so we can return the top 3 reasons.
    final scored = <(int, CompatibilityReason)>[];

    // 1. Relationship goal (25 pts) ─────────────────────────────────────────
    final goalPts = _scoreGoal(currentUser, candidate, prefs);
    total += goalPts;
    if (goalPts >= 20) scored.add((goalPts, CompatibilityReason.relationshipGoal));

    // 2. Identity fit (20 pts) ──────────────────────────────────────────────
    final identityPts = _scoreIdentity(candidate, prefs);
    total += identityPts;
    if (identityPts >= 15) scored.add((identityPts, CompatibilityReason.identityFit));

    // 3. Age preference (20 pts) ────────────────────────────────────────────
    final agePts = _scoreAge(candidate, prefs);
    total += agePts;
    if (agePts >= 15) scored.add((agePts, CompatibilityReason.ageRange));

    // 4. Shared interests (20 pts) ──────────────────────────────────────────
    final interestPts = _scoreInterests(currentUser, candidate);
    total += interestPts;
    if (interestPts >= 10) scored.add((interestPts, CompatibilityReason.sharedInterests));

    // 5. Approximate distance (10 pts) — cell centres only, never exact coords
    final (distPts, usedDist) = _scoreDistance(currentUser, candidate, prefs);
    total += distPts;
    if (distPts >= 8) scored.add((distPts, CompatibilityReason.nearbyArea));

    // 6. Verification bonus (5 pts) ─────────────────────────────────────────
    final verPts = _scoreVerification(candidate);
    total += verPts;
    if (verPts > 0) scored.add((verPts, CompatibilityReason.verified));

    // Return top 3 reasons by contribution (descending).
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    final reasons = scored.take(3).map((r) => r.$2).toList();

    return CompatibilityScore(
      percentage: total.clamp(0, 100),
      reasons: reasons,
      isApproximateDistanceUsed: usedDist,
    );
  }

  // ── Dimension scorers ─────────────────────────────────────────────────────

  static int _scoreGoal(
    UserModel currentUser,
    DiscoveryProfile candidate,
    UserCompatibilityPreferences prefs,
  ) {
    if (candidate.relationshipGoal.isEmpty) return 12; // no data → neutral

    if (prefs.relationshipGoals.isNotEmpty) {
      return prefs.relationshipGoals.contains(candidate.relationshipGoal) ? 25 : 0;
    }

    // No explicit pref: soft-match on currentUser's own goal.
    if (currentUser.relationshipGoal.isEmpty) return 12;
    return currentUser.relationshipGoal == candidate.relationshipGoal ? 25 : 8;
  }

  static int _scoreIdentity(
    DiscoveryProfile candidate,
    UserCompatibilityPreferences prefs,
  ) {
    if (candidate.identity.isEmpty) return 10; // no data → neutral

    if (prefs.identities.isNotEmpty) {
      return prefs.identities.contains(candidate.identity) ? 20 : 0;
    }

    // No explicit identity pref → neutral.
    return 10;
  }

  static int _scoreAge(
    DiscoveryProfile candidate,
    UserCompatibilityPreferences prefs,
  ) {
    final age = candidate.age;
    if (age >= prefs.minAge && age <= prefs.maxAge) return 20;

    final outside = age < prefs.minAge ? prefs.minAge - age : age - prefs.maxAge;
    return outside <= 5 ? 10 : 0;
  }

  static int _scoreInterests(
    UserModel currentUser,
    DiscoveryProfile candidate,
  ) {
    if (currentUser.interests.isEmpty) return 10; // no data → neutral
    if (candidate.interests.isEmpty) return 0;

    final mySet = currentUser.interests.toSet();
    final sharedCount = candidate.interests.where(mySet.contains).length;
    if (sharedCount == 0) return 0;
    // 1 shared → ~7, 2 → ~13, 3+ → 20 (capped).
    return ((sharedCount / 3.0) * 20).round().clamp(0, 20);
  }

  /// Uses geoHash cell centres for approximate distance.
  ///
  /// The decoded lat/lng pair is used only within this method and is never
  /// stored, returned, or logged. Returns `(score, usedDistance)`.
  static (int, bool) _scoreDistance(
    UserModel currentUser,
    DiscoveryProfile candidate,
    UserCompatibilityPreferences prefs,
  ) {
    if (currentUser.geoHash.isEmpty || candidate.geoHash.isEmpty) {
      return (5, false); // neutral — no location data
    }
    try {
      final (lat1, lng1) = GeoHashUtils.decodeCellCenter(currentUser.geoHash);
      final (lat2, lng2) = GeoHashUtils.decodeCellCenter(candidate.geoHash);
      final approxKm = DistanceUtils.haversineKm(lat1, lng1, lat2, lng2);

      final maxKm =
          prefs.maxDistanceKm > 0 ? prefs.maxDistanceKm.toDouble() : 50.0;
      if (approxKm <= maxKm) return (10, true);
      if (approxKm <= maxKm * 2) return (5, true);
      return (0, true);
    } catch (_) {
      return (5, false); // decode error → neutral
    }
  }

  static int _scoreVerification(DiscoveryProfile candidate) {
    return candidate.verificationLevel != 'none' ? 5 : 0;
  }
}
