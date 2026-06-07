import 'package:bloom/features/notifications/domain/repositories/fcm_token_repository.dart';
import 'package:bloom/features/notifications/domain/usecases/clear_fcm_token_use_case.dart';
import 'package:bloom/features/notifications/domain/usecases/register_fcm_token_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements FcmTokenRepository {
  String? lastSavedUserId;
  String? lastSavedToken;
  String? lastClearedUserId;
  bool shouldThrow = false;

  @override
  Future<void> requestPermission() async {}

  @override
  Future<String?> getToken() async => 'fake_token';

  @override
  Stream<String> watchTokenRefresh() => const Stream.empty();

  @override
  Future<void> saveToken(String userId, String token) async {
    lastSavedUserId = userId;
    lastSavedToken = token;
    if (shouldThrow) throw Exception('Firestore error');
  }

  @override
  Future<void> clearToken(String userId) async {
    lastClearedUserId = userId;
    if (shouldThrow) throw Exception('Firestore error');
  }
}

void main() {
  late _FakeRepo repo;
  late RegisterFcmTokenUseCase registerUseCase;
  late ClearFcmTokenUseCase clearUseCase;

  setUp(() {
    repo = _FakeRepo();
    registerUseCase = RegisterFcmTokenUseCase(repo);
    clearUseCase = ClearFcmTokenUseCase(repo);
  });

  group('RegisterFcmTokenUseCase', () {
    test('rejects empty userId — no repo call', () async {
      await registerUseCase.execute(userId: '', token: 'token123');
      expect(repo.lastSavedUserId, isNull);
    });

    test('rejects whitespace-only userId', () async {
      await registerUseCase.execute(userId: '   ', token: 'token123');
      expect(repo.lastSavedUserId, isNull);
    });

    test('ignores empty token — no repo call', () async {
      await registerUseCase.execute(userId: 'user1', token: '');
      expect(repo.lastSavedUserId, isNull);
    });

    test('ignores whitespace-only token', () async {
      await registerUseCase.execute(userId: 'user1', token: '   ');
      expect(repo.lastSavedUserId, isNull);
    });

    test('saves valid userId and token', () async {
      await registerUseCase.execute(userId: 'user1', token: 'token_abc');
      expect(repo.lastSavedUserId, 'user1');
      expect(repo.lastSavedToken, 'token_abc');
    });

    test('swallows repository error — does not throw', () async {
      repo.shouldThrow = true;
      await expectLater(
        registerUseCase.execute(userId: 'user1', token: 'token_abc'),
        completes,
      );
    });
  });

  group('ClearFcmTokenUseCase', () {
    test('rejects empty userId — no repo call', () async {
      await clearUseCase.execute(userId: '');
      expect(repo.lastClearedUserId, isNull);
    });

    test('rejects whitespace-only userId', () async {
      await clearUseCase.execute(userId: '   ');
      expect(repo.lastClearedUserId, isNull);
    });

    test('calls repository clearToken for valid userId', () async {
      await clearUseCase.execute(userId: 'user1');
      expect(repo.lastClearedUserId, 'user1');
    });

    test('swallows repository error — does not throw', () async {
      repo.shouldThrow = true;
      await expectLater(clearUseCase.execute(userId: 'user1'), completes);
    });
  });
}
