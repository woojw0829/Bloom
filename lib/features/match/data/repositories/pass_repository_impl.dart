import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/pass_repository.dart';

/// Firestore-backed implementation of [PassRepository].
///
/// Writes: users/{currentUserId}/passes/{targetUserId}
/// Schema: { passedUserId: string, createdAt: Timestamp }
///
/// Privacy guarantees:
/// - Never writes to the target user's document.
/// - Never reads or writes private subcollections.
/// - Does not write likes or matches.
class PassRepositoryImpl implements PassRepository {
  PassRepositoryImpl();

  // Accessed lazily so the constructor does not call FirebaseFirestore.instance
  // at instantiation time; this keeps unit tests that don't initialise Firebase
  // from crashing when the provider is created.
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _passesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('passes');

  @override
  Future<void> recordPass({
    required String currentUserId,
    required String targetUserId,
  }) =>
      _passesRef(currentUserId).doc(targetUserId).set({
        'passedUserId': targetUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<Set<String>> loadPassedUserIds(String currentUserId) async {
    final snapshot = await _passesRef(currentUserId).get();
    return snapshot.docs.map((d) => d.id).toSet();
  }
}
