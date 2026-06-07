import 'package:bloom/features/location/domain/location_update_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationUpdatePolicy.shouldAutoUpdate', () {
    test('returns true when lastUpdatedAt is null (never updated)', () {
      expect(LocationUpdatePolicy.shouldAutoUpdate(null), isTrue);
    });

    test('returns false when lastUpdatedAt is within the threshold', () {
      final recentUpdate = DateTime.now().subtract(const Duration(hours: 1));
      expect(LocationUpdatePolicy.shouldAutoUpdate(recentUpdate), isFalse);
    });

    test('returns false when lastUpdatedAt is exactly at the threshold boundary minus 1 second', () {
      final justUnder = DateTime.now().subtract(
        LocationUpdatePolicy.autoUpdateThreshold - const Duration(seconds: 1),
      );
      expect(LocationUpdatePolicy.shouldAutoUpdate(justUnder), isFalse);
    });

    test('returns true when lastUpdatedAt equals the threshold duration ago', () {
      final atThreshold = DateTime.now()
          .subtract(LocationUpdatePolicy.autoUpdateThreshold);
      expect(LocationUpdatePolicy.shouldAutoUpdate(atThreshold), isTrue);
    });

    test('returns true when lastUpdatedAt is older than the threshold', () {
      final old = DateTime.now().subtract(const Duration(hours: 24));
      expect(LocationUpdatePolicy.shouldAutoUpdate(old), isTrue);
    });

    test('autoUpdateThreshold is 6 hours', () {
      expect(LocationUpdatePolicy.autoUpdateThreshold,
          const Duration(hours: 6));
    });
  });
}
