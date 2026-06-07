import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/fcm_token_repository_impl.dart';
import '../../domain/repositories/fcm_token_repository.dart';
import '../../domain/usecases/clear_fcm_token_use_case.dart';
import '../../domain/usecases/register_fcm_token_use_case.dart';

final fcmTokenRepositoryProvider = Provider<FcmTokenRepository>(
  (_) => FcmTokenRepositoryImpl(),
);

final registerFcmTokenUseCaseProvider = Provider<RegisterFcmTokenUseCase>(
  (ref) => RegisterFcmTokenUseCase(ref.watch(fcmTokenRepositoryProvider)),
);

final clearFcmTokenUseCaseProvider = Provider<ClearFcmTokenUseCase>(
  (ref) => ClearFcmTokenUseCase(ref.watch(fcmTokenRepositoryProvider)),
);

/// Requests notification permission, retrieves the device FCM token, and
/// persists it to Firestore users/{userId}/private/notificationTokens on auth
/// state changes. Watches for token refreshes and updates Firestore automatically.
/// Clears the token from the private path when the user signs out.
///
/// Does NOT send push notifications or create notification documents.
/// Watch at app-shell level (BloomApp) to keep alive for the full session.
final fcmTokenLifecycleProvider = Provider<void>((ref) {
  String? lastKnownUserId;
  StreamSubscription<String>? tokenRefreshSub;

  final repository = ref.read(fcmTokenRepositoryProvider);
  final registerUseCase = ref.read(registerFcmTokenUseCaseProvider);
  final clearUseCase = ref.read(clearFcmTokenUseCaseProvider);

  // Requests permission then retrieves and saves the token for the given user.
  // Errors are swallowed — token registration must not block app launch.
  Future<void> registerForUser(String uid) async {
    try {
      await repository.requestPermission();
      final token = await repository.getToken();
      if (token == null || token.isEmpty) return;
      await registerUseCase.execute(userId: uid, token: token);
    } catch (_) {}
  }

  // ── Login / sign-out trigger ─────────────────────────────────────────────────

  ref.listen(authStateChangesProvider, (_, next) {
    final uid = next.valueOrNull?.uid;

    if (uid == null) {
      // Signed out — cancel refresh subscription and clear previous user's token.
      final prev = lastKnownUserId;
      lastKnownUserId = null;
      tokenRefreshSub?.cancel();
      tokenRefreshSub = null;
      if (prev != null) unawaited(clearUseCase.execute(userId: prev));
      return;
    }

    // Deduplicate: token refresh and stream replays re-emit the same uid.
    if (uid == lastKnownUserId) return;

    // Handle user switch without an explicit sign-out.
    final prev = lastKnownUserId;
    if (prev != null) {
      tokenRefreshSub?.cancel();
      tokenRefreshSub = null;
      unawaited(clearUseCase.execute(userId: prev));
    }

    lastKnownUserId = uid;
    unawaited(registerForUser(uid));

    // Subscribe to token refreshes; save new tokens for this user.
    // uid is captured in the closure — each subscription targets the correct user.
    tokenRefreshSub = repository.watchTokenRefresh().listen((newToken) {
      if (newToken.isEmpty) return;
      unawaited(registerUseCase.execute(userId: uid, token: newToken));
    });
  });

  ref.onDispose(() {
    tokenRefreshSub?.cancel();
  });
});
