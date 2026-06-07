abstract final class AppConstants {
  static const String appName = 'Bloom';

  // Profile
  static const int maxProfilePhotos = 6;
  static const int maxBioLength = 500;
  static const int minAge = 18;
  static const int maxAge = 100;

  // Discovery defaults
  static const int defaultMinAge = 18;
  static const int defaultMaxAge = 45;
  static const int defaultMaxDistanceKm = 50;
  static const int maxDistanceKm = 100;

  // Location
  static const int geoHashPrecision = 5;

  // Pagination
  static const int exploreFeedPageSize = 20;
  static const int browsePageSize = 20;
  static const int messagesPageSize = 30;
  static const int notificationsPageSize = 20;

  // Timing
  static const int typingIndicatorTimeoutMs = 3000;
  static const int presenceUpdateIntervalMs = 30000;
  static const int splashDurationMs = 2000;

  // RevenueCat
  static const String premiumEntitlementId = 'premium';
}
