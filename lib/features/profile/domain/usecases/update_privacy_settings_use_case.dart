import '../../../../core/constants/app_options.dart';
import '../../../../shared/models/user_model.dart';
import '../repositories/user_repository.dart';

class PrivacySettingsException implements Exception {
  const PrivacySettingsException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Updates only profileVisibility, onlineStatusVisible, lastSeenVisible, and
/// updatedAt. All other fields are preserved from [currentUser] unchanged.
class UpdatePrivacySettingsUseCase {
  const UpdatePrivacySettingsUseCase(this._repository);

  final UserRepository _repository;

  Future<void> call({
    required UserModel currentUser,
    required String profileVisibility,
    required bool onlineStatusVisible,
    required bool lastSeenVisible,
  }) async {
    if (!AppOptions.profileVisibilityOptions.contains(profileVisibility)) {
      throw const PrivacySettingsException(
        'Invalid profile visibility option.',
      );
    }
    await _repository.updateUserProfile(
      currentUser.copyWith(
        profileVisibility: profileVisibility,
        onlineStatusVisible: onlineStatusVisible,
        lastSeenVisible: lastSeenVisible,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
