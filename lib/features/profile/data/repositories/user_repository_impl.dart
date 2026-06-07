import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const Uuid _uuid = Uuid();

  // ── Profile CRUD ──────────────────────────────────────────────────────────

  @override
  Future<void> createUserProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson());
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromJson(doc.data()!);
  }

  @override
  Stream<UserModel?> watchUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) =>
            doc.exists && doc.data() != null
                ? UserModel.fromJson(doc.data()!)
                : null);
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .update(user.toJson());
  }

  // ── Profile existence check (reactive) ───────────────────────────────────

  @override
  Stream<bool> watchProfileExists(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ── Photo upload ──────────────────────────────────────────────────────────

  @override
  Future<List<String>> uploadProfilePhotos({
    required String userId,
    required List<String> photoPaths,
  }) async {
    final futures = photoPaths.map((path) async {
      final file = File(path);
      final photoId = _uuid.v4();
      final ref = _storage.ref().child('users/$userId/photos/$photoId');

      final snapshot = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return snapshot.ref.getDownloadURL();
    });

    return Future.wait(futures);
  }

  // ── Photo deletion ────────────────────────────────────────────────────────

  @override
  Future<void> deleteProfilePhoto({
    required String userId,
    required String photoUrl,
  }) async {
    try {
      await _storage.refFromURL(photoUrl).delete();
    } catch (_) {
      // Best-effort: Firestore is updated by the caller before this runs.
      // A Storage failure leaves an orphaned file but does not affect the
      // user's visible photo list.
    }
  }
}
