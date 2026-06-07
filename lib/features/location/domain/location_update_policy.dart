/// Policy constants and helpers for location update decisions.
///
/// This is a pure utility — it does NOT wire up any lifecycle listener or
/// stream. Automatic foreground/resume updates are deferred; callers are
/// responsible for invoking [shouldAutoUpdate] at the appropriate time.
abstract final class LocationUpdatePolicy {
  /// Minimum interval between automatic (non-user-initiated) location updates.
  ///
  /// Manual updates via the "Update location" button are always allowed
  /// regardless of this threshold.
  static const Duration autoUpdateThreshold = Duration(hours: 6);

  /// Returns true when an automatic update is appropriate given
  /// [lastUpdatedAt].
  ///
  /// Returns true unconditionally if [lastUpdatedAt] is null (location has
  /// never been recorded). Returns false if the elapsed time since the last
  /// update is less than [autoUpdateThreshold].
  ///
  /// Callers must still verify permission and service status independently
  /// before invoking a location update.
  static bool shouldAutoUpdate(DateTime? lastUpdatedAt) {
    if (lastUpdatedAt == null) return true;
    return DateTime.now().difference(lastUpdatedAt) >= autoUpdateThreshold;
  }
}
