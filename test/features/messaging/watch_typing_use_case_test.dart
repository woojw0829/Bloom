import 'package:bloom/features/messaging/domain/repositories/typing_repository.dart';
import 'package:bloom/features/messaging/domain/usecases/watch_typing_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements TypingRepository {
  Stream<Set<String>> Function(String matchId) watchImpl =
      (_) => Stream.value(const {});

  @override
  Future<void> setTyping({
    required String matchId,
    required String userId,
    required bool isTyping,
  }) async {}

  @override
  Stream<Set<String>> watchTypingUserIds({required String matchId}) =>
      watchImpl(matchId);
}

void main() {
  late _FakeRepo repo;
  late WatchTypingUseCase useCase;

  setUp(() {
    repo = _FakeRepo();
    useCase = WatchTypingUseCase(repo);
  });

  group('WatchTypingUseCase', () {
    test('returns false immediately for empty matchId', () async {
      final result = await useCase
          .execute(matchId: '', currentUserId: 'user1')
          .first;
      expect(result, false);
    });

    test('returns false immediately for whitespace matchId', () async {
      final result = await useCase
          .execute(matchId: '   ', currentUserId: 'user1')
          .first;
      expect(result, false);
    });

    test('returns false immediately for empty currentUserId', () async {
      final result = await useCase
          .execute(matchId: 'match1', currentUserId: '')
          .first;
      expect(result, false);
    });

    test('returns false when no one is typing', () async {
      repo.watchImpl = (_) => Stream.value(const {});
      final result = await useCase
          .execute(matchId: 'match1', currentUserId: 'user1')
          .first;
      expect(result, false);
    });

    test('returns false when only current user is typing', () async {
      repo.watchImpl = (_) => Stream.value({'user1'});
      final result = await useCase
          .execute(matchId: 'match1', currentUserId: 'user1')
          .first;
      expect(result, false);
    });

    test('returns true when another user is typing', () async {
      repo.watchImpl = (_) => Stream.value({'userB'});
      final result = await useCase
          .execute(matchId: 'match1', currentUserId: 'user1')
          .first;
      expect(result, true);
    });

    test('returns true when both current user and other user are typing',
        () async {
      repo.watchImpl = (_) => Stream.value({'user1', 'userB'});
      final result = await useCase
          .execute(matchId: 'match1', currentUserId: 'user1')
          .first;
      expect(result, true);
    });

    test('filters out current user — only counts others', () async {
      repo.watchImpl = (_) => Stream.fromIterable([
            {'user1'},
            {'user1', 'userB'},
          ]);
      final results = await useCase
          .execute(matchId: 'match1', currentUserId: 'user1')
          .take(2)
          .toList();
      expect(results, [false, true]);
    });

    test('repository errors are swallowed — stream closes without emitting error',
        () async {
      repo.watchImpl = (_) => Stream.error(Exception('RTDB error'));
      await expectLater(
        useCase.execute(matchId: 'match1', currentUserId: 'user1'),
        emitsDone,
      );
    });
  });
}
