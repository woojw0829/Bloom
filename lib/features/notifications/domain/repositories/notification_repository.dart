import '../models/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> watchNotifications({
    required String userId,
    int limit = 50,
  });

  Stream<int> watchUnreadCount({
    required String userId,
  });

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  });

  Future<void> markAllAsRead({
    required String userId,
  });
}
