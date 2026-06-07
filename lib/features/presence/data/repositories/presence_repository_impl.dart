import 'package:firebase_database/firebase_database.dart';

import '../../domain/repositories/presence_repository.dart';

class PresenceRepositoryImpl implements PresenceRepository {
  PresenceRepositoryImpl();

  // Lazy getter — FirebaseDatabase.instance is resolved at call time, not at
  // construction time, so this repository can be created before Firebase.initializeApp().
  FirebaseDatabase get _database => FirebaseDatabase.instance;

  DatabaseReference _ref(String userId) => _database.ref('status/$userId');

  @override
  Future<void> setOnline(String userId) async {
    await _ref(userId).set({
      'isOnline': true,
      'lastSeen': ServerValue.timestamp,
    });
  }

  @override
  Future<void> setOffline(String userId) async {
    await _ref(userId).set({
      'isOnline': false,
      'lastSeen': ServerValue.timestamp,
    });
  }

  @override
  Future<void> setupOnDisconnect(String userId) async {
    await _ref(userId).onDisconnect().set({
      'isOnline': false,
      'lastSeen': ServerValue.timestamp,
    });
  }

  @override
  Future<void> cancelOnDisconnect(String userId) async {
    await _ref(userId).onDisconnect().cancel();
  }
}
