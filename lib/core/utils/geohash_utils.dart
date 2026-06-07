import '../constants/app_constants.dart';

/// Encodes geographic coordinates into a geohash string.
///
/// Geohash at precision 5 produces a 5-character string covering roughly a
/// 4.9 km × 4.9 km cell — appropriate for approximate discovery without
/// exposing exact user coordinates.
abstract final class GeoHashUtils {
  static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Decodes [hash] to the approximate centre of its bounding cell.
  ///
  /// Returns `(lat, lng)` of the cell centre — **not** the user's exact
  /// location. At precision 5 the cell is ≈ 4.9 × 4.9 km; the centre is at
  /// most ≈ 2.5 km from any point in the cell. Use only for approximate
  /// distance filtering. Never display the returned values to users.
  ///
  /// Returns `(0.0, 0.0)` for an empty or unrecognised hash.
  static (double lat, double lng) decodeCellCenter(String hash) {
    if (hash.isEmpty) return (0.0, 0.0);
    var minLat = -90.0, maxLat = 90.0;
    var minLng = -180.0, maxLng = 180.0;
    var isLng = true;

    for (final ch in hash.split('')) {
      final idx = _base32.indexOf(ch);
      if (idx < 0) continue;
      for (var bits = 4; bits >= 0; bits--) {
        final bit = (idx >> bits) & 1;
        if (isLng) {
          final mid = (minLng + maxLng) / 2;
          if (bit == 1) {
            minLng = mid;
          } else {
            maxLng = mid;
          }
        } else {
          final mid = (minLat + maxLat) / 2;
          if (bit == 1) {
            minLat = mid;
          } else {
            maxLat = mid;
          }
        }
        isLng = !isLng;
      }
    }
    return ((minLat + maxLat) / 2, (minLng + maxLng) / 2);
  }

  /// Returns a geohash for [lat] / [lng] at [precision] characters.
  ///
  /// Defaults to [AppConstants.geoHashPrecision] (5 characters).
  /// Latitude must be in [-90, 90]; longitude in [-180, 180].
  static String encode(
    double lat,
    double lng, {
    int precision = AppConstants.geoHashPrecision,
  }) {
    assert(lat >= -90 && lat <= 90, 'latitude out of range');
    assert(lng >= -180 && lng <= 180, 'longitude out of range');
    assert(precision >= 1, 'precision must be >= 1');

    var minLat = -90.0, maxLat = 90.0;
    var minLng = -180.0, maxLng = 180.0;
    final result = StringBuffer();
    var bits = 0, bitsTotal = 0, hashValue = 0;

    while (result.length < precision) {
      if (bitsTotal.isEven) {
        // Longitude: even-indexed bits
        final mid = (minLng + maxLng) / 2;
        if (lng >= mid) {
          hashValue = (hashValue << 1) | 1;
          minLng = mid;
        } else {
          hashValue <<= 1;
          maxLng = mid;
        }
      } else {
        // Latitude: odd-indexed bits
        final mid = (minLat + maxLat) / 2;
        if (lat >= mid) {
          hashValue = (hashValue << 1) | 1;
          minLat = mid;
        } else {
          hashValue <<= 1;
          maxLat = mid;
        }
      }
      bitsTotal++;
      bits++;
      if (bits == 5) {
        result.write(_base32[hashValue]);
        bits = 0;
        hashValue = 0;
      }
    }
    return result.toString();
  }
}
