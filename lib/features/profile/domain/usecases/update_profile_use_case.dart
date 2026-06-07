import '../../../../shared/models/user_model.dart';
import '../repositories/user_repository.dart';

class ProfileUpdateException implements Exception {
  const ProfileUpdateException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Updates the editable subset of a user's profile.
///
/// Immutable fields — id, email, birthDate, age, city, geoHash,
/// profileImages, accountStatus, verificationLevel, premium, createdAt —
/// are preserved from [currentUser] unchanged.
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final UserRepository _repository;

  Future<void> call({
    required UserModel currentUser,
    required String nickname,
    required String bio,
    required String relationshipGoal,
    required List<String> interests,
  }) async {
    _validate(nickname: nickname, bio: bio, relationshipGoal: relationshipGoal);

    await _repository.updateUserProfile(
      currentUser.copyWith(
        nickname: nickname.trim(),
        bio: bio.trim(),
        relationshipGoal: relationshipGoal.trim(),
        interests: interests,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void _validate({
    required String nickname,
    required String bio,
    required String relationshipGoal,
  }) {
    if (nickname.trim().isEmpty) {
      throw const ProfileUpdateException('Please enter a nickname.');
    }
    if (nickname.trim().length > 30) {
      throw const ProfileUpdateException(
        'Nickname must be 30 characters or fewer.',
      );
    }
    if (bio.length > 500) {
      throw const ProfileUpdateException(
        'Bio must be 500 characters or fewer.',
      );
    }
    if (relationshipGoal.trim().isEmpty) {
      throw const ProfileUpdateException(
        'Please select a relationship goal.',
      );
    }
  }
}
