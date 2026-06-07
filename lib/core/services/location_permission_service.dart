import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  serviceDisabled,
  notDetermined,
  denied,
  deniedForever,
  granted,
}

/// Wraps [Geolocator] to expose app-friendly location permission state.
///
/// Phase 5A only: checks and requests foreground permission.
/// Does NOT read latitude/longitude, write to Firestore, or generate GeoHash.
class LocationPermissionService {
  const LocationPermissionService();

  /// Returns the current combined status of the location service and
  /// the app's foreground location permission.
  Future<LocationPermissionStatus> checkStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;

    final permission = await Geolocator.checkPermission();
    return _map(permission);
  }

  /// Requests foreground location permission and returns the resulting status.
  /// If the device location service is off, returns [LocationPermissionStatus.serviceDisabled]
  /// without showing a permission dialog.
  Future<LocationPermissionStatus> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;

    final permission = await Geolocator.requestPermission();
    return _map(permission);
  }

  /// Opens the OS app settings page so the user can grant a permanently-denied
  /// location permission. Returns immediately after launching settings.
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Opens the OS location settings page so the user can enable the device
  /// location service. Returns immediately after launching settings.
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  LocationPermissionStatus _map(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.whileInUse ||
        LocationPermission.always =>
          LocationPermissionStatus.granted,
        LocationPermission.denied => LocationPermissionStatus.denied,
        LocationPermission.deniedForever =>
          LocationPermissionStatus.deniedForever,
        _ => LocationPermissionStatus.notDetermined,
      };
}
