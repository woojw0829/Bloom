import '../models/app_notification.dart';
import '../repositories/notification_repository.dart';

class WatchNotificationsUseCase {
  const WatchNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  Stream<List<AppNotification>> execute({
    required String userId,
    int limit = 50,
  }) {
    if (userId.trim().isEmpty) return Stream.value(const []);
    return _repository.watchNotifications(userId: userId, limit: limit);
  }
}
