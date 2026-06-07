import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/geohash_utils.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../safety/presentation/providers/block_provider.dart';
import '../../domain/models/map_discovery_profile.dart';
import '../../domain/models/nearby_user_count.dart';
import '../../domain/usecases/count_nearby_users_use_case.dart';
import 'discovery_feed_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class MapDiscoveryState {
  const MapDiscoveryState({
    this.nearbyCount,
    this.currentUserPoint,
    this.isLoading = false,
    this.hasError = false,
    this.needsLocation = false,
  });

  /// Privacy-safe aggregate count. UI must use [NearbyUserCount.bucket],
  /// never [NearbyUserCount.rawCount], for display.
  final NearbyUserCount? nearbyCount;

  /// Approximate centre for the initial camera position.
  /// Derived from currentUser.geoHash — internal only, never shown as text.
  final MapApproximatePoint? currentUserPoint;

  final bool isLoading;
  final bool hasError;
  final bool needsLocation;

  bool get isEmpty =>
      !isLoading && !hasError && !needsLocation && nearbyCount == null;

  MapDiscoveryState copyWith({
    NearbyUserCount? nearbyCount,
    MapApproximatePoint? currentUserPoint,
    bool? isLoading,
    bool? hasError,
    bool? needsLocation,
  }) {
    return MapDiscoveryState(
      nearbyCount: nearbyCount ?? this.nearbyCount,
      currentUserPoint: currentUserPoint ?? this.currentUserPoint,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      needsLocation: needsLocation ?? this.needsLocation,
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Non-autoDispose: state is preserved when the user navigates away and
/// returns. Rebuilds automatically when userId or blocked-user set changes.
final mapDiscoveryProvider =
    NotifierProvider<MapDiscoveryNotifier, MapDiscoveryState>(
  MapDiscoveryNotifier.new,
);

class MapDiscoveryNotifier extends Notifier<MapDiscoveryState> {
  var _disposed = false;

  @override
  MapDiscoveryState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    // Rebuild when the authenticated user changes.
    ref.watch(currentUserProvider.select((a) => a.valueOrNull?.id));
    // Rebuild when the blocked-user set changes — blocked users are excluded
    // from the nearby count.
    ref.watch(blockedUserIdsProvider);

    Future.microtask(_load);
    return const MapDiscoveryState(isLoading: true);
  }

  CountNearbyUsersUseCase get _useCase => CountNearbyUsersUseCase(
        repository: ref.read(discoveryRepositoryProvider),
      );

  Future<void> _load() async {
    if (_disposed) return;
    state = const MapDiscoveryState(isLoading: true);

    final currentUser =
        ref.read(currentUserProvider).valueOrNull;
    final outcome = await _useCase.call(
      currentUser: currentUser,
      blockedUserIds:
          ref.read(blockedUserIdsProvider).valueOrNull ?? const {},
    );
    if (_disposed) return;

    switch (outcome) {
      case CountNearbyUsersUnauthenticated():
        state = const MapDiscoveryState();
      case CountNearbyUsersNeedsLocation():
        state = const MapDiscoveryState(needsLocation: true);
      case CountNearbyUsersError():
        state = const MapDiscoveryState(hasError: true);
      case CountNearbyUsersSuccess(:final count):
        final userPoint = _decodePoint(currentUser!.geoHash);
        state = MapDiscoveryState(
          nearbyCount: count,
          currentUserPoint: userPoint,
        );
    }
  }

  Future<void> refresh() async {
    if (state.isLoading) return;
    await _load();
  }

  /// Decodes a geoHash to a cell-centre point for camera positioning.
  ///
  /// Returns null for empty or unrecognised hashes.
  /// The returned values are used only for camera positioning — never shown
  /// as text or written to logs.
  MapApproximatePoint? _decodePoint(String geoHash) {
    if (geoHash.isEmpty) return null;
    try {
      final (lat, lng) = GeoHashUtils.decodeCellCenter(geoHash);
      if (lat == 0.0 && lng == 0.0) return null;
      return MapApproximatePoint(lat: lat, lng: lng);
    } catch (_) {
      return null;
    }
  }
}
