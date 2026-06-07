import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required String geoHash,
  }) async {
    // TODO(diag): remove diagnostic prints before production
    debugPrint('[REPO] updateUserLocation: userId=$userId');
    debugPrint('[REPO] privatePath: users/$userId/private/location');
    debugPrint('[REPO] userPath:    users/$userId');
    debugPrint('[REPO] geoHash=$geoHash');

    final privateRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('location');
    final userRef = _firestore.collection('users').doc(userId);

    // Atomic batch: both writes succeed together or both fail.
    // Eliminates the two-write inconsistency risk from Phase 5B.
    final batch = _firestore.batch()
      // Exact GeoPoint — ONLY stored here, never on the public user document.
      ..set(
        privateRef,
        {
          'location': GeoPoint(latitude, longitude),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: false),
      )
      // Public user document: only GeoHash and updatedAt — no coordinates.
      // updateUserProfile(UserModel) is intentionally NOT used (L1 risk).
      ..update(userRef, {
        'geoHash': geoHash,
        'updatedAt': FieldValue.serverTimestamp(),
      });

    debugPrint('[REPO] batch.commit: starting');
    try {
      await batch.commit();
      debugPrint('[REPO] batch.commit: success');
    } catch (e) {
      debugPrint('[REPO] batch.commit: FAILED (${e.runtimeType}) $e');
      if (e is FirebaseException) {
        debugPrint('[REPO] FirebaseException code=${e.code} message=${e.message}');
      }
      rethrow;
    }
  }

  @override
  Stream<DateTime?> watchLastUpdatedAt(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('private')
        .doc('location')
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      final ts = snap.data()?['updatedAt'];
      if (ts is! Timestamp) return null;
      return ts.toDate();
    });
  }
}
