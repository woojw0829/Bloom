import 'dart:math';

/// Pure-Dart utilities for geographic distance calculations.
///
/// No external package required. Results are in kilometres.
/// Callers should use AppLocalizations keys for any user-facing formatting.
abstract final class DistanceUtils {
  static const double _earthRadiusKm = 6371.0;

  /// Returns the great-circle distance in kilometres between two geographic
  /// coordinates using the Haversine formula.
  ///
  /// Suitable for distances up to thousands of km with < 0.5 % error.
  static double haversineKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final sinDLat = sin(dLat / 2);
    final sinDLng = sin(dLng / 2);
    final a = sinDLat * sinDLat +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sinDLng * sinDLng;
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  /// Formats [km] for approximate display.
  ///
  /// Under 1 km → "< 1 km". 1 km and above → rounded integer + " km".
  /// Not localised — UI callers must use the corresponding l10n keys
  /// (distanceLessThanOneKm / distanceKm) when displaying to users.
  static String formatApproxKm(double km) {
    if (km < 1.0) return '< 1 km';
    return '${km.round()} km';
  }

  static double _toRad(double degrees) => degrees * pi / 180.0;
}
