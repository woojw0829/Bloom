import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/user_model.dart';
import '../../domain/usecases/update_notification_settings_use_case.dart';
import 'profile_providers.dart';
import 'user_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

/// Transient form state for the notification settings screen.
/// Lives only while [NotificationSettingsScreen] is in the tree.
class NotificationSettingsState {
  const NotificationSettingsState({
    this.match = true,
    this.message = true,
    this.like = true,
    this.verification = true,
    this.isSaving = false,
    this.saveError,
  });

  final bool match;
  final bool message;
  final bool like;
  final bool verification;
  final bool isSaving;

  /// Non-null after a failed save. Always user-readable.
  final String? saveError;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final notificationSettingsProvider = NotifierProvider.autoDispose<
    NotificationSettingsNotifier, NotificationSettingsState>(
  NotificationSettingsNotifier.new,
);

class NotificationSettingsNotifier
    extends AutoDisposeNotifier<NotificationSettingsState> {
  @override
  NotificationSettingsState build() {
    // Read once — not watch — so Firestore stream updates never reset staged
    // changes while the user is editing.
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return const NotificationSettingsState();
    final ns = user.notificationSettings;
    return NotificationSettingsState(
      match: ns.match,
      message: ns.message,
      like: ns.like,
      verification: ns.verification,
    );
  }

  // ── Field mutations ───────────────────────────────────────────────────────

  void setMatch(bool value) => _patch(match: value);
  void setMessage(bool value) => _patch(message: value);
  void setLike(bool value) => _patch(like: value);
  void setVerification(bool value) => _patch(verification: value);

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> saveChanges() async {
    if (state.isSaving) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    // Capture staged values before any state mutation.
    final match = state.match;
    final message = state.message;
    final like = state.like;
    final verification = state.verification;

    state = NotificationSettingsState(
      match: match,
      message: message,
      like: like,
      verification: verification,
      isSaving: true,
    );

    try {
      await UpdateNotificationSettingsUseCase(
        ref.read(userRepositoryProvider),
      ).call(
        currentUser: user,
        settings: UserNotificationSettings(
          match: match,
          message: message,
          like: like,
          verification: verification,
        ),
      );
    } catch (e) {
      state = NotificationSettingsState(
        match: match,
        message: message,
        like: like,
        verification: verification,
        isSaving: false,
        saveError: e is NotificationSettingsException
            ? e.message
            : 'Failed to save settings. Please try again.',
      );
      return;
    }

    // On success: clear isSaving. The screen listener detects the transition
    // isSaving true → false with no saveError and pops navigation.
    state = NotificationSettingsState(
      match: match,
      message: message,
      like: like,
      verification: verification,
    );
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _patch({
    bool? match,
    bool? message,
    bool? like,
    bool? verification,
  }) {
    state = NotificationSettingsState(
      match: match ?? state.match,
      message: message ?? state.message,
      like: like ?? state.like,
      verification: verification ?? state.verification,
      isSaving: state.isSaving,
    );
  }
}
