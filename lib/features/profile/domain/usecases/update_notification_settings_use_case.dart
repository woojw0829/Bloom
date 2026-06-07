import '../../../../shared/models/user_model.dart';
import '../repositories/user_repository.dart';

class NotificationSettingsException implements Exception {
  const NotificationSettingsException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Updates only notificationSettings and updatedAt on the user's Firestore
/// document. All other fields are preserved from [currentUser] unchanged.
class UpdateNotificationSettingsUseCase {
  const UpdateNotificationSettingsUseCase(this._repository);

  final UserRepository _repository;

  Future<void> call({
    required UserModel currentUser,
    required UserNotificationSettings settings,
  }) async {
    await _repository.updateUserProfile(
      currentUser.copyWith(
        notificationSettings: settings,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
