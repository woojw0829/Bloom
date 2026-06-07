enum NearbyCountBucket {
  none,
  fewerThanFive,
  fivePlus,
  tenPlus,
  fifteenPlus,
  twentyPlus,
  twentyFivePlus,
  thirtyPlus,
  thirtyFivePlus,
  fortyPlus,
  fortyFivePlus,
  fiftyPlus,
}

/// Privacy-safe aggregate of nearby eligible users within [radiusKm].
///
/// [rawCount] is for internal logic and tests only — the UI must display
/// [bucket], never the raw value, to avoid making individuals identifiable.
class NearbyUserCount {
  const NearbyUserCount({
    required this.rawCount,
    required this.radiusKm,
    required this.bucket,
  });

  final int rawCount;
  final int radiusKm;
  final NearbyCountBucket bucket;
}
