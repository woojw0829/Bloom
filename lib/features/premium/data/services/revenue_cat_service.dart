import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenue_cat_config.dart';

enum RevenueCatInitResult { configured, unconfigured, error }

// ── Abstract interface ────────────────────────────────────────────────────────

abstract interface class RevenueCatService {
  Future<RevenueCatInitResult> configure({required String userId});
  Future<void> logIn(String userId);
  Future<void> logOut();
  Future<CustomerInfo?> getCustomerInfo();
  Future<CustomerInfo?> restorePurchases();
}

// ── Production implementation ─────────────────────────────────────────────────

class RevenueCatServiceImpl implements RevenueCatService {
  bool _configured = false;

  /// Configures the Purchases SDK once with the Firebase UID as the App User ID.
  /// If already configured, logs in the new user without re-initialising.
  /// Returns [RevenueCatInitResult.unconfigured] when no API key is present
  /// (e.g. local dev without --dart-define keys) so the app continues normally.
  @override
  Future<RevenueCatInitResult> configure({required String userId}) async {
    if (_configured) {
      await logIn(userId);
      return RevenueCatInitResult.configured;
    }

    final config = selectRevenueCatConfig();
    if (config is RevenueCatUnconfigured) {
      return RevenueCatInitResult.unconfigured;
    }

    final purchasesConfig =
        PurchasesConfiguration((config as RevenueCatConfigured).apiKey)
          ..appUserID = userId;

    await Purchases.configure(purchasesConfig);
    _configured = true;
    return RevenueCatInitResult.configured;
  }

  /// Switches the SDK to a different user without re-configuring.
  /// No-op when the SDK is not configured.
  @override
  Future<void> logIn(String userId) async {
    if (!_configured) return;
    await Purchases.logIn(userId);
  }

  /// Switches the SDK back to an anonymous user.
  /// Not called on sign-out in Task 13.1 to avoid creating orphaned anonymous
  /// customers in RevenueCat. Revisit in Task 13.2 if needed.
  @override
  Future<void> logOut() async {
    if (!_configured) return;
    await Purchases.logOut();
  }

  @override
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_configured) return null;
    return Purchases.getCustomerInfo();
  }

  @override
  Future<CustomerInfo?> restorePurchases() async {
    if (!_configured) return null;
    return Purchases.restorePurchases();
  }
}
