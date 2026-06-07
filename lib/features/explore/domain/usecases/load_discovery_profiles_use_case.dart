import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../../../core/utils/geohash_utils.dart';
import '../../../../shared/models/user_model.dart';
import '../models/discovery_filters.dart';
import '../models/discovery_profile.dart';
import '../repositories/discovery_repository.dart';

// ── Outcome sealed hierarchy ──────────────────────────────────────────────────

sealed class LoadDiscoveryOutcome {
  const LoadDiscoveryOutcome();
}

/// The current user is not authenticated.
final class LoadDiscoveryUnauthenticated extends LoadDiscoveryOutcome {
  const LoadDiscoveryUnauthenticated();
}

/// The current user has no geoHash — they must update location first.
final class LoadDiscoveryNeedsLocation extends LoadDiscoveryOutcome {
  const LoadDiscoveryNeedsLocation();
}

/// Profiles loaded successfully.
final class LoadDiscoverySuccess extends LoadDiscoveryOutcome {
  const LoadDiscoverySuccess({
    required this.profiles,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<DiscoveryProfile> profiles;

  /// Firestore cursor for the next page. Null on the last page.
  final QueryDocumentSnapshot<Map<String, dynamic>>? lastDocument;

  /// True when the raw Firestore page was full — more pages likely exist.
  final bool hasMore;
}

/// An unexpected error occurred while loading profiles.
final class LoadDiscoveryError extends LoadDiscoveryOutcome {
  const LoadDiscoveryError();
}

// ── Use case ──────────────────────────────────────────────────────────────────

class LoadDiscoveryProfilesUseCase {
  const LoadDiscoveryProfilesUseCase({required this.repository});

  final DiscoveryRepository repository;

  /// Loads a page of discovery candidates, applying [filters] client-side.
  ///
  /// When [filters] are non-default a 3× fetch buffer is used so that
  /// client-side filtering still yields a reasonable number of visible
  /// profiles per page. [hasMore] is computed from the raw Firestore doc
  /// count, not the filtered count, so pagination terminates correctly.
  ///
  /// [passedUserIds], [likedUserIds], and [blockedUserIds] are sets of user
  /// IDs to exclude from results. Profiles already passed, liked, or blocked
  /// by the current user are filtered out so they do not reappear across
  /// Explore, Browse, and Map Discovery.
  ///
  /// Privacy guarantees:
  /// - Distance filtering uses geoHash cell centres (≈ 2.5 km accuracy),
  ///   never exact user coordinates from private subcollections.
  /// - Cell-centre lat/lng values are only used internally and are never
  ///   returned, displayed, or logged.
  Future<LoadDiscoveryOutcome> call({
    required UserModel? currentUser,
    QueryDocumentSnapshot<Map<String, dynamic>>? afterDocument,
    int pageSize = AppConstants.exploreFeedPageSize,
    DiscoveryFilters filters = const DiscoveryFilters(),
    Set<String> passedUserIds = const {},
    Set<String> likedUserIds = const {},
    Set<String> blockedUserIds = const {},
  }) async {
    if (currentUser == null) return const LoadDiscoveryUnauthenticated();
    if (currentUser.geoHash.isEmpty) return const LoadDiscoveryNeedsLocation();

    // When filters are active, fetch a larger buffer from Firestore so that
    // client-side filtering still yields enough visible profiles per page.
    final fetchPageSize = filters.isDefault ? pageSize : pageSize * 3;

    try {
      final page = await repository.loadPage(
        currentUserId: currentUser.id,
        afterDocument: afterDocument,
        pageSize: fetchPageSize,
      );

      final profiles = page.profiles
          // Require at least one photo for a meaningful card.
          .where((u) => u.profileImages.isNotEmpty)
          // Defensive: exclude current user even if repo missed it.
          .where((u) => u.id != currentUser.id)
          // Exclude profiles the current user has already passed on.
          .where((u) => !passedUserIds.contains(u.id))
          // Exclude profiles the current user has already liked or super-liked.
          .where((u) => !likedUserIds.contains(u.id))
          // Exclude profiles blocked by the current user.
          .where((u) => !blockedUserIds.contains(u.id))
          // Client-side discovery filters.
          .where((u) => _passesFilters(u, filters, currentUser))
          // Trim to the requested display page size.
          .take(pageSize)
          .map(DiscoveryProfile.fromUserModel)
          .toList();

      return LoadDiscoverySuccess(
        profiles: profiles,
        lastDocument: page.lastDocument,
        // hasMore is based on raw Firestore doc count vs. fetch page size,
        // not the filtered result count, to avoid premature pagination end.
        hasMore: page.rawCount >= fetchPageSize,
      );
    } catch (_) {
      return const LoadDiscoveryError();
    }
  }

  // ── Client-side filter logic ────────────────────────────────────────────────

  bool _passesFilters(
    UserModel user,
    DiscoveryFilters f,
    UserModel currentUser,
  ) {
    // Age: lower bound always applies; upper bound is inactive at maxAgeLimit.
    if (user.age < f.minAge) return false;
    if (f.maxAge < DiscoveryFilters.maxAgeLimit && user.age > f.maxAge) {
      return false;
    }

    // Identity: empty set = no filter.
    if (f.identities.isNotEmpty && !f.identities.contains(user.identity)) {
      return false;
    }

    // Relationship goal: empty set = no filter.
    if (f.relationshipGoals.isNotEmpty &&
        !f.relationshipGoals.contains(user.relationshipGoal)) {
      return false;
    }

    // Verified profiles only.
    if (f.verifiedOnly && user.verificationLevel == 'none') return false;

    // Distance: approximate, using geoHash cell centres.
    // maxDistanceKmLimit means no distance filter.
    if (f.maxDistanceKm < DiscoveryFilters.maxDistanceKmLimit) {
      if (!_passesDistance(user, f, currentUser)) return false;
    }

    return true;
  }

  /// Approximate distance check using geoHash cell centres.
  ///
  /// Returns true (include profile) when distance cannot be computed.
  /// Cell-centre lat/lng values are computed internally and never exposed
  /// to callers, UI, or logs.
  bool _passesDistance(
    UserModel user,
    DiscoveryFilters f,
    UserModel currentUser,
  ) {
    if (user.geoHash.isEmpty || currentUser.geoHash.isEmpty) return true;
    try {
      final (lat1, lng1) = GeoHashUtils.decodeCellCenter(currentUser.geoHash);
      final (lat2, lng2) = GeoHashUtils.decodeCellCenter(user.geoHash);
      // Suppress unused variables lint — values are intentionally discarded
      // after the distance computation.
      final approxKm = DistanceUtils.haversineKm(lat1, lng1, lat2, lng2);
      return approxKm <= f.maxDistanceKm;
    } catch (_) {
      return true;
    }
  }
}
