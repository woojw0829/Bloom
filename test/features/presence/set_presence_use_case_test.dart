import 'package:bloom/features/presence/domain/repositories/presence_repository.dart';
import 'package:bloom/features/presence/domain/usecases/set_presence_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements PresenceRepository {
  String? lastOnlineUserId;
  String? lastOfflineUserId;
  String? lastOnDisconnectUserId;
  String? lastCancelOnDisconnectUserId;
  bool shouldThrow = false;

  @override
  Future<void> setOnline(String userId) async {
    lastOnlineUserId = userId;
    if (shouldThrow) throw Exception('RTDB error');
  }

  @override
  Future<void> setOffline(String userId) async {
    lastOfflineUserId = userId;
    if (shouldThrow) throw Exception('RTDB error');
  }

  @override
  Future<void> setupOnDisconnect(String userId) async {
    lastOnDisconnectUserId = userId;
    if (shouldThrow) throw Exception('RTDB error');
  }

  @override
  Future<void> cancelOnDisconnect(String userId) async {
    lastCancelOnDisconnectUserId = userId;
    if (shouldThrow) throw Exception('RTDB error');
  }
}

void main() {
  late _FakeRepo repo;
  late SetPresenceUseCase useCase;

  setUp(() {
    repo = _FakeRepo();
    useCase = SetPresenceUseCase(repo);
  });

  group('SetPresenceUseCase.setOnline', () {
    test('rejects empty userId — no repo call', () async {
      await useCase.setOnline('');
      expect(repo.lastOnlineUserId, isNull);
    });

    test('rejects whitespace-only userId', () async {
      await useCase.setOnline('   ');
      expect(repo.lastOnlineUserId, isNull);
    });

    test('calls repository setOnline for valid userId', () async {
      await useCase.setOnline('user1');
      expect(repo.lastOnlineUserId, 'user1');
    });

    test('swallows repository error — does not throw', () async {
      repo.shouldThrow = true;
      await expectLater(useCase.setOnline('user1'), completes);
    });
  });

  group('SetPresenceUseCase.setOffline', () {
    test('rejects empty userId — no repo call', () async {
      await useCase.setOffline('');
      expect(repo.lastOfflineUserId, isNull);
    });

    test('rejects whitespace-only userId', () async {
      await useCase.setOffline('   ');
      expect(repo.lastOfflineUserId, isNull);
    });

    test('calls repository setOffline for valid userId', () async {
      await useCase.setOffline('user1');
      expect(repo.lastOfflineUserId, 'user1');
    });

    test('swallows repository error — does not throw', () async {
      repo.shouldThrow = true;
      await expectLater(useCase.setOffline('user1'), completes);
    });
  });

  group('SetPresenceUseCase.setupOnDisconnect', () {
    test('rejects empty userId — no repo call', () async {
      await useCase.setupOnDisconnect('');
      expect(repo.lastOnDisconnectUserId, isNull);
    });

    test('rejects whitespace-only userId', () async {
      await useCase.setupOnDisconnect('   ');
      expect(repo.lastOnDisconnectUserId, isNull);
    });

    test('calls repository setupOnDisconnect for valid userId', () async {
      await useCase.setupOnDisconnect('user1');
      expect(repo.lastOnDisconnectUserId, 'user1');
    });

    test('swallows repository error — does not throw', () async {
      repo.shouldThrow = true;
      await expectLater(useCase.setupOnDisconnect('user1'), completes);
    });
  });

  group('SetPresenceUseCase.cancelOnDisconnect', () {
    test('rejects empty userId — no repo call', () async {
      await useCase.cancelOnDisconnect('');
      expect(repo.lastCancelOnDisconnectUserId, isNull);
    });

    test('rejects whitespace-only userId', () async {
      await useCase.cancelOnDisconnect('   ');
      expect(repo.lastCancelOnDisconnectUserId, isNull);
    });

    test('calls repository cancelOnDisconnect for valid userId', () async {
      await useCase.cancelOnDisconnect('user1');
      expect(repo.lastCancelOnDisconnectUserId, 'user1');
    });

    test('swallows repository error — does not throw', () async {
      repo.shouldThrow = true;
      await expectLater(useCase.cancelOnDisconnect('user1'), completes);
    });
  });
}
