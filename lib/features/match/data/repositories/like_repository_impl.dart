import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/like_record.dart';
import '../../domain/repositories/like_repository.dart';

class LikeRepositoryImpl implements LikeRepository {
  LikeRepositoryImpl();

  // Lazy getter — avoids calling FirebaseFirestore.instance at construction
  // time, keeping unit tests that don't initialise Firebase from crashing.
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<void> recordLike({
    required String fromUserId,
    required String toUserId,
    required LikeType type,
  }) {
    final id = makeLikeId(fromUserId, toUserId);
    return _firestore.collection('likes').doc(id).set({
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'type': type.firestoreValue,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Set<String>> loadSentLikedUserIds(String fromUserId) async {
    final snapshot = await _firestore
        .collection('likes')
        .where('fromUserId', isEqualTo: fromUserId)
        .get();
    return snapshot.docs
        .map((d) => d.data()['toUserId'] as String)
        .toSet();
  }
}
