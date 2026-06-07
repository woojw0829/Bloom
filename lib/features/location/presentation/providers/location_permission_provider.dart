import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/location_permission_service.dart';

export '../../../../core/services/location_permission_service.dart'
    show LocationPermissionStatus;

// ── Service provider ──────────────────────────────────────────────────────────

final locationPermissionServiceProvider = Provider<LocationPermissionService>(
  (_) => const LocationPermissionService(),
);

// ── State ─────────────────────────────────────────────────────────────────────

/// Transient state for the location permission screen.
/// Lives only while [LocationPermissionScreen] is in the tree.
class LocationPermissionState {
  const LocationPermissionState({
    this.status = LocationPermissionStatus.notDetermined,
    this.isLoading = false,
    this.errorMessage,
  });

  final LocationPermissionStatus status;
  final bool isLoading;

  /// Non-null after a failed check or request. Always user-readable.
  final String? errorMessage;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final locationPermissionProvider = NotifierProvider.autoDispose<
    LocationPermissionNotifier, LocationPermissionState>(
  LocationPermissionNotifier.new,
);

class LocationPermissionNotifier
    extends AutoDisposeNotifier<LocationPermissionState> {
  @override
  LocationPermissionState build() {
    // Automatically refresh permission status when the user returns from OS
    // settings (e.g., after granting permission in app settings).
    final listener = AppLifecycleListener(
      onResume: () => unawaited(refreshStatus()),
    );
    ref.onDispose(listener.dispose);

    unawaited(_init());
    return const LocationPermissionState(isLoading: true);
  }

  // ── Public actions ────────────────────────────────────────────────────────

  /// Re-checks the current service + permission status.
  /// No-ops if already loading to prevent concurrent checks.
  Future<void> refreshStatus() async {
    if (state.isLoading) return;
    state = LocationPermissionState(status: state.status, isLoading: true);
    try {
      final status =
          await ref.read(locationPermissionServiceProvider).checkStatus();
      state = LocationPermissionState(status: status);
    } catch (_) {
      state = LocationPermissionState(
        status: state.status,
        errorMessage: 'Failed to check location permission. Please try again.',
      );
    }
  }

  /// Shows the OS permission dialog (or returns the existing status if the
  /// dialog would not be shown). No-ops if already loading.
  Future<void> requestPermission() async {
    if (state.isLoading) return;
    state = LocationPermissionState(status: state.status, isLoading: true);
    try {
      final status = await ref
          .read(locationPermissionServiceProvider)
          .requestPermission();
      state = LocationPermissionState(status: status);
    } catch (_) {
      state = LocationPermissionState(
        status: state.status,
        errorMessage:
            'Failed to request location permission. Please try again.',
      );
    }
  }

  /// Opens OS app settings. The [AppLifecycleListener] in [build] will
  /// trigger [refreshStatus] when the user returns to the app.
  Future<void> openAppSettings() async {
    await ref.read(locationPermissionServiceProvider).openAppSettings();
  }

  /// Opens OS location settings. The [AppLifecycleListener] in [build] will
  /// trigger [refreshStatus] when the user returns to the app.
  Future<void> openLocationSettings() async {
    await ref.read(locationPermissionServiceProvider).openLocationSettings();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _init() async {
    try {
      final status =
          await ref.read(locationPermissionServiceProvider).checkStatus();
      state = LocationPermissionState(status: status);
    } catch (_) {
      state = const LocationPermissionState(
        errorMessage: 'Failed to check location permission. Please try again.',
      );
    }
  }
}
