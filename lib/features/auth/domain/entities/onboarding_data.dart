/// Domain value object passed to [CompleteOnboardingUseCase].
/// Contains the fully validated, final data collected during onboarding.
class OnboardingData {
  const OnboardingData({
    required this.identity,
    required this.birthDate,
    required this.nickname,
    required this.bio,
    required this.relationshipGoal,
    required this.interests,
    required this.photoPaths,
    required this.minAge,
    required this.maxAge,
    required this.maxDistanceKm,
    required this.preferredIdentities,
    required this.preferredGoals,
  });

  final String identity;
  final DateTime birthDate;
  final String nickname;
  final String bio;
  final String relationshipGoal;
  final List<String> interests;

  /// Absolute file paths of photos on the device.
  /// Uploaded to Firebase Storage during [CompleteOnboardingUseCase.call].
  final List<String> photoPaths;

  final int minAge;
  final int maxAge;
  final int maxDistanceKm;
  final List<String> preferredIdentities;
  final List<String> preferredGoals;
}
