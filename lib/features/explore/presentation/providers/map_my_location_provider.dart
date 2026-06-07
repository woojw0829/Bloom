import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException;

import '../../../../core/services/location_service.dart';
import '../../../location/presentation/providers/location_permission_provider.dart';
import '../../../location/presentation/providers/location_update_provider.dart';

// ── Error enum ────────────────────────────────────────────────────────────────

enum MapMyLocationError {
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  unavailable,
}

// ── State ─────────────────────────────────────────────────────────────────────

class MapMyLocationState {
  const MapMyLocationState({
    this.isChecking = false,
    this.hasPermission = false,
    this.error,
  });

  final bool isChecking;

  /// True when device location permission is confirmed granted.
  /// Controls the Google Maps my-location layer (local display only —
  /// the user's position is never sent to other users or written to Firestore).
  final bool hasPermission;

  /// Non-null after a failed permission check or location fetch.
  final MapMyLocationError? error;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final mapMyLocationProvider =
    NotifierProvider<MapMyLocationNotifier, MapMyLocationState>(
  MapMyLocationNotifier.new,
);

// ── Notifier ──────────────────────────────────────────────────────────────────

class MapMyLocationNotifier extends Notifier<MapMyLocationState> {
  @override
  MapMyLocationState build() {
    Future.microtask(_checkPermission);
    return const MapMyLocationState(isChecking: true);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _checkPermission() async {
    try {
      final status =
          await ref.read(locationPermissionServiceProvider).checkStatus();
      state = MapMyLocationState(
        hasPermission: status == LocationPermissionStatus.granted,
      );
    } catch (_) {
      state = const MapMyLocationState();
    }
  }

  // ── Public actions ────────────────────────────────────────────────────────

  /// Checks or requests location permission, then fetches the current device
  /// position for camera animation.
  ///
  /// The returned [Position] is for immediate camera animation only.
  /// Callers must not log, store, or display its coordinates as text.
  ///
  /// Returns null when permission is unavailable or location cannot be read.
  Future<Position?> requestAndGetLocation() async {
    if (state.isChecking) return null;

    final permService = ref.read(locationPermissionServiceProvider);
    state = MapMyLocationState(
      isChecking: true,
      hasPermission: state.hasPermission,
    );

    var status = await permService.checkStatus();
    if (status == LocationPermissionStatus.denied) {
      status = await permService.requestPermission();
    }

    switch (status) {
      case LocationPermissionStatus.deniedForever:
        state = const MapMyLocationState(
          error: MapMyLocationError.permissionDeniedForever,
        );
        return null;
      case LocationPermissionStatus.serviceDisabled:
        state = const MapMyLocationState(
          error: MapMyLocationError.serviceDisabled,
        );
        return null;
      case LocationPermissionStatus.denied:
      case LocationPermissionStatus.notDetermined:
        state = const MapMyLocationState(
          error: MapMyLocationError.permissionDenied,
        );
        return null;
      case LocationPermissionStatus.granted:
        break;
    }

    try {
      final position =
          await ref.read(locationServiceProvider).getCurrentPosition();
      state = const MapMyLocationState(hasPermission: true);
      return position;
    } on LocationServiceDisabledException {
      state = const MapMyLocationState(
        hasPermission: true,
        error: MapMyLocationError.serviceDisabled,
      );
      return null;
    } on LocationPermissionDeniedException {
      state = const MapMyLocationState(
        error: MapMyLocationError.permissionDenied,
      );
      return null;
    } catch (_) {
      state = const MapMyLocationState(
        hasPermission: true,
        error: MapMyLocationError.unavailable,
      );
      return null;
    }
  }

  /// Opens OS app settings so the user can grant a permanently-denied permission.
  Future<void> openSettings() async {
    await ref.read(locationPermissionServiceProvider).openAppSettings();
  }

  /// Opens OS location settings so the user can enable the device location service.
  Future<void> openLocationSettings() async {
    await ref.read(locationPermissionServiceProvider).openLocationSettings();
  }

  /// Clears the current error without changing the permission state.
  void clearError() {
    state = MapMyLocationState(
      isChecking: state.isChecking,
      hasPermission: state.hasPermission,
    );
  }
}
