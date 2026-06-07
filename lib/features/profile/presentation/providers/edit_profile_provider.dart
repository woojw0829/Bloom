import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/update_profile_use_case.dart';
import 'profile_providers.dart';
import 'user_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

/// Transient form state for the edit-profile screen.
/// Not persisted — lives only as long as [EditProfileScreen] is in the tree.
class EditProfileState {
  const EditProfileState({
    this.nickname = '',
    this.bio = '',
    this.relationshipGoal = '',
    this.interests = const [],
    this.isSaving = false,
    this.saveError,
  });

  final String nickname;
  final String bio;
  final String relationshipGoal;
  final List<String> interests;
  final bool isSaving;

  /// Non-null after a failed save. Always a user-readable string — never a
  /// raw Dart exception message.
  final String? saveError;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final editProfileProvider =
    NotifierProvider.autoDispose<EditProfileNotifier, EditProfileState>(
  EditProfileNotifier.new,
);

class EditProfileNotifier extends AutoDisposeNotifier<EditProfileState> {
  @override
  EditProfileState build() {
    // Read once — not watch — so the Firestore stream never resets form state
    // while the user is actively editing.
    final user = ref.read(currentUserProvider).valueOrNull;
    return user == null
        ? const EditProfileState()
        : EditProfileState(
            nickname: user.nickname,
            bio: user.bio,
            relationshipGoal: user.relationshipGoal,
            interests: List<String>.from(user.interests),
          );
  }

  // ── Field mutations ───────────────────────────────────────────────────────

  void updateNickname(String value) => _patch(nickname: value);
  void updateBio(String value) => _patch(bio: value);
  void setRelationshipGoal(String goal) => _patch(relationshipGoal: goal);

  void toggleInterest(String interest) {
    final updated = List<String>.from(state.interests);
    if (updated.contains(interest)) {
      updated.remove(interest);
    } else if (updated.length < 10) {
      updated.add(interest);
    }
    _patch(interests: updated);
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> saveChanges({
    required String nickname,
    required String bio,
  }) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    // Capture chip state before any state mutation.
    final relationshipGoal = state.relationshipGoal;
    final interests = List<String>.from(state.interests);

    state = EditProfileState(
      nickname: nickname,
      bio: bio,
      relationshipGoal: relationshipGoal,
      interests: interests,
      isSaving: true,
    );

    try {
      await UpdateProfileUseCase(ref.read(userRepositoryProvider)).call(
        currentUser: currentUser,
        nickname: nickname,
        bio: bio,
        relationshipGoal: relationshipGoal,
        interests: interests,
      );
    } catch (e) {
      state = EditProfileState(
        nickname: nickname,
        bio: bio,
        relationshipGoal: relationshipGoal,
        interests: interests,
        isSaving: false,
        saveError: e is ProfileUpdateException
            ? e.message
            : 'Failed to save profile. Please try again.',
      );
      return;
    }

    // On success: clear isSaving. The screen listener detects the transition
    // isSaving true → false with no saveError and pops navigation.
    state = EditProfileState(
      nickname: nickname,
      bio: bio,
      relationshipGoal: relationshipGoal,
      interests: interests,
      isSaving: false,
    );
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _patch({
    String? nickname,
    String? bio,
    String? relationshipGoal,
    List<String>? interests,
  }) {
    state = EditProfileState(
      nickname: nickname ?? state.nickname,
      bio: bio ?? state.bio,
      relationshipGoal: relationshipGoal ?? state.relationshipGoal,
      interests: interests ?? state.interests,
      isSaving: state.isSaving,
    );
  }
}
