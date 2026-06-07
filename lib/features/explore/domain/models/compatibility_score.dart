/// Reasons that positively contributed to a compatibility score.
///
/// Each value maps 1-to-1 to a localization key so that UI layers can display
/// a human-readable explanation without embedding raw preference data.
enum CompatibilityReason {
  sharedInterests,
  relationshipGoal,
  identityFit,
  ageRange,
  nearbyArea,
  verified,
}

/// Result of a single compatibility calculation for one candidate profile.
///
/// The [percentage] is an MVP "profile fit" score (0–100) computed from the
/// current user's own public preferences and the candidate's public
/// [DiscoveryProfile] fields only. It is:
/// - Deterministic (same inputs → same output).
/// - Client-side only (never stored in Firestore).
/// - Approximate: distance contribution uses geoHash cell centres, not exact
///   coordinates. No private subcollection data is read or exposed.
class CompatibilityScore {
  const CompatibilityScore({
    required this.percentage,
    this.reasons = const [],
    this.isApproximateDistanceUsed = false,
  });

  /// Overall fit percentage clamped to [0, 100].
  final int percentage;

  /// Top contributing reasons (at most 3), ordered by contribution size.
  /// Values are [CompatibilityReason] enum cases — no raw preference data.
  final List<CompatibilityReason> reasons;

  /// True when geoHash cell-centre distance contributed to the score.
  /// The cell-centre lat/lng values are internal to the calculator and are
  /// never surfaced through this model.
  final bool isApproximateDistanceUsed;
}
