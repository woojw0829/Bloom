import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/presence_repository_impl.dart';
import '../../domain/repositories/presence_repository.dart';
import '../../domain/usecases/set_presence_use_case.dart';

final presenceRepositoryProvider = Provider<PresenceRepository>(
  (_) => PresenceRepositoryImpl(),
);

final setPresenceUseCaseProvider = Provider<SetPresenceUseCase>(
  (ref) => SetPresenceUseCase(ref.watch(presenceRepositoryProvider)),
);

/// Automatically writes RTDB presence (status/{userId}) based on auth state
/// and app lifecycle, and registers an onDisconnect hook so unexpected
/// disconnects also mark the user offline.
///
/// Triggers:
/// - Login / session restore → setupOnDisconnect, then isOnline: true
/// - App foreground / resume  → setupOnDisconnect (re-register after reconnect), then isOnline: true
/// - App background / pause / inactive / detach → isOnline: false
/// - Sign out → cancelOnDisconnect, then isOnline: false for previous user
///
/// No Firestore sync — handled in Task 9.3.
///
/// Watch at app-shell level (BloomApp) to keep alive for the full session.
final presenceLifecycleProvider = Provider<void>((ref) {
  String? lastKnownUserId;

  final useCase = ref.read(setPresenceUseCaseProvider);

  void goOnline(String uid) {
    // Register onDisconnect before writing online — ensures the disconnect hook
    // is always in place before the online state is set.
    unawaited(useCase.setupOnDisconnect(uid));
    unawaited(useCase.setOnline(uid));
  }

  void goOffline() {
    final uid = lastKnownUserId;
    if (uid == null) return;
    unawaited(useCase.setOffline(uid));
  }

  // ── Login / sign-out trigger ─────────────────────────────────────────────────

  ref.listen(authStateChangesProvider, (_, next) {
    final uid = next.valueOrNull?.uid;

    if (uid == null) {
      // Signed out — cancel disconnect hook and mark previous user offline.
      final prev = lastKnownUserId;
      lastKnownUserId = null;
      if (prev != null) {
        unawaited(useCase.cancelOnDisconnect(prev));
        unawaited(useCase.setOffline(prev));
      }
      return;
    }

    // Deduplicate: token refresh and stream replays re-emit the same uid.
    if (uid == lastKnownUserId) return;

    // Handle user switch without an explicit sign-out (e.g. anonymous upgrade).
    final prev = lastKnownUserId;
    if (prev != null) {
      unawaited(useCase.cancelOnDisconnect(prev));
      unawaited(useCase.setOffline(prev));
    }

    lastKnownUserId = uid;
    goOnline(uid);
  });

  // ── App lifecycle trigger ─────────────────────────────────────────────────────

  final lifecycleListener = AppLifecycleListener(
    onResume: () {
      // On resume, prefer lastKnownUserId; fall back to auth stream if the
      // auth listener has not fired yet (e.g. cold start with cached session).
      // Always re-register onDisconnect since the RTDB connection may have
      // been re-established with a new socket after backgrounding.
      final uid = lastKnownUserId ??
          ref.read(authStateChangesProvider).valueOrNull?.uid;
      if (uid == null) return;
      lastKnownUserId = uid;
      goOnline(uid);
    },
    onPause: goOffline,
    onInactive: goOffline,
    onDetach: goOffline,
  );

  ref.onDispose(lifecycleListener.dispose);
});
