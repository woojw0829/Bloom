import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Thrown when the device location service is off.
class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();
}

/// Thrown when foreground location permission is not granted.
class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();
}

/// Thrown when the device cannot determine a position for any other reason.
class LocationUnavailableException implements Exception {
  const LocationUnavailableException([this.cause]);
  final Object? cause;
}

/// Reads the device's current foreground position via Geolocator.
///
/// Does NOT request permission — call this only after permission is confirmed
/// granted by [LocationPermissionService]. Does NOT start streams or background
/// tracking.
class LocationService {
  const LocationService();

  /// Returns the current [Position] from the device's location hardware.
  ///
  /// Uses [LocationAccuracy.medium] (~100 m): sufficient for discovery-radius
  /// calculations without unnecessarily draining battery.
  ///
  /// Throws [LocationServiceDisabledException] if the OS location service is off.
  /// Throws [LocationPermissionDeniedException] if permission is denied or revoked.
  /// Throws [LocationUnavailableException] for any other hardware/timeout failure.
  Future<Position> getCurrentPosition() async {
    // TODO(diag): remove diagnostic prints before production
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('[LOC] isLocationServiceEnabled: $serviceEnabled');
    if (!serviceEnabled) throw const LocationServiceDisabledException();

    final permission = await Geolocator.checkPermission();
    debugPrint('[LOC] checkPermission: $permission');
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      throw const LocationPermissionDeniedException();
    }

    debugPrint('[LOC] getCurrentPosition: calling (accuracy=medium, timeLimit=15s, forceLocationManager=${Platform.isAndroid})');
    // On Android, forceLocationManager bypasses the Fused Location Provider and
    // reads directly from LocationManager — required for emulator mock locations
    // to be visible, and more reliable on devices where FLP has a stale cache.
    final locationSettings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 15),
            forceLocationManager: true,
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          );
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      debugPrint('[LOC] current position acquired');
      return position;
    } catch (e) {
      debugPrint('[LOC] getCurrentPosition: FAILED (${e.runtimeType}) $e');
      throw LocationUnavailableException(e);
    }
  }
}
