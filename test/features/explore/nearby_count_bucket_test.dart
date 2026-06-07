import 'package:bloom/features/explore/domain/models/nearby_user_count.dart';
import 'package:bloom/features/explore/domain/utils/nearby_count_bucket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bucketNearbyCount', () {
    // ── none ────────────────────────────────────────────────────────────────
    test('0 → none', () => expect(bucketNearbyCount(0), NearbyCountBucket.none));
    test('negative → none',
        () => expect(bucketNearbyCount(-5), NearbyCountBucket.none));

    // ── fewerThanFive ────────────────────────────────────────────────────────
    test('1 → fewerThanFive',
        () => expect(bucketNearbyCount(1), NearbyCountBucket.fewerThanFive));
    test('4 → fewerThanFive',
        () => expect(bucketNearbyCount(4), NearbyCountBucket.fewerThanFive));

    // ── fivePlus ─────────────────────────────────────────────────────────────
    test('5 → fivePlus',
        () => expect(bucketNearbyCount(5), NearbyCountBucket.fivePlus));
    test('9 → fivePlus',
        () => expect(bucketNearbyCount(9), NearbyCountBucket.fivePlus));

    // ── tenPlus ──────────────────────────────────────────────────────────────
    test('10 → tenPlus',
        () => expect(bucketNearbyCount(10), NearbyCountBucket.tenPlus));
    test('14 → tenPlus',
        () => expect(bucketNearbyCount(14), NearbyCountBucket.tenPlus));

    // ── fifteenPlus ──────────────────────────────────────────────────────────
    test('15 → fifteenPlus',
        () => expect(bucketNearbyCount(15), NearbyCountBucket.fifteenPlus));
    test('19 → fifteenPlus',
        () => expect(bucketNearbyCount(19), NearbyCountBucket.fifteenPlus));

    // ── twentyPlus ───────────────────────────────────────────────────────────
    test('20 → twentyPlus',
        () => expect(bucketNearbyCount(20), NearbyCountBucket.twentyPlus));

    // ── twentyFivePlus ───────────────────────────────────────────────────────
    test('25 → twentyFivePlus',
        () => expect(bucketNearbyCount(25), NearbyCountBucket.twentyFivePlus));

    // ── thirtyPlus ───────────────────────────────────────────────────────────
    test('30 → thirtyPlus',
        () => expect(bucketNearbyCount(30), NearbyCountBucket.thirtyPlus));

    // ── thirtyFivePlus ───────────────────────────────────────────────────────
    test('35 → thirtyFivePlus',
        () => expect(bucketNearbyCount(35), NearbyCountBucket.thirtyFivePlus));

    // ── fortyPlus ────────────────────────────────────────────────────────────
    test('40 → fortyPlus',
        () => expect(bucketNearbyCount(40), NearbyCountBucket.fortyPlus));

    // ── fortyFivePlus ────────────────────────────────────────────────────────
    test('45 → fortyFivePlus',
        () => expect(bucketNearbyCount(45), NearbyCountBucket.fortyFivePlus));
    test('49 → fortyFivePlus',
        () => expect(bucketNearbyCount(49), NearbyCountBucket.fortyFivePlus));

    // ── fiftyPlus ────────────────────────────────────────────────────────────
    test('50 → fiftyPlus',
        () => expect(bucketNearbyCount(50), NearbyCountBucket.fiftyPlus));
    test('100 → fiftyPlus',
        () => expect(bucketNearbyCount(100), NearbyCountBucket.fiftyPlus));

    // ── Boundary transitions ─────────────────────────────────────────────────
    test('4 and 5 are in different buckets', () {
      expect(bucketNearbyCount(4), isNot(bucketNearbyCount(5)));
    });

    test('9 and 10 are in different buckets', () {
      expect(bucketNearbyCount(9), isNot(bucketNearbyCount(10)));
    });

    test('49 and 50 are in different buckets', () {
      expect(bucketNearbyCount(49), isNot(bucketNearbyCount(50)));
    });
  });

  group('NearbyUserCount', () {
    test('stores rawCount, radiusKm, and bucket', () {
      const count = NearbyUserCount(
        rawCount: 12,
        radiusKm: 5,
        bucket: NearbyCountBucket.tenPlus,
      );
      expect(count.rawCount, 12);
      expect(count.radiusKm, 5);
      expect(count.bucket, NearbyCountBucket.tenPlus);
    });
  });
}
