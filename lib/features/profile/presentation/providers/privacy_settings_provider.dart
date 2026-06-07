import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/update_privacy_settings_use_case.dart';
import 'profile_providers.dart';
import 'user_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

/// Transient form state for the privacy settings screen.
/// Lives only while [PrivacySettingsScreen] is in the tree.
class PrivacySettingsState {
  const PrivacySettingsState({
    this.profileVisibility = 'public',
    this.onlineStatusVisible = true,
    this.lastSeenVisible = true,
    this.isSaving = false,
    this.saveError,
  });

  final String profileVisibility;
  final bool onlineStatusVisible;
  final bool lastSeenVisible;
  final bool isSaving;

  /// Non-null after a failed save. Always user-readable.
  final String? saveError;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final privacySettingsProvider =
    NotifierProvider.autoDispose<PrivacySettingsNotifier, PrivacySettingsState>(
  PrivacySettingsNotifier.new,
);

class PrivacySettingsNotifier extends AutoDisposeNotifier<PrivacySettingsState> {
  @override
  PrivacySettingsState build() {
    // Read once — not watch — so Firestore stream updates never reset staged
    // changes while the user is editing.
    final user = ref.read(currentUserProvider).valueOrNull;
    return user == null
        ? const PrivacySettingsState()
        : PrivacySettingsState(
            profileVisibility: user.profileVisibility,
            onlineStatusVisible: user.onlineStatusVisible,
            lastSeenVisible: user.lastSeenVisible,
          );
  }

  // ── Field mutations ───────────────────────────────────────────────────────

  void setProfileVisibility(String value) =>
      _patch(profileVisibility: value);

  void setOnlineStatusVisible(bool value) =>
      _patch(onlineStatusVisible: value);

  void setLastSeenVisible(bool value) =>
      _patch(lastSeenVisible: value);

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> saveChanges() async {
    if (state.isSaving) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    // Capture staged values before any state mutation.
    final profileVisibility = state.profileVisibility;
    final onlineStatusVisible = state.onlineStatusVisible;
    final lastSeenVisible = state.lastSeenVisible;

    state = PrivacySettingsState(
      profileVisibility: profileVisibility,
      onlineStatusVisible: onlineStatusVisible,
      lastSeenVisible: lastSeenVisible,
      isSaving: true,
    );

    try {
      await UpdatePrivacySettingsUseCase(
        ref.read(userRepositoryProvider),
      ).call(
        currentUser: user,
        profileVisibility: profileVisibility,
        onlineStatusVisible: onlineStatusVisible,
        lastSeenVisible: lastSeenVisible,
      );
    } catch (e) {
      state = PrivacySettingsState(
        profileVisibility: profileVisibility,
        onlineStatusVisible: onlineStatusVisible,
        lastSeenVisible: lastSeenVisible,
        isSaving: false,
        saveError: e is PrivacySettingsException
            ? e.message
            : 'Failed to save settings. Please try again.',
      );
      return;
    }

    // On success: clear isSaving. The screen listener detects the transition
    // isSaving true → false with no saveError and pops navigation.
    state = PrivacySettingsState(
      profileVisibility: profileVisibility,
      onlineStatusVisible: onlineStatusVisible,
      lastSeenVisible: lastSeenVisible,
    );
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _patch({
    String? profileVisibility,
    bool? onlineStatusVisible,
    bool? lastSeenVisible,
  }) {
    state = PrivacySettingsState(
      profileVisibility: profileVisibility ?? state.profileVisibility,
      onlineStatusVisible: onlineStatusVisible ?? state.onlineStatusVisible,
      lastSeenVisible: lastSeenVisible ?? state.lastSeenVisible,
      isSaving: state.isSaving,
    );
  }
}
