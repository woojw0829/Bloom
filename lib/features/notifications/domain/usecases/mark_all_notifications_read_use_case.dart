import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<void> execute({required String userId}) async {
    if (userId.trim().isEmpty) return;
    try {
      await _repository.markAllAsRead(userId: userId);
    } catch (_) {}
  }
}
