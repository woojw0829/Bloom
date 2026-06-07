import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/user_model.dart';
import '../repositories/user_repository.dart';

class ProfilePhotosException implements Exception {
  const ProfilePhotosException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Updates only the profileImages list and updatedAt on the user's Firestore
/// document. All other fields are preserved from [currentUser] unchanged.
class UpdateProfilePhotosUseCase {
  const UpdateProfilePhotosUseCase(this._repository);

  final UserRepository _repository;

  Future<void> call({
    required UserModel currentUser,
    required List<String> photoUrls,
  }) async {
    if (photoUrls.isEmpty) {
      throw const ProfilePhotosException(
        'You must keep at least one profile photo.',
      );
    }
    if (photoUrls.length > AppConstants.maxProfilePhotos) {
      throw const ProfilePhotosException(
        'You can have at most ${AppConstants.maxProfilePhotos} profile photos.',
      );
    }
    await _repository.updateUserProfile(
      currentUser.copyWith(
        profileImages: photoUrls,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
