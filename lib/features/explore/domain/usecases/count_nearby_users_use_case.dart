import '../../../../core/utils/distance_utils.dart';
import '../../../../core/utils/geohash_utils.dart';
import '../../../../shared/models/user_model.dart';
import '../models/nearby_user_count.dart';
import '../repositories/discovery_repository.dart';
import '../utils/nearby_count_bucket.dart';

// ── Outcome sealed hierarchy ──────────────────────────────────────────────────

sealed class CountNearbyUsersOutcome {
  const CountNearbyUsersOutcome();
}

final class CountNearbyUsersUnauthenticated extends CountNearbyUsersOutcome {
  const CountNearbyUsersUnauthenticated();
}

final class CountNearbyUsersNeedsLocation extends CountNearbyUsersOutcome {
  const CountNearbyUsersNeedsLocation();
}

final class CountNearbyUsersSuccess extends CountNearbyUsersOutcome {
  const CountNearbyUsersSuccess({required this.count});
  final NearbyUserCount count;
}

final class CountNearbyUsersError extends CountNearbyUsersOutcome {
  const CountNearbyUsersError();
}

// ── Use case ──────────────────────────────────────────────────────────────────

/// Counts eligible users within [radiusKm] of the current user.
///
/// Privacy guarantees:
/// - Distance filtering uses geoHash cell centres — never exact coordinates.
/// - Returns only an aggregate [NearbyUserCount]; no profile list, no user IDs.
/// - Blocked users are excluded from the count.
/// - The raw count is for internal/test use only; the UI must use [bucket].
/// - No private location documents are read.
/// - No coordinates are logged or returned to callers.
class CountNearbyUsersUseCase {
  const CountNearbyUsersUseCase({required this.repository});

  final DiscoveryRepository repository;

  static const int _kFetchLimit = 200;
  static const int _kDefaultRadiusKm = 5;

  Future<CountNearbyUsersOutcome> call({
    required UserModel? currentUser,
    required Set<String> blockedUserIds,
    int radiusKm = _kDefaultRadiusKm,
  }) async {
    if (currentUser == null) return const CountNearbyUsersUnauthenticated();
    if (currentUser.geoHash.isEmpty) return const CountNearbyUsersNeedsLocation();

    double centerLat;
    double centerLng;
    try {
      (centerLat, centerLng) = GeoHashUtils.decodeCellCenter(currentUser.geoHash);
    } catch (_) {
      return const CountNearbyUsersNeedsLocation();
    }
    if (centerLat == 0.0 && centerLng == 0.0) {
      return const CountNearbyUsersNeedsLocation();
    }

    try {
      final page = await repository.loadPage(
        currentUserId: currentUser.id,
        pageSize: _kFetchLimit,
      );

      var count = 0;
      for (final user in page.profiles) {
        if (user.id == currentUser.id) continue;
        if (blockedUserIds.contains(user.id)) continue;
        if (user.profileImages.isEmpty) continue;
        if (user.geoHash.isEmpty) continue;

        try {
          final (uLat, uLng) = GeoHashUtils.decodeCellCenter(user.geoHash);
          if (uLat == 0.0 && uLng == 0.0) continue;
          // Internal distance computation — values never exposed to UI or logs.
          final approxKm = DistanceUtils.haversineKm(
            centerLat, centerLng, uLat, uLng,
          );
          if (approxKm <= radiusKm) count++;
        } catch (_) {
          // Skip users with unparseable geoHash.
        }
      }

      final bucket = bucketNearbyCount(count);
      return CountNearbyUsersSuccess(
        count: NearbyUserCount(
          rawCount: count,
          radiusKm: radiusKm,
          bucket: bucket,
        ),
      );
    } catch (_) {
      return const CountNearbyUsersError();
    }
  }
}
