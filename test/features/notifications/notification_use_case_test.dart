import 'package:bloom/features/notifications/domain/models/app_notification.dart';
import 'package:bloom/features/notifications/domain/repositories/notification_repository.dart';
import 'package:bloom/features/notifications/domain/usecases/mark_all_notifications_read_use_case.dart';
import 'package:bloom/features/notifications/domain/usecases/mark_notification_read_use_case.dart';
import 'package:bloom/features/notifications/domain/usecases/watch_notifications_use_case.dart';
import 'package:bloom/features/notifications/domain/usecases/watch_unread_notification_count_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNotificationRepo implements NotificationRepository {
  final List<AppNotification> notifications;
  String? lastMarkedReadId;
  String? lastMarkedAllReadUserId;
  bool shouldThrow = false;

  _FakeNotificationRepo({this.notifications = const []});

  @override
  Stream<List<AppNotification>> watchNotifications({
    required String userId,
    int limit = 50,
  }) =>
      Stream.value(notifications.where((n) => n.userId == userId).toList());

  @override
  Stream<int> watchUnreadCount({required String userId}) =>
      Stream.value(
        notifications
            .where((n) => n.userId == userId && !n.read)
            .length,
      );

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    lastMarkedReadId = notificationId;
    if (shouldThrow) throw Exception('Firestore error');
  }

  @override
  Future<void> markAllAsRead({required String userId}) async {
    lastMarkedAllReadUserId = userId;
    if (shouldThrow) throw Exception('Firestore error');
  }
}

void main() {
  late _FakeNotificationRepo repo;

  setUp(() {
    repo = _FakeNotificationRepo();
  });

  // ── WatchNotificationsUseCase ───────────────────────────────────────────────

  group('WatchNotificationsUseCase', () {
    test('returns empty stream for empty userId', () async {
      final useCase = WatchNotificationsUseCase(repo);
      final result = await useCase.execute(userId: '').first;
      expect(result, isEmpty);
    });

    test('returns empty stream for whitespace-only userId', () async {
      final useCase = WatchNotificationsUseCase(repo);
      final result = await useCase.execute(userId: '   ').first;
      expect(result, isEmpty);
    });

    test('delegates to repository for valid userId', () async {
      const notification = AppNotification(
        id: 'n1',
        userId: 'user1',
        type: NotificationType.match,
        title: 'Match!',
        body: 'You matched.',
        read: false,
      );
      repo = _FakeNotificationRepo(notifications: [notification]);
      final useCase = WatchNotificationsUseCase(repo);
      final result = await useCase.execute(userId: 'user1').first;
      expect(result, [notification]);
    });
  });

  // ── WatchUnreadNotificationCountUseCase ─────────────────────────────────────

  group('WatchUnreadNotificationCountUseCase', () {
    test('returns 0 for empty userId', () async {
      final useCase = WatchUnreadNotificationCountUseCase(repo);
      final result = await useCase.execute(userId: '').first;
      expect(result, 0);
    });

    test('returns 0 for whitespace-only userId', () async {
      final useCase = WatchUnreadNotificationCountUseCase(repo);
      final result = await useCase.execute(userId: '   ').first;
      expect(result, 0);
    });

    test('returns correct unread count', () async {
      repo = _FakeNotificationRepo(notifications: [
        const AppNotification(
          id: 'n1',
          userId: 'user1',
          type: NotificationType.like,
          title: 'Like',
          body: 'Body',
          read: false,
        ),
        const AppNotification(
          id: 'n2',
          userId: 'user1',
          type: NotificationType.match,
          title: 'Match',
          body: 'Body',
          read: true,
        ),
      ]);
      final useCase = WatchUnreadNotificationCountUseCase(repo);
      final result = await useCase.execute(userId: 'user1').first;
      expect(result, 1);
    });
  });

  // ── MarkNotificationReadUseCase ─────────────────────────────────────────────

  group('MarkNotificationReadUseCase', () {
    test('rejects empty userId — no repo call', () async {
      final useCase = MarkNotificationReadUseCase(repo);
      await useCase.execute(userId: '', notificationId: 'n1');
      expect(repo.lastMarkedReadId, isNull);
    });

    test('rejects whitespace-only userId', () async {
      final useCase = MarkNotificationReadUseCase(repo);
      await useCase.execute(userId: '   ', notificationId: 'n1');
      expect(repo.lastMarkedReadId, isNull);
    });

    test('rejects empty notificationId — no repo call', () async {
      final useCase = MarkNotificationReadUseCase(repo);
      await useCase.execute(userId: 'user1', notificationId: '');
      expect(repo.lastMarkedReadId, isNull);
    });

    test('rejects whitespace-only notificationId', () async {
      final useCase = MarkNotificationReadUseCase(repo);
      await useCase.execute(userId: 'user1', notificationId: '   ');
      expect(repo.lastMarkedReadId, isNull);
    });

    test('calls repository for valid inputs', () async {
      final useCase = MarkNotificationReadUseCase(repo);
      await useCase.execute(userId: 'user1', notificationId: 'n42');
      expect(repo.lastMarkedReadId, 'n42');
    });

    test('swallows repository error — does not throw', () async {
      repo.shouldThrow = true;
      final useCase = MarkNotificationReadUseCase(repo);
      await expectLater(
        useCase.execute(userId: 'user1', notificationId: 'n1'),
        completes,
      );
    });
  });

  // ── MarkAllNotificationsReadUseCase ─────────────────────────────────────────

  group('MarkAllNotificationsReadUseCase', () {
    test('rejects empty userId — no repo call', () async {
      final useCase = MarkAllNotificationsReadUseCase(repo);
      await useCase.execute(userId: '');
      expect(repo.lastMarkedAllReadUserId, isNull);
    });

    test('rejects whitespace-only userId', () async {
      final useCase = MarkAllNotificationsReadUseCase(repo);
      await useCase.execute(userId: '   ');
      expect(repo.lastMarkedAllReadUserId, isNull);
    });

    test('calls repository for valid userId', () async {
      final useCase = MarkAllNotificationsReadUseCase(repo);
      await useCase.execute(userId: 'user1');
      expect(repo.lastMarkedAllReadUserId, 'user1');
    });

    test('swallows repository error — does not throw', () async {
      repo.shouldThrow = true;
      final useCase = MarkAllNotificationsReadUseCase(repo);
      await expectLater(useCase.execute(userId: 'user1'), completes);
    });
  });
}
