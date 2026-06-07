import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/repositories/fcm_token_repository.dart';

class FcmTokenRepositoryImpl implements FcmTokenRepository {
  FcmTokenRepositoryImpl();

  // Lazy getters — Firebase instances resolved at call time, not construction
  // time, so this repository can be created before Firebase.initializeApp().
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // Permission denial is not an error — callers check getToken() result.
  }

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Stream<String> watchTokenRefresh() => _messaging.onTokenRefresh;

  DocumentReference<Map<String, dynamic>> _tokenRef(String userId) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('private')
          .doc('notificationTokens');

  @override
  Future<void> saveToken(String userId, String token) async {
    await _tokenRef(userId).set(
      {
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> clearToken(String userId) async {
    await _tokenRef(userId).set(
      {
        'fcmToken': '',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
