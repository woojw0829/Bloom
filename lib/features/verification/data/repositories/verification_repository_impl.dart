import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/models/verification_request.dart';
import '../../domain/repositories/verification_repository.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  VerificationRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const String _collection = 'verification_requests';

  @override
  Future<void> submitPhotoVerification({
    required String userId,
    required File selfieFile,
  }) async {
    // Generate the document ID first so it can be embedded in the Storage path.
    final docRef = _firestore.collection(_collection).doc();
    final requestId = docRef.id;

    // Storage path encodes userId and requestId — never use getDownloadURL().
    final storagePath =
        'verification_requests/$userId/$requestId/selfie.jpg';

    final storageRef = _storage.ref().child(storagePath);
    await storageRef.putFile(
      selfieFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    await docRef.set({
      'id': requestId,
      'userId': userId,
      'verificationType': VerificationType.photo.firestoreValue,
      'selfieImageUrl': storagePath,
      'status': VerificationRequestStatus.pending.firestoreValue,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<VerificationRequest?> watchLatestPhotoVerificationRequest({
    required String userId,
  }) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where(
          'verificationType',
          isEqualTo: VerificationType.photo.firestoreValue,
        )
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map(
          (snap) => snap.docs.isEmpty
              ? null
              : VerificationRequest.fromFirestore(
                  snap.docs.first.id,
                  snap.docs.first.data(),
                ),
        );
  }

  @override
  Stream<List<VerificationRequest>> watchPendingPhotoVerificationRequests() {
    return _firestore
        .collection(_collection)
        .where(
          'verificationType',
          isEqualTo: VerificationType.photo.firestoreValue,
        )
        .where(
          'status',
          isEqualTo: VerificationRequestStatus.pending.firestoreValue,
        )
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) =>
                  VerificationRequest.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> approvePhotoVerificationRequest({
    required String requestId,
    required String userId,
    required String reviewerId,
  }) async {
    await _firestore.collection(_collection).doc(requestId).update({
      'status': VerificationRequestStatus.approved.firestoreValue,
      'reviewerId': reviewerId,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rejectPhotoVerificationRequest({
    required String requestId,
    required String reviewerId,
    required String rejectionReason,
  }) async {
    await _firestore.collection(_collection).doc(requestId).update({
      'status': VerificationRequestStatus.rejected.firestoreValue,
      'reviewerId': reviewerId,
      'rejectionReason': rejectionReason,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
