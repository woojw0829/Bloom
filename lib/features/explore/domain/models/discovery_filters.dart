import '../../../../core/constants/app_constants.dart';

/// Immutable set of discovery filter criteria.
///
/// [identities] and [relationshipGoals]: empty set = no filter (show all).
/// [verifiedOnly]: false = no filter.
/// [maxDistanceKm]: [maxDistanceKmLimit] = no distance filter.
/// [maxAge]: [maxAgeLimit] = no upper age bound ("80+").
class DiscoveryFilters {
  const DiscoveryFilters({
    this.minAge = minAgeLimit,
    this.maxAge = maxAgeLimit,
    this.identities = const {},
    this.relationshipGoals = const {},
    this.verifiedOnly = false,
    this.maxDistanceKm = maxDistanceKmLimit,
  });

  /// Absolute slider boundaries — shared with the filter sheet UI.
  static const int minAgeLimit = 18;

  /// Upper slider boundary. When [maxAge] equals this, no upper age bound is
  /// applied ("80+" label). This avoids displaying 100 on a narrow slider.
  static const int maxAgeLimit = 80;

  static const int maxDistanceKmLimit = AppConstants.maxDistanceKm;

  final int minAge;
  final int maxAge;

  /// Identities to include. Empty = show all identities.
  final Set<String> identities;

  /// Relationship goals to include. Empty = show all goals.
  final Set<String> relationshipGoals;

  final bool verifiedOnly;

  /// Maximum approximate distance in km.
  /// [maxDistanceKmLimit] means no distance limit.
  final int maxDistanceKm;

  /// True when every field is at its default value (no active filters).
  bool get isDefault =>
      minAge == minAgeLimit &&
      maxAge == maxAgeLimit &&
      identities.isEmpty &&
      relationshipGoals.isEmpty &&
      !verifiedOnly &&
      maxDistanceKm >= maxDistanceKmLimit;

  /// Number of active (non-default) filter dimensions.
  int get activeCount {
    var n = 0;
    if (minAge != minAgeLimit || maxAge != maxAgeLimit) n++;
    if (identities.isNotEmpty) n++;
    if (relationshipGoals.isNotEmpty) n++;
    if (verifiedOnly) n++;
    if (maxDistanceKm < maxDistanceKmLimit) n++;
    return n;
  }

  DiscoveryFilters copyWith({
    int? minAge,
    int? maxAge,
    Set<String>? identities,
    Set<String>? relationshipGoals,
    bool? verifiedOnly,
    int? maxDistanceKm,
  }) =>
      DiscoveryFilters(
        minAge: minAge ?? this.minAge,
        maxAge: maxAge ?? this.maxAge,
        identities: identities ?? this.identities,
        relationshipGoals: relationshipGoals ?? this.relationshipGoals,
        verifiedOnly: verifiedOnly ?? this.verifiedOnly,
        maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      );
}
