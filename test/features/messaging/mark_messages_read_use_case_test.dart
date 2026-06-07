import 'package:bloom/features/messaging/domain/models/chat_message.dart';
import 'package:bloom/features/messaging/domain/repositories/message_repository.dart';
import 'package:bloom/features/messaging/domain/usecases/mark_messages_read_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements MessageRepository {
  String? lastMatchId;
  String? lastCurrentUserId;
  List<String>? lastMessageIds;
  bool shouldThrow = false;

  @override
  Future<void> markMessagesAsRead({
    required String matchId,
    required String currentUserId,
    required List<String> messageIds,
  }) async {
    lastMatchId = matchId;
    lastCurrentUserId = currentUserId;
    lastMessageIds = messageIds;
    if (shouldThrow) throw Exception('Firestore error');
  }

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
  }) async {}
}

void main() {
  late _FakeRepo repo;
  late MarkMessagesReadUseCase useCase;

  setUp(() {
    repo = _FakeRepo();
    useCase = MarkMessagesReadUseCase(repo);
  });

  group('MarkMessagesReadUseCase', () {
    test('rejects empty matchId — does not call repository', () async {
      await useCase.execute(
          matchId: '', currentUserId: 'user1', messageIds: ['m1']);
      expect(repo.lastMatchId, isNull);
    });

    test('rejects whitespace-only matchId', () async {
      await useCase.execute(
          matchId: '   ', currentUserId: 'user1', messageIds: ['m1']);
      expect(repo.lastMatchId, isNull);
    });

    test('rejects empty currentUserId', () async {
      await useCase.execute(
          matchId: 'match1', currentUserId: '', messageIds: ['m1']);
      expect(repo.lastCurrentUserId, isNull);
    });

    test('rejects whitespace-only currentUserId', () async {
      await useCase.execute(
          matchId: 'match1', currentUserId: '   ', messageIds: ['m1']);
      expect(repo.lastCurrentUserId, isNull);
    });

    test('ignores empty messageIds — does not call repository', () async {
      await useCase.execute(
          matchId: 'match1', currentUserId: 'user1', messageIds: []);
      expect(repo.lastMatchId, isNull);
    });

    test('deduplicates messageIds before calling repository', () async {
      await useCase.execute(
        matchId: 'match1',
        currentUserId: 'user1',
        messageIds: ['m1', 'm2', 'm1', 'm2'],
      );
      expect(repo.lastMessageIds!.toSet(), {'m1', 'm2'});
      expect(repo.lastMessageIds!.length, 2);
    });

    test('calls repository with correct matchId and currentUserId', () async {
      await useCase.execute(
        matchId: 'matchXYZ',
        currentUserId: 'userABC',
        messageIds: ['m1'],
      );
      expect(repo.lastMatchId, 'matchXYZ');
      expect(repo.lastCurrentUserId, 'userABC');
    });

    test('calls repository with provided messageIds', () async {
      await useCase.execute(
        matchId: 'match1',
        currentUserId: 'user1',
        messageIds: ['m1', 'm2', 'm3'],
      );
      expect(repo.lastMessageIds, containsAll(['m1', 'm2', 'm3']));
    });

    test('swallows repository error — does not throw', () async {
      repo.shouldThrow = true;
      await expectLater(
        useCase.execute(
            matchId: 'match1', currentUserId: 'user1', messageIds: ['m1']),
        completes,
      );
    });
  });
}
