import 'package:bloom/core/utils/distance_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DistanceUtils.haversineKm', () {
    test('same point returns 0 km', () {
      expect(DistanceUtils.haversineKm(37.5665, 126.9780, 37.5665, 126.9780),
          0.0);
    });

    test('Seoul City Hall to Gangnam Station is approximately 10 km', () {
      // Seoul City Hall: 37.5663, 126.9779
      // Gangnam Station: 37.4979, 127.0276
      final km = DistanceUtils.haversineKm(
          37.5663, 126.9779, 37.4979, 127.0276);
      expect(km, closeTo(10.0, 1.5)); // ~10 km ± 1.5 km tolerance
    });

    test('Seoul to Busan is approximately 325 km', () {
      // Seoul: 37.5665, 126.9780
      // Busan: 35.1796, 129.0756
      final km = DistanceUtils.haversineKm(
          37.5665, 126.9780, 35.1796, 129.0756);
      expect(km, closeTo(325.0, 15.0)); // ~325 km ± 15 km tolerance
    });

    test('London to Paris is approximately 340 km', () {
      // London: 51.5074, -0.1278
      // Paris: 48.8566, 2.3522
      final km = DistanceUtils.haversineKm(
          51.5074, -0.1278, 48.8566, 2.3522);
      expect(km, closeTo(340.0, 15.0));
    });

    test('result is symmetric', () {
      final ab = DistanceUtils.haversineKm(37.5665, 126.9780, 35.1796, 129.0756);
      final ba = DistanceUtils.haversineKm(35.1796, 129.0756, 37.5665, 126.9780);
      expect(ab, closeTo(ba, 0.001));
    });
  });

  group('DistanceUtils.formatApproxKm', () {
    test('under 1 km returns "< 1 km"', () {
      expect(DistanceUtils.formatApproxKm(0.0), '< 1 km');
      expect(DistanceUtils.formatApproxKm(0.5), '< 1 km');
      expect(DistanceUtils.formatApproxKm(0.99), '< 1 km');
    });

    test('exactly 1 km returns "1 km"', () {
      expect(DistanceUtils.formatApproxKm(1.0), '1 km');
    });

    test('rounds to nearest km', () {
      expect(DistanceUtils.formatApproxKm(1.4), '1 km');
      expect(DistanceUtils.formatApproxKm(1.5), '2 km');
      expect(DistanceUtils.formatApproxKm(10.7), '11 km');
    });
  });
}
