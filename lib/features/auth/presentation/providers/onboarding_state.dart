import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

/// In-memory accumulation of data collected across onboarding steps.
/// Never persisted to disk or Firestore until the final step completes.
@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentStep,
    // Step 1 — Identity
    String? identity,
    // Step 2 — Age verification
    DateTime? birthDate,
    // Step 3 — Profile creation
    @Default('') String nickname,
    @Default('') String bio,
    @Default('') String relationshipGoal,
    @Default(<String>[]) List<String> interests,
    // Step 4 — Photo upload (local file paths)
    @Default(<String>[]) List<String> photoPaths,
    // Step 5 — Discovery preferences
    @Default(18) int minAge,
    @Default(45) int maxAge,
    @Default(50) int maxDistanceKm,
    @Default(<String>[]) List<String> preferredIdentities,
    @Default(<String>[]) List<String> preferredGoals,
  }) = _OnboardingState;
}
