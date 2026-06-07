import '../../../../shared/models/user_model.dart';
import '../../../profile/domain/repositories/user_repository.dart';
import '../entities/onboarding_data.dart';

class OnboardingException implements Exception {
  const OnboardingException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Validates onboarding data, uploads photos, and writes the single atomic
/// Firestore document that marks onboarding as complete.
///
/// Rule: [UserRepository.createUserProfile] is called exactly once.
/// No partial writes are made at any earlier point.
class CompleteOnboardingUseCase {
  const CompleteOnboardingUseCase(this._userRepository);

  final UserRepository _userRepository;

  Future<void> call({
    required String userId,
    required String email,
    required OnboardingData data,
  }) async {
    _validate(data);

    // 1 — Upload photos to Firebase Storage, receive download URLs.
    final photoUrls = await _userRepository.uploadProfilePhotos(
      userId: userId,
      photoPaths: data.photoPaths,
    );

    // 2 — Build the complete UserModel in memory.
    final now = DateTime.now();
    final user = UserModel(
      id: userId,
      email: email,
      nickname: data.nickname.trim(),
      birthDate: data.birthDate,
      age: _calculateAge(data.birthDate),
      identity: data.identity,
      relationshipGoal: data.relationshipGoal,
      bio: data.bio.trim(),
      interests: data.interests,
      city: '',           // written in Phase 5 (Location System)
      geoHash: '',        // written in Phase 5 (Location System)
      profileImages: photoUrls,
      notificationSettings: const UserNotificationSettings(),
      compatibilityPreferences: UserCompatibilityPreferences(
        minAge: data.minAge,
        maxAge: data.maxAge,
        maxDistanceKm: data.maxDistanceKm,
        identities: data.preferredIdentities,
        relationshipGoals: data.preferredGoals,
      ),
      lastSeen: now,
      createdAt: now,
      updatedAt: now,
    );

    // 3 — Single atomic Firestore write. Document existence = onboarding done.
    await _userRepository.createUserProfile(user);
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  void _validate(OnboardingData data) {
    if (data.identity.isEmpty) {
      throw const OnboardingException('Please select your identity.');
    }
    if (!_isAtLeast18(data.birthDate)) {
      throw const OnboardingException(
        'You must be 18 or older to use Bloom.',
      );
    }
    if (data.nickname.trim().isEmpty) {
      throw const OnboardingException('Please enter a nickname.');
    }
    if (data.nickname.trim().length > 30) {
      throw const OnboardingException(
        'Nickname must be 30 characters or fewer.',
      );
    }
    if (data.relationshipGoal.isEmpty) {
      throw const OnboardingException('Please select a relationship goal.');
    }
    if (data.photoPaths.isEmpty) {
      throw const OnboardingException('Please add at least one photo.');
    }
  }

  bool _isAtLeast18(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age >= 18;
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
