import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/blocked_user.dart';
import '../../domain/repositories/block_repository.dart';

class BlockRepositoryImpl implements BlockRepository {
  BlockRepositoryImpl() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _blocksRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('blocks');

  @override
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _blocksRef(currentUserId).doc(blockedUserId).set({
      'blockedUserId': blockedUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> isBlocked({
    required String currentUserId,
    required String targetUserId,
  }) async {
    final doc = await _blocksRef(currentUserId).doc(targetUserId).get();
    return doc.exists;
  }

  @override
  Stream<Set<String>> watchBlockedUserIds({
    required String currentUserId,
  }) {
    if (currentUserId.isEmpty) return Stream.value(const {});
    return _blocksRef(currentUserId).snapshots().map(
          (snap) => snap.docs.map((doc) => doc.id).toSet(),
        );
  }

  @override
  Future<List<BlockedUser>> fetchBlockedUsers({
    required String currentUserId,
  }) async {
    if (currentUserId.isEmpty) return [];
    final snap = await _blocksRef(currentUserId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((doc) => BlockedUser.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _blocksRef(currentUserId).doc(blockedUserId).delete();
  }
}
