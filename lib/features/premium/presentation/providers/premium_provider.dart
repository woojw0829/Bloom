import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/premium_repository_impl.dart';
import '../../data/services/revenue_cat_service.dart';
import '../../domain/constants/premium_constants.dart' as premium_utils;
import '../../domain/repositories/premium_repository.dart';

// ── Service ───────────────────────────────────────────────────────────────────

final revenueCatServiceProvider = Provider<RevenueCatService>(
  (_) => RevenueCatServiceImpl(),
);

// ── Repository ────────────────────────────────────────────────────────────────

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  return PremiumRepositoryImpl(service: ref.watch(revenueCatServiceProvider));
});

// ── Customer info ─────────────────────────────────────────────────────────────

final customerInfoProvider =
    AsyncNotifierProvider<_CustomerInfoNotifier, CustomerInfo?>(
  _CustomerInfoNotifier.new,
);

class _CustomerInfoNotifier extends AsyncNotifier<CustomerInfo?> {
  @override
  Future<CustomerInfo?> build() {
    return ref.read(premiumRepositoryProvider).getCustomerInfo();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(premiumRepositoryProvider).getCustomerInfo(),
    );
  }
}

// ── Entitlement ───────────────────────────────────────────────────────────────

/// Synchronously derives the active entitlement state from [customerInfoProvider].
/// Returns false while loading, on error, or when unconfigured.
final premiumEntitlementProvider = Provider<bool>((ref) {
  final info = ref.watch(customerInfoProvider).valueOrNull;
  return premium_utils.isPremiumEntitled(info);
});

// ── Lifecycle ─────────────────────────────────────────────────────────────────

/// Watches [authStateChangesProvider] and initialises RevenueCat with the
/// Firebase UID when a user is authenticated.
///
/// Sign-out behavior: RevenueCat SDK is NOT switched to an anonymous user on
/// sign-out. This avoids creating orphaned anonymous customer records in the
/// RevenueCat dashboard. When the user signs back in, [configure] calls
/// [Purchases.logIn] to restore the correct customer association.
/// Revisit in Task 13.2 if subscription state must be cleared on sign-out.
///
/// Watch at app-shell level (BloomApp) to keep alive for the full session.
final premiumLifecycleProvider = Provider<void>((ref) {
  String? lastKnownUserId;
  final repository = ref.read(premiumRepositoryProvider);

  ref.listen(authStateChangesProvider, (_, next) {
    final uid = next.valueOrNull?.uid;

    if (uid == null) {
      lastKnownUserId = null;
      return;
    }

    // Deduplicate: stream replays and auth refreshes re-emit the same uid.
    if (uid == lastKnownUserId) return;
    lastKnownUserId = uid;

    unawaited(
      repository.initializeForUser(uid).then((_) {
        // Refresh CustomerInfo now that the SDK is configured for this user.
        ref.invalidate(customerInfoProvider);
      }),
    );
  });
});
