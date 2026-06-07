import 'package:flutter/foundation.dart';

import '../../../../core/services/location_permission_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/geohash_utils.dart';
import '../repositories/location_repository.dart';

/// Typed domain errors returned by [UpdateCurrentLocationUseCase].
enum UpdateLocationError {
  serviceDisabled,
  permissionDenied,
  locationUnavailable,
  storageFailed,
}

/// Checks permission, reads the current foreground position, generates a
/// GeoHash, and persists the result to Firestore.
///
/// Returns null on success, or an [UpdateLocationError] on any failure.
/// Never throws — all errors are captured and mapped to the enum.
class UpdateCurrentLocationUseCase {
  const UpdateCurrentLocationUseCase({
    required this._permissionService,
    required this._locationService,
    required this._locationRepository,
  });

  final LocationPermissionService _permissionService;
  final LocationService _locationService;
  final LocationRepository _locationRepository;

  Future<UpdateLocationError?> call(String userId) async {
    // TODO(diag): remove diagnostic prints before production
    debugPrint('[USECASE] call: userId=$userId');

    // 1. Pre-check permission without triggering a dialog.
    debugPrint('[USECASE] checkStatus: starting');
    final LocationPermissionStatus status;
    try {
      status = await _permissionService.checkStatus();
    } catch (e) {
      debugPrint('[USECASE] checkStatus: FAILED $e → locationUnavailable');
      return UpdateLocationError.locationUnavailable;
    }
    debugPrint('[USECASE] checkStatus: $status');

    if (status == LocationPermissionStatus.serviceDisabled) {
      debugPrint('[USECASE] → serviceDisabled');
      return UpdateLocationError.serviceDisabled;
    }
    if (status != LocationPermissionStatus.granted) {
      debugPrint('[USECASE] → permissionDenied (status=$status)');
      return UpdateLocationError.permissionDenied;
    }

    // 2. Read the current foreground position.
    debugPrint('[USECASE] getCurrentPosition: starting');
    final double latitude;
    final double longitude;
    try {
      final position = await _locationService.getCurrentPosition();
      latitude = position.latitude;
      longitude = position.longitude;
      debugPrint('[USECASE] getCurrentPosition: success');
    } on LocationServiceDisabledException {
      debugPrint('[USECASE] getCurrentPosition: LocationServiceDisabledException → serviceDisabled');
      return UpdateLocationError.serviceDisabled;
    } on LocationPermissionDeniedException {
      debugPrint('[USECASE] getCurrentPosition: LocationPermissionDeniedException → permissionDenied');
      return UpdateLocationError.permissionDenied;
    } catch (e) {
      debugPrint('[USECASE] getCurrentPosition: FAILED (${e.runtimeType}) $e → locationUnavailable');
      return UpdateLocationError.locationUnavailable;
    }

    // 3. Generate GeoHash from coordinates (precision from AppConstants).
    final geoHash = GeoHashUtils.encode(latitude, longitude);
    debugPrint('[USECASE] geoHash: $geoHash');

    // 4. Persist: exact GeoPoint to private subcollection, GeoHash to public doc.
    debugPrint('[USECASE] updateUserLocation: starting');
    try {
      await _locationRepository.updateUserLocation(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        geoHash: geoHash,
      );
      debugPrint('[USECASE] updateUserLocation: success');
    } catch (e) {
      debugPrint('[USECASE] updateUserLocation: FAILED (${e.runtimeType}) $e → storageFailed');
      return UpdateLocationError.storageFailed;
    }

    debugPrint('[USECASE] → success (null)');
    return null;
  }
}
