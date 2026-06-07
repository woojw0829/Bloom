/// Contract for persisting the user's current location.
abstract class LocationRepository {
  /// Writes the user's location to Firestore atomically.
  ///
  /// Exact coordinates ([latitude], [longitude]) are stored only in the
  /// private subcollection `users/{userId}/private/location`.
  /// The main user document receives only [geoHash] and `updatedAt` —
  /// latitude and longitude are never written there.
  Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required String geoHash,
  });

  /// Streams the `updatedAt` timestamp of the user's private location document.
  /// Emits null when the document does not exist yet.
  /// Does NOT expose coordinates — only the timestamp is read.
  Stream<DateTime?> watchLastUpdatedAt(String userId);
}
