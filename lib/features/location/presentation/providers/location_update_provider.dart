import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/location_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/update_current_location_use_case.dart';
import 'location_permission_provider.dart';

export '../../domain/usecases/update_current_location_use_case.dart'
    show UpdateLocationError;

// ── Supporting providers ──────────────────────────────────────────────────────

final locationServiceProvider = Provider<LocationService>(
  (_) => const LocationService(),
);

final locationRepositoryProvider = Provider<LocationRepository>(
  (_) => LocationRepositoryImpl(),
);

/// Streams the timestamp of the current user's last location update.
/// Emits null when the private location document does not exist yet.
/// Only the timestamp is read — coordinates are never accessed.
///
/// Non-autoDispose so [locationLifecycleProvider] can reliably read the
/// current cached value without cold-stream races on every lifecycle event.
final lastLocationUpdatedAtProvider = StreamProvider<DateTime?>((ref) {
  final userId = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (userId == null) return Stream.value(null);
  return ref.watch(locationRepositoryProvider).watchLastUpdatedAt(userId);
});

// ── State ─────────────────────────────────────────────────────────────────────

class LocationUpdateState {
  const LocationUpdateState({
    this.isUpdating = false,
    this.error,
  });

  final bool isUpdating;

  /// Typed error from the last update attempt. Null means no error or no
  /// update has been attempted yet. The screen layer maps this to l10n strings.
  final UpdateLocationError? error;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final locationUpdateProvider = NotifierProvider.autoDispose<
    LocationUpdateNotifier, LocationUpdateState>(
  LocationUpdateNotifier.new,
);

class LocationUpdateNotifier
    extends AutoDisposeNotifier<LocationUpdateState> {
  @override
  LocationUpdateState build() => const LocationUpdateState();

  /// Reads the current foreground position and persists it to Firestore.
  /// No-ops if an update is already in progress.
  Future<void> updateCurrentLocation() async {
    // TODO(diag): remove diagnostic prints before production
    debugPrint('[PROVIDER] updateCurrentLocation: called');
    if (state.isUpdating) {
      debugPrint('[PROVIDER] updateCurrentLocation: already updating — skipped');
      return;
    }

    final userId = ref.read(authStateChangesProvider).valueOrNull?.uid;
    debugPrint('[PROVIDER] userId: $userId');
    if (userId == null) {
      debugPrint('[PROVIDER] → permissionDenied (no auth user)');
      state = const LocationUpdateState(
        error: UpdateLocationError.permissionDenied,
      );
      return;
    }

    debugPrint('[PROVIDER] isUpdating: setting true');
    state = const LocationUpdateState(isUpdating: true);

    final error = await UpdateCurrentLocationUseCase(
      permissionService: ref.read(locationPermissionServiceProvider),
      locationService: ref.read(locationServiceProvider),
      locationRepository: ref.read(locationRepositoryProvider),
    ).call(userId);

    debugPrint('[PROVIDER] useCase result: error=$error');
    state = LocationUpdateState(error: error);
    debugPrint('[PROVIDER] finalState: isUpdating=${state.isUpdating} error=${state.error}');
  }
}
