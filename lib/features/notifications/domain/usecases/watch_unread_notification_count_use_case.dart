import '../repositories/notification_repository.dart';

class WatchUnreadNotificationCountUseCase {
  const WatchUnreadNotificationCountUseCase(this._repository);

  final NotificationRepository _repository;

  Stream<int> execute({required String userId}) {
    if (userId.trim().isEmpty) return Stream.value(0);
    return _repository.watchUnreadCount(userId: userId);
  }
}
