import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../shared/models/user_model.dart';
import '../../domain/repositories/discovery_repository.dart';

/// Firestore-backed implementation of [DiscoveryRepository].
///
/// Query: active + public users, ordered by most recently updated.
/// Required composite index (accountStatus ASC, profileVisibility ASC,
/// updatedAt DESC) — see firestore.indexes.json.
///
/// Privacy guarantees:
/// - Never reads users/{id}/private/location or any private subcollection.
/// - Never writes to Firestore.
/// - Exact coordinates are never accessed or returned.
class DiscoveryRepositoryImpl implements DiscoveryRepository {
  DiscoveryRepositoryImpl() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<DiscoveryPage> loadPage({
    required String currentUserId,
    QueryDocumentSnapshot<Map<String, dynamic>>? afterDocument,
    required int pageSize,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .where('accountStatus', isEqualTo: 'active')
        .where('profileVisibility', isEqualTo: 'public')
        .orderBy('updatedAt', descending: true)
        .limit(pageSize);

    if (afterDocument != null) {
      query = query.startAfterDocument(afterDocument);
    }

    final snapshot = await query.get();

    final profiles = snapshot.docs
        .map((doc) {
          try {
            // Ensure 'id' is present — stored in document data during onboarding,
            // but fall back to document ID as a safeguard.
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] ??= doc.id;
            return UserModel.fromJson(data);
          } catch (_) {
            // Skip malformed documents silently.
            return null;
          }
        })
        .whereType<UserModel>()
        // Exclude the current user defensively at the data layer.
        .where((user) => user.id != currentUserId)
        .toList();

    return DiscoveryPage(
      profiles: profiles,
      lastDocument: snapshot.docs.isEmpty ? null : snapshot.docs.last,
      rawCount: snapshot.docs.length,
    );
  }
}
