import 'package:bloom/features/messaging/domain/models/chat_message.dart';
import 'package:bloom/features/messaging/domain/repositories/message_repository.dart';
import 'package:bloom/features/messaging/domain/usecases/send_text_message_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements MessageRepository {
  bool shouldThrow = false;
  String? lastMatchId;
  String? lastSenderId;
  String? lastContent;

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String matchId,
    int limit = 50,
  }) =>
      const Stream.empty();

  @override
  Future<void> sendTextMessage({
    required String matchId,
    required String senderId,
    required String content,
  }) async {
    lastMatchId = matchId;
    lastSenderId = senderId;
    lastContent = content;
    if (shouldThrow) throw Exception('test error');
  }

  @override
  Future<void> sendImageMessage({
    required String matchId,
    required String senderId,
    required String imageFilePath,
  }) async {}

  @override
  Future<void> markMessagesAsRead({
    required String matchId,
    required String currentUserId,
    required List<String> messageIds,
  }) async {}
}

void main() {
  late _FakeRepo repo;
  late SendTextMessageUseCase useCase;

  setUp(() {
    repo = _FakeRepo();
    useCase = SendTextMessageUseCase(repo);
  });

  group('SendTextMessageUseCase', () {
    test('rejects empty matchId', () async {
      final result = await useCase.execute(
        matchId: '',
        senderId: 'user1',
        content: 'Hello',
      );
      expect(result, isA<SendTextMessageValidationError>());
    });

    test('rejects whitespace-only matchId', () async {
      final result = await useCase.execute(
        matchId: '   ',
        senderId: 'user1',
        content: 'Hello',
      );
      expect(result, isA<SendTextMessageValidationError>());
    });

    test('rejects empty senderId', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: '',
        content: 'Hello',
      );
      expect(result, isA<SendTextMessageValidationError>());
    });

    test('rejects blank content', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        content: '',
      );
      expect(result, isA<SendTextMessageValidationError>());
    });

    test('rejects whitespace-only content', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        content: '   ',
      );
      expect(result, isA<SendTextMessageValidationError>());
    });

    test('rejects content over max length', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        content: 'a' * (kMaxMessageLength + 1),
      );
      expect(result, isA<SendTextMessageValidationError>());
    });

    test('accepts content exactly at max length', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        content: 'a' * kMaxMessageLength,
      );
      expect(result, isA<SendTextMessageSuccess>());
    });

    test('trims content before sending', () async {
      await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        content: '  Hello world  ',
      );
      expect(repo.lastContent, 'Hello world');
    });

    test('returns success for valid input', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        content: 'Hello',
      );
      expect(result, isA<SendTextMessageSuccess>());
    });

    test('passes correct matchId and senderId to repository', () async {
      await useCase.execute(
        matchId: 'match99',
        senderId: 'userABC',
        content: 'Hi',
      );
      expect(repo.lastMatchId, 'match99');
      expect(repo.lastSenderId, 'userABC');
    });

    test('returns failure when repository throws', () async {
      repo.shouldThrow = true;
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        content: 'Hello',
      );
      expect(result, isA<SendTextMessageFailure>());
    });
  });
}
