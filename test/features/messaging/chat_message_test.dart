import 'package:bloom/features/messaging/domain/models/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage.fromFirestore', () {
    test('maps id and senderId', () {
      final msg = ChatMessage.fromFirestore('msg1', {
        'senderId': 'user1',
        'type': 'text',
        'content': 'Hello',
        'readBy': ['user1'],
        'deleted': false,
      });
      expect(msg.id, 'msg1');
      expect(msg.senderId, 'user1');
    });

    test('maps text type', () {
      final msg = ChatMessage.fromFirestore('m1', {
        'senderId': 'u1',
        'type': 'text',
        'content': '',
        'readBy': <String>[],
        'deleted': false,
      });
      expect(msg.type, MessageType.text);
    });

    test('maps image type', () {
      final msg = ChatMessage.fromFirestore('m1', {
        'senderId': 'u1',
        'type': 'image',
        'content': '',
        'readBy': <String>[],
        'deleted': false,
      });
      expect(msg.type, MessageType.image);
    });

    test('falls back to text for unknown type string', () {
      final msg = ChatMessage.fromFirestore('m1', {
        'senderId': 'u1',
        'type': 'voice',
        'content': '',
        'readBy': <String>[],
        'deleted': false,
      });
      expect(msg.type, MessageType.text);
    });

    test('falls back to text when type is missing', () {
      final msg = ChatMessage.fromFirestore('m1', {
        'senderId': 'u1',
        'content': '',
        'readBy': <String>[],
        'deleted': false,
      });
      expect(msg.type, MessageType.text);
    });

    test('maps content', () {
      final msg = ChatMessage.fromFirestore('m1', {
        'senderId': 'u1',
        'type': 'text',
        'content': 'Hi there',
        'readBy': ['u1'],
        'deleted': false,
      });
      expect(msg.content, 'Hi there');
    });

    test('maps readBy list', () {
      final msg = ChatMessage.fromFirestore('m1', {
        'senderId': 'u1',
        'type': 'text',
        'content': '',
        'readBy': ['u1', 'u2'],
        'deleted': false,
      });
      expect(msg.readBy, ['u1', 'u2']);
    });

    test('maps deleted true', () {
      final msg = ChatMessage.fromFirestore('m1', {
        'senderId': 'u1',
        'type': 'text',
        'content': '',
        'readBy': <String>[],
        'deleted': true,
      });
      expect(msg.deleted, true);
    });

    test('imageUrl is null when not provided', () {
      final msg = ChatMessage.fromFirestore('m1', {
        'senderId': 'u1',
        'type': 'text',
        'content': '',
        'readBy': <String>[],
        'deleted': false,
      });
      expect(msg.imageUrl, isNull);
    });

    test('handles null createdAt', () {
      final msg = ChatMessage.fromFirestore('m1', {
        'senderId': 'u1',
        'type': 'text',
        'content': '',
        'readBy': <String>[],
        'deleted': false,
        'createdAt': null,
      });
      expect(msg.createdAt, isNull);
    });
  });
}
