import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/models/chat_message.dart';
import '../../domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl()
      : _firestore = FirebaseFirestore.instance,
        _storage = FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String matchId,
    int limit = 50,
  }) {
    if (matchId.isEmpty) return Stream.value(const []);
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .orderBy('createdAt')
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ChatMessage.fromFirestore(doc.id, doc.data()))
              .where((msg) => !msg.deleted)
              .toList(),
        );
  }

  @override
  Future<void> sendTextMessage({
    required String matchId,
    required String senderId,
    required String content,
  }) async {
    final batch = _firestore.batch();

    final msgRef = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .doc();

    batch.set(msgRef, {
      'id': msgRef.id,
      'senderId': senderId,
      'type': 'text',
      'content': content,
      'readBy': [senderId],
      'deleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(
      _firestore.collection('matches').doc(matchId),
      {
        'lastMessagePreview': content,
        'lastMessageAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }

  @override
  Future<void> sendImageMessage({
    required String matchId,
    required String senderId,
    required String imageFilePath,
  }) async {
    final msgRef = _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .doc();

    final storageRef = _storage.ref().child('chats/$matchId/${msgRef.id}');
    final snapshot = await storageRef.putFile(
      File(imageFilePath),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final imageUrl = await snapshot.ref.getDownloadURL();

    final batch = _firestore.batch();
    batch.set(msgRef, {
      'id': msgRef.id,
      'senderId': senderId,
      'type': 'image',
      'content': '',
      'imageUrl': imageUrl,
      'readBy': [senderId],
      'deleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(
      _firestore.collection('matches').doc(matchId),
      {
        'lastMessagePreview': '📷',
        'lastMessageAt': FieldValue.serverTimestamp(),
      },
    );
    await batch.commit();
  }

  @override
  Future<void> markMessagesAsRead({
    required String matchId,
    required String currentUserId,
    required List<String> messageIds,
  }) async {
    if (messageIds.isEmpty) return;
    final batch = _firestore.batch();
    for (final id in messageIds) {
      final ref = _firestore
          .collection('matches')
          .doc(matchId)
          .collection('messages')
          .doc(id);
      batch.update(ref, {'readBy': FieldValue.arrayUnion([currentUserId])});
    }
    await batch.commit();
  }
}
