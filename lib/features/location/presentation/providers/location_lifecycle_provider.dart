import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/location_update_policy.dart';
import '../../domain/usecases/update_current_location_use_case.dart';
import 'location_permission_provider.dart';
import 'location_update_provider.dart';

/// Drives automatic foreground location updates without user intervention.
///
/// Triggers:
/// - **Login / session restore**: fires once per new authenticated user.
/// - **App foreground / resume**: fires each time the app returns from
///   the background.
///
/// Both triggers are gated by [LocationUpdatePolicy.shouldAutoUpdate].
/// If the last update is recent (< [LocationUpdatePolicy.autoUpdateThreshold])
/// the trigger is a no-op.
///
/// Safety guarantees:
/// - Never requests location permission — updates only when already granted.
/// - Never shows UI or SnackBars — all failures are silent.
/// - Never runs concurrent updates — guarded by an in-flight flag.
/// - Never loops — reads [lastLocationUpdatedAtProvider] via [Ref.read],
///   so writes to Firestore do not re-trigger through this provider.
/// - Never writes exact coordinates to the public user document.
///
/// Watch this provider at app-shell level ([BloomApp]) to keep it alive
/// for the full app session.
final locationLifecycleProvider = Provider<void>((ref) {
  // Prevents concurrent auto-updates from overlapping.
  var isUpdating = false;

  // Tracks the userId that already received a login-triggered update.
  // Prevents duplicate runs when the auth stream re-emits (token refresh, etc).
  String? lastAutoUpdateUserId;

  Future<void> tryAutoUpdate(String userId) async {
    if (isUpdating) return;

    // Read the cached lastUpdatedAt. [lastLocationUpdatedAtProvider] is
    // non-autoDispose, so its stream value is always current once loaded.
    // valueOrNull is null while loading OR when no document exists yet —
    // shouldAutoUpdate(null) == true, so fresh logins always attempt an update.
    final lastUpdated = ref.read(lastLocationUpdatedAtProvider).valueOrNull;
    if (!LocationUpdatePolicy.shouldAutoUpdate(lastUpdated)) return;

    isUpdating = true;
    try {
      // UpdateCurrentLocationUseCase handles all internal safety checks:
      //   - verifies permission is granted before calling getCurrentPosition
      //   - returns a typed UpdateLocationError? on any failure, never throws
      // A non-null result is a silent no-op in this lifecycle context.
      await UpdateCurrentLocationUseCase(
        permissionService: ref.read(locationPermissionServiceProvider),
        locationService: ref.read(locationServiceProvider),
        locationRepository: ref.read(locationRepositoryProvider),
      ).call(userId);
    } catch (_) {
      // Purely defensive: the use case already swallows all exceptions.
      // Lifecycle updates must never surface errors to the user.
    } finally {
      isUpdating = false;
    }
  }

  // ── Login / session-restore trigger ─────────────────────────────────────────
  // Type is inferred from authStateChangesProvider to avoid importing AuthUser.

  ref.listen(authStateChangesProvider, (prev, next) {
    final uid = next.valueOrNull?.uid;

    if (uid == null) {
      // User signed out — reset so the next sign-in triggers a fresh update.
      lastAutoUpdateUserId = null;
      return;
    }

    // Mark as attempted before the async work so that repeated auth
    // emissions (token refresh, stream replay) for the same user do not
    // queue another update while one is already in flight.
    if (uid == lastAutoUpdateUserId) return;
    lastAutoUpdateUserId = uid;

    unawaited(tryAutoUpdate(uid));
  });

  // ── App foreground / resume trigger ─────────────────────────────────────────

  final lifecycleListener = AppLifecycleListener(
    onResume: () {
      final uid = ref.read(authStateChangesProvider).valueOrNull?.uid;
      if (uid == null) return;
      // Foreground resumes check the 6-hour policy each time.
      // lastAutoUpdateUserId is intentionally NOT checked here so that
      // threshold-based re-triggering governs rather than a one-shot flag.
      unawaited(tryAutoUpdate(uid));
    },
  );

  ref.onDispose(lifecycleListener.dispose);
});
