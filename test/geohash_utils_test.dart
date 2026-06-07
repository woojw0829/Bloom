import 'package:bloom/core/utils/geohash_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeoHashUtils.encode', () {
    test('produces the correct length', () {
      expect(GeoHashUtils.encode(37.5665, 126.9780).length, 5);
      expect(GeoHashUtils.encode(0, 0, precision: 7).length, 7);
    });

    test('known value — Null Island (0,0) at precision 5', () {
      // Standard geohash for (0,0) at precision 5 is 's0000'.
      expect(GeoHashUtils.encode(0, 0), 's0000');
    });

    test('known value — Seoul (37.5665, 126.9780) at precision 5', () {
      expect(GeoHashUtils.encode(37.5665, 126.9780), 'wydm9');
    });

    test('known value — New York City (40.7128, -74.0060) at precision 5', () {
      // Standard geohash for NYC at precision 5 is 'dr5re'.
      expect(GeoHashUtils.encode(40.7128, -74.0060), 'dr5re');
    });

    test('uses only base32 alphabet characters', () {
      const alphabet = '0123456789bcdefghjkmnpqrstuvwxyz';
      final hash = GeoHashUtils.encode(51.5074, -0.1278); // London
      for (final ch in hash.split('')) {
        expect(alphabet.contains(ch), isTrue, reason: 'char "$ch" not in base32');
      }
    });
  });
}
