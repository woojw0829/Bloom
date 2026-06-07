import 'package:bloom/features/messaging/domain/models/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

ChatMessage _msg({
  String id = 'm1',
  String senderId = 'userA',
  List<String> readBy = const [],
  bool deleted = false,
}) =>
    ChatMessage(
      id: id,
      senderId: senderId,
      type: MessageType.text,
      content: 'hi',
      readBy: readBy,
      deleted: deleted,
    );

void main() {
  group('ChatMessage.isReadBy', () {
    test('returns true when userId is in readBy', () {
      final msg = _msg(readBy: ['userA', 'userB']);
      expect(msg.isReadBy('userB'), true);
    });

    test('returns false when userId is not in readBy', () {
      final msg = _msg(readBy: ['userA']);
      expect(msg.isReadBy('userB'), false);
    });

    test('returns false when readBy is empty', () {
      final msg = _msg(readBy: []);
      expect(msg.isReadBy('userA'), false);
    });
  });

  group('ChatMessage.isReadByOtherParticipant', () {
    test('returns true when another user is in readBy', () {
      final msg = _msg(readBy: ['userA', 'userB']);
      expect(msg.isReadByOtherParticipant('userA'), true);
    });

    test('returns false when only current user is in readBy', () {
      final msg = _msg(readBy: ['userA']);
      expect(msg.isReadByOtherParticipant('userA'), false);
    });

    test('returns false when readBy is empty', () {
      final msg = _msg(readBy: []);
      expect(msg.isReadByOtherParticipant('userA'), false);
    });
  });

  group('ChatMessage.shouldMarkRead', () {
    test('returns true for incoming unread message', () {
      final msg = _msg(senderId: 'userA', readBy: ['userA']);
      expect(msg.shouldMarkRead('userB'), true);
    });

    test('returns false for outgoing message (senderId == currentUserId)', () {
      final msg = _msg(senderId: 'userA', readBy: ['userA']);
      expect(msg.shouldMarkRead('userA'), false);
    });

    test('returns false when already read by currentUserId', () {
      final msg = _msg(senderId: 'userA', readBy: ['userA', 'userB']);
      expect(msg.shouldMarkRead('userB'), false);
    });

    test('returns false for deleted message', () {
      final msg = _msg(senderId: 'userA', readBy: ['userA'], deleted: true);
      expect(msg.shouldMarkRead('userB'), false);
    });

    test('returns false when currentUserId is empty', () {
      final msg = _msg(senderId: 'userA', readBy: ['userA']);
      expect(msg.shouldMarkRead(''), false);
    });
  });
}
