import '../models/nearby_user_count.dart';

/// Maps a raw nearby-user count to a privacy-safe [NearbyCountBucket].
///
/// Buckets prevent reverse-engineering of exact counts for small values:
/// 1–4 users → fewerThanFive (not "3 people here").
/// 5+ → rounded-down multiples of 5.
/// 50+ → capped bucket (no upper-bound leakage).
NearbyCountBucket bucketNearbyCount(int count) {
  if (count <= 0) return NearbyCountBucket.none;
  if (count < 5) return NearbyCountBucket.fewerThanFive;
  if (count < 10) return NearbyCountBucket.fivePlus;
  if (count < 15) return NearbyCountBucket.tenPlus;
  if (count < 20) return NearbyCountBucket.fifteenPlus;
  if (count < 25) return NearbyCountBucket.twentyPlus;
  if (count < 30) return NearbyCountBucket.twentyFivePlus;
  if (count < 35) return NearbyCountBucket.thirtyPlus;
  if (count < 40) return NearbyCountBucket.thirtyFivePlus;
  if (count < 45) return NearbyCountBucket.fortyPlus;
  if (count < 50) return NearbyCountBucket.fortyFivePlus;
  return NearbyCountBucket.fiftyPlus;
}
