import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/match_record.dart';
import '../../domain/repositories/match_repository.dart';

class MatchRepositoryImpl implements MatchRepository {
  MatchRepositoryImpl() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> unmatch({
    required String matchId,
    required String currentUserId,
  }) async {
    await _firestore.collection('matches').doc(matchId).update({
      'active': false,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessagePreview': '',
    });
  }

  @override
  Stream<List<MatchRecord>> watchActiveMatches(String currentUserId) {
    if (currentUserId.isEmpty) return Stream.value(const []);
    return _firestore
        .collection('matches')
        .where('users', arrayContains: currentUserId)
        .where('active', isEqualTo: true)
        .orderBy('lastMessageAt', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => MatchRecord.fromFirestore(doc.data()))
              .toList(),
        );
  }
}
