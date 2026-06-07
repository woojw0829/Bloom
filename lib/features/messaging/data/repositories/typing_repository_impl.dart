import 'package:firebase_database/firebase_database.dart';

import '../../domain/repositories/typing_repository.dart';

class TypingRepositoryImpl implements TypingRepository {
  TypingRepositoryImpl() : _database = FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  @override
  Future<void> setTyping({
    required String matchId,
    required String userId,
    required bool isTyping,
  }) async {
    final ref = _database.ref('typing/$matchId/$userId');
    if (isTyping) {
      await ref.set(true);
    } else {
      await ref.remove();
    }
  }

  @override
  Stream<Set<String>> watchTypingUserIds({required String matchId}) {
    return _database
        .ref('typing/$matchId')
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data == null) return const <String>{};
          if (data is! Map) return const <String>{};
          final result = <String>{};
          data.forEach((key, value) {
            if (value == true && key != null) {
              result.add(key.toString());
            }
          });
          return result;
        })
        .handleError((Object _) {});
  }
}
