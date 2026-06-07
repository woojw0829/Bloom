import '../../../../shared/models/user_model.dart';

abstract class UserRepository {
  Future<void> createUserProfile(UserModel user);

  Future<UserModel?> getUserProfile(String userId);

  Stream<UserModel?> watchUserProfile(String userId);

  Future<void> updateUserProfile(UserModel user);

  Stream<bool> watchProfileExists(String userId);

  Future<List<String>> uploadProfilePhotos({
    required String userId,
    required List<String> photoPaths,
  });

  /// Deletes a single photo from Firebase Storage by its download URL.
  /// Best-effort — callers should not depend on this succeeding.
  Future<void> deleteProfilePhoto({
    required String userId,
    required String photoUrl,
  });
}
