import 'package:bloom/features/notifications/domain/models/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── NotificationType ────────────────────────────────────────────────────────

  group('NotificationType.fromString', () {
    test('parses match', () {
      expect(NotificationType.fromString('match'), NotificationType.match);
    });

    test('parses message', () {
      expect(NotificationType.fromString('message'), NotificationType.message);
    });

    test('parses like', () {
      expect(NotificationType.fromString('like'), NotificationType.like);
    });

    test('parses verification', () {
      expect(
        NotificationType.fromString('verification'),
        NotificationType.verification,
      );
    });

    test('unknown value falls back to match', () {
      expect(NotificationType.fromString('unknown'), NotificationType.match);
    });

    test('null falls back to match', () {
      expect(NotificationType.fromString(null), NotificationType.match);
    });
  });

  // ── NotificationReferenceType ───────────────────────────────────────────────

  group('NotificationReferenceType.fromString', () {
    test('parses match', () {
      expect(
        NotificationReferenceType.fromString('match'),
        NotificationReferenceType.match,
      );
    });

    test('parses message', () {
      expect(
        NotificationReferenceType.fromString('message'),
        NotificationReferenceType.message,
      );
    });

    test('parses like', () {
      expect(
        NotificationReferenceType.fromString('like'),
        NotificationReferenceType.like,
      );
    });

    test('parses verification_request (snake_case)', () {
      expect(
        NotificationReferenceType.fromString('verification_request'),
        NotificationReferenceType.verificationRequest,
      );
    });

    test('parses verificationRequest (camelCase)', () {
      expect(
        NotificationReferenceType.fromString('verificationRequest'),
        NotificationReferenceType.verificationRequest,
      );
    });

    test('returns null for null input', () {
      expect(NotificationReferenceType.fromString(null), isNull);
    });

    test('unknown value falls back to match', () {
      expect(
        NotificationReferenceType.fromString('unknown'),
        NotificationReferenceType.match,
      );
    });
  });

  group('NotificationReferenceType.toJson', () {
    test('verificationRequest serialises as verification_request', () {
      expect(
        NotificationReferenceType.verificationRequest.toJson(),
        'verification_request',
      );
    });

    test('match serialises as match', () {
      expect(NotificationReferenceType.match.toJson(), 'match');
    });

    test('message serialises as message', () {
      expect(NotificationReferenceType.message.toJson(), 'message');
    });

    test('like serialises as like', () {
      expect(NotificationReferenceType.like.toJson(), 'like');
    });
  });

  // ── AppNotification.fromFirestore ───────────────────────────────────────────

  group('AppNotification.fromFirestore', () {
    test('parses all required fields', () {
      final n = AppNotification.fromFirestore('doc1', {
        'id': 'doc1',
        'userId': 'user1',
        'type': 'match',
        'title': 'New match!',
        'body': 'You matched with Alex.',
        'read': false,
      });

      expect(n.id, 'doc1');
      expect(n.userId, 'user1');
      expect(n.type, NotificationType.match);
      expect(n.title, 'New match!');
      expect(n.body, 'You matched with Alex.');
      expect(n.read, false);
      expect(n.referenceId, isNull);
      expect(n.referenceType, isNull);
      expect(n.createdAt, isNull);
    });

    test('uses document ID when id field is absent', () {
      final n = AppNotification.fromFirestore('docIdFallback', {
        'userId': 'user1',
        'type': 'like',
        'title': 'title',
        'body': 'body',
        'read': false,
      });

      expect(n.id, 'docIdFallback');
    });

    test('parses optional referenceId and referenceType', () {
      final n = AppNotification.fromFirestore('doc2', {
        'id': 'doc2',
        'userId': 'user1',
        'type': 'message',
        'title': 'New message',
        'body': 'Hi!',
        'read': true,
        'referenceId': 'match123',
        'referenceType': 'match',
      });

      expect(n.referenceId, 'match123');
      expect(n.referenceType, NotificationReferenceType.match);
    });

    test('parses verification_request referenceType', () {
      final n = AppNotification.fromFirestore('doc3', {
        'id': 'doc3',
        'userId': 'user1',
        'type': 'verification',
        'title': 'Verified',
        'body': 'Your profile is verified.',
        'read': false,
        'referenceType': 'verification_request',
      });

      expect(n.referenceType, NotificationReferenceType.verificationRequest);
    });

    test('handles missing optional fields gracefully', () {
      final n = AppNotification.fromFirestore('doc4', {
        'type': 'like',
        'read': false,
      });

      expect(n.id, 'doc4');
      expect(n.userId, '');
      expect(n.title, '');
      expect(n.body, '');
      expect(n.referenceId, isNull);
      expect(n.referenceType, isNull);
      expect(n.createdAt, isNull);
    });

    test('read defaults to false when absent', () {
      final n = AppNotification.fromFirestore('doc5', {
        'type': 'match',
      });

      expect(n.read, false);
    });
  });

  // ── AppNotification.toFirestore ─────────────────────────────────────────────

  group('AppNotification.toFirestore', () {
    test('writes expected fields without optional ones', () {
      const n = AppNotification(
        id: 'n1',
        userId: 'user1',
        type: NotificationType.match,
        title: 'You matched!',
        body: 'You have a new match.',
        read: false,
      );

      final map = n.toFirestore();

      expect(map['id'], 'n1');
      expect(map['userId'], 'user1');
      expect(map['type'], 'match');
      expect(map['title'], 'You matched!');
      expect(map['body'], 'You have a new match.');
      expect(map['read'], false);
      expect(map.containsKey('referenceId'), false);
      expect(map.containsKey('referenceType'), false);
    });

    test('includes referenceId and referenceType when set', () {
      const n = AppNotification(
        id: 'n2',
        userId: 'user1',
        type: NotificationType.message,
        title: 'Message',
        body: 'Hi',
        read: false,
        referenceId: 'match456',
        referenceType: NotificationReferenceType.match,
      );

      final map = n.toFirestore();

      expect(map['referenceId'], 'match456');
      expect(map['referenceType'], 'match');
    });

    test('serialises verificationRequest as verification_request', () {
      const n = AppNotification(
        id: 'n3',
        userId: 'user1',
        type: NotificationType.verification,
        title: 'Verified',
        body: 'Done',
        read: false,
        referenceType: NotificationReferenceType.verificationRequest,
      );

      expect(n.toFirestore()['referenceType'], 'verification_request');
    });
  });
}
