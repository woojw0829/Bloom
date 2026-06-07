import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/profile/presentation/providers/user_provider.dart';
import '../../domain/entities/onboarding_data.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import 'auth_provider.dart';
import 'onboarding_state.dart';

final onboardingProvider =
    AsyncNotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends AsyncNotifier<OnboardingState> {
  // Preserved before submission so it can be restored on error.
  OnboardingState? _preSubmitState;

  @override
  FutureOr<OnboardingState> build() => const OnboardingState();

  // ── Step navigation ───────────────────────────────────────────────────────

  void nextStep() {
    final s = _current;
    state = AsyncData(s.copyWith(currentStep: s.currentStep + 1));
  }

  void previousStep() {
    final s = _current;
    if (s.currentStep > 0) {
      state = AsyncData(s.copyWith(currentStep: s.currentStep - 1));
    }
  }

  // ── Step 1 — Identity ─────────────────────────────────────────────────────

  void setIdentity(String identity) {
    state = AsyncData(_current.copyWith(identity: identity));
  }

  // ── Step 2 — Age verification ─────────────────────────────────────────────

  void setBirthDate(DateTime birthDate) {
    state = AsyncData(_current.copyWith(birthDate: birthDate));
  }

  // ── Step 3 — Profile creation ─────────────────────────────────────────────

  void setNickname(String nickname) {
    state = AsyncData(_current.copyWith(nickname: nickname));
  }

  void setBio(String bio) {
    state = AsyncData(_current.copyWith(bio: bio));
  }

  void setRelationshipGoal(String goal) {
    state = AsyncData(_current.copyWith(relationshipGoal: goal));
  }

  void toggleInterest(String interest) {
    final current = List<String>.from(_current.interests);
    if (current.contains(interest)) {
      current.remove(interest);
    } else {
      current.add(interest);
    }
    state = AsyncData(_current.copyWith(interests: current));
  }

  // ── Step 4 — Photo upload ─────────────────────────────────────────────────

  void addPhoto(String path) {
    final current = List<String>.from(_current.photoPaths);
    if (current.length < 6) current.add(path);
    state = AsyncData(_current.copyWith(photoPaths: current));
  }

  void removePhoto(int index) {
    final current = List<String>.from(_current.photoPaths);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
    }
    state = AsyncData(_current.copyWith(photoPaths: current));
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    final current = List<String>.from(_current.photoPaths);
    final item = current.removeAt(oldIndex);
    current.insert(newIndex, item);
    state = AsyncData(_current.copyWith(photoPaths: current));
  }

  // ── Step 5 — Discovery preferences ───────────────────────────────────────

  void setAgeRange(int minAge, int maxAge) {
    state = AsyncData(_current.copyWith(minAge: minAge, maxAge: maxAge));
  }

  void setMaxDistance(int km) {
    state = AsyncData(_current.copyWith(maxDistanceKm: km));
  }

  void togglePreferredIdentity(String identity) {
    final current = List<String>.from(_current.preferredIdentities);
    if (current.contains(identity)) {
      current.remove(identity);
    } else {
      current.add(identity);
    }
    state = AsyncData(_current.copyWith(preferredIdentities: current));
  }

  void togglePreferredGoal(String goal) {
    final current = List<String>.from(_current.preferredGoals);
    if (current.contains(goal)) {
      current.remove(goal);
    } else {
      current.add(goal);
    }
    state = AsyncData(_current.copyWith(preferredGoals: current));
  }

  // ── Final submission ──────────────────────────────────────────────────────
  // All data stays local until this method is called.
  // A single atomic Firestore write creates users/{userId}.
  // Document existence signals onboarding completion to the router.

  Future<void> completeOnboarding() async {
    final authUser = ref.read(authStateChangesProvider).valueOrNull;
    if (authUser == null) return;

    _preSubmitState = _current;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final data = _buildOnboardingData(_preSubmitState!);
      await CompleteOnboardingUseCase(
        ref.read(userRepositoryProvider),
      ).call(
        userId: authUser.uid,
        email: authUser.email ?? '',
        data: data,
      );
      return _preSubmitState!;
    });

    // On success the StreamProvider watching users/{userId} emits true,
    // authRoutingProvider transitions to authenticated, router → /explore.
    // On error restore the form so the user can fix and retry.
    if (state.hasError && _preSubmitState != null) {
      state = AsyncData(_preSubmitState!);
    }
  }

  void clearError() {
    if (state.hasError && _preSubmitState != null) {
      state = AsyncData(_preSubmitState!);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  OnboardingState get _current =>
      state.valueOrNull ?? const OnboardingState();

  OnboardingData _buildOnboardingData(OnboardingState s) {
    return OnboardingData(
      identity: s.identity ?? '',
      birthDate: s.birthDate ?? DateTime(2000),
      nickname: s.nickname,
      bio: s.bio,
      relationshipGoal: s.relationshipGoal,
      interests: s.interests,
      photoPaths: s.photoPaths,
      minAge: s.minAge,
      maxAge: s.maxAge,
      maxDistanceKm: s.maxDistanceKm,
      preferredIdentities: s.preferredIdentities,
      preferredGoals: s.preferredGoals,
    );
  }
}
