import 'package:bloom/features/messaging/domain/models/chat_message.dart';
import 'package:bloom/features/messaging/domain/repositories/message_repository.dart';
import 'package:bloom/features/messaging/domain/usecases/send_image_message_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements MessageRepository {
  bool shouldThrow = false;
  String? lastMatchId;
  String? lastSenderId;
  String? lastImageFilePath;

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
  }) async {}

  @override
  Future<void> sendImageMessage({
    required String matchId,
    required String senderId,
    required String imageFilePath,
  }) async {
    lastMatchId = matchId;
    lastSenderId = senderId;
    lastImageFilePath = imageFilePath;
    if (shouldThrow) throw Exception('upload error');
  }

  @override
  Future<void> markMessagesAsRead({
    required String matchId,
    required String currentUserId,
    required List<String> messageIds,
  }) async {}
}

void main() {
  late _FakeRepo repo;
  late SendImageMessageUseCase useCase;

  setUp(() {
    repo = _FakeRepo();
    useCase = SendImageMessageUseCase(repo);
  });

  group('SendImageMessageUseCase', () {
    test('rejects empty matchId', () async {
      final result = await useCase.execute(
        matchId: '',
        senderId: 'user1',
        imageFilePath: '/tmp/photo.jpg',
      );
      expect(result, isA<SendImageMessageValidationError>());
    });

    test('rejects whitespace-only matchId', () async {
      final result = await useCase.execute(
        matchId: '   ',
        senderId: 'user1',
        imageFilePath: '/tmp/photo.jpg',
      );
      expect(result, isA<SendImageMessageValidationError>());
    });

    test('rejects empty senderId', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: '',
        imageFilePath: '/tmp/photo.jpg',
      );
      expect(result, isA<SendImageMessageValidationError>());
    });

    test('rejects empty imageFilePath', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        imageFilePath: '',
      );
      expect(result, isA<SendImageMessageValidationError>());
    });

    test('rejects whitespace-only imageFilePath', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        imageFilePath: '   ',
      );
      expect(result, isA<SendImageMessageValidationError>());
    });

    test('returns success for valid input', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        imageFilePath: '/tmp/photo.jpg',
      );
      expect(result, isA<SendImageMessageSuccess>());
    });

    test('passes correct matchId and senderId to repository', () async {
      await useCase.execute(
        matchId: 'match99',
        senderId: 'userABC',
        imageFilePath: '/tmp/photo.jpg',
      );
      expect(repo.lastMatchId, 'match99');
      expect(repo.lastSenderId, 'userABC');
    });

    test('passes imageFilePath to repository unchanged', () async {
      await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        imageFilePath: '/storage/emulated/0/photo.jpg',
      );
      expect(repo.lastImageFilePath, '/storage/emulated/0/photo.jpg');
    });

    test('returns failure when repository throws', () async {
      repo.shouldThrow = true;
      final result = await useCase.execute(
        matchId: 'match1',
        senderId: 'user1',
        imageFilePath: '/tmp/photo.jpg',
      );
      expect(result, isA<SendImageMessageFailure>());
    });
  });
}
