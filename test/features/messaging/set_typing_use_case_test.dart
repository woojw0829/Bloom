import 'package:bloom/features/messaging/domain/repositories/typing_repository.dart';
import 'package:bloom/features/messaging/domain/usecases/set_typing_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements TypingRepository {
  String? lastMatchId;
  String? lastUserId;
  bool? lastIsTyping;
  bool shouldThrow = false;

  @override
  Future<void> setTyping({
    required String matchId,
    required String userId,
    required bool isTyping,
  }) async {
    lastMatchId = matchId;
    lastUserId = userId;
    lastIsTyping = isTyping;
    if (shouldThrow) throw Exception('RTDB error');
  }

  @override
  Stream<Set<String>> watchTypingUserIds({required String matchId}) =>
      const Stream.empty();
}

void main() {
  late _FakeRepo repo;
  late SetTypingUseCase useCase;

  setUp(() {
    repo = _FakeRepo();
    useCase = SetTypingUseCase(repo);
  });

  group('SetTypingUseCase', () {
    test('rejects empty matchId — does not call repository', () async {
      await useCase.execute(matchId: '', userId: 'user1', isTyping: true);
      expect(repo.lastMatchId, isNull);
    });

    test('rejects whitespace-only matchId', () async {
      await useCase.execute(matchId: '   ', userId: 'user1', isTyping: true);
      expect(repo.lastMatchId, isNull);
    });

    test('rejects empty userId', () async {
      await useCase.execute(matchId: 'match1', userId: '', isTyping: true);
      expect(repo.lastUserId, isNull);
    });

    test('rejects whitespace-only userId', () async {
      await useCase.execute(matchId: 'match1', userId: '   ', isTyping: true);
      expect(repo.lastUserId, isNull);
    });

    test('calls repository with isTyping=true for valid input', () async {
      await useCase.execute(
          matchId: 'match1', userId: 'user1', isTyping: true);
      expect(repo.lastIsTyping, true);
    });

    test('calls repository with isTyping=false for valid input', () async {
      await useCase.execute(
          matchId: 'match1', userId: 'user1', isTyping: false);
      expect(repo.lastIsTyping, false);
    });

    test('passes correct matchId and userId to repository', () async {
      await useCase.execute(
          matchId: 'matchXYZ', userId: 'userABC', isTyping: true);
      expect(repo.lastMatchId, 'matchXYZ');
      expect(repo.lastUserId, 'userABC');
    });

    test('swallows repository error — does not throw', () async {
      repo.shouldThrow = true;
      await expectLater(
        useCase.execute(matchId: 'match1', userId: 'user1', isTyping: true),
        completes,
      );
    });
  });
}
