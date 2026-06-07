import 'compatibility_score.dart';
import 'discovery_profile.dart';

/// An approximate geographic point derived from a public geoHash cell centre.
///
/// NOT an exact location — at geoHash precision 5 the cell is ≈ 4.9 × 4.9 km
/// and the centre is at most ≈ 2.5 km from any point in the cell.
/// Values are used internally for map marker positioning only.
/// They must never be displayed as text or written to logs.
class MapApproximatePoint {
  const MapApproximatePoint({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

/// A [DiscoveryProfile] enriched with an approximate map position and an
/// optional compatibility score, for rendering in [MapDiscoveryScreen].
///
/// [approximatePoint] is derived exclusively from [DiscoveryProfile.geoHash]
/// (a public field). No private location documents are read to construct it.
/// The model is ephemeral — it is never written to Firestore.
class MapDiscoveryProfile {
  const MapDiscoveryProfile({
    required this.profile,
    required this.approximatePoint,
    this.score,
  });

  final DiscoveryProfile profile;

  /// Cell-centre position derived from [profile.geoHash].
  /// Internal use only — must not appear in UI text or logs.
  final MapApproximatePoint approximatePoint;

  final CompatibilityScore? score;
}
