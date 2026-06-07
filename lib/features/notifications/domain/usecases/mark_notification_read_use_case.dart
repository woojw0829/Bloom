import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<void> execute({
    required String userId,
    required String notificationId,
  }) async {
    if (userId.trim().isEmpty) return;
    if (notificationId.trim().isEmpty) return;
    try {
      await _repository.markAsRead(
        userId: userId,
        notificationId: notificationId,
      );
    } catch (_) {}
  }
}
