import 'package:purchases_flutter/purchases_flutter.dart';

// ── Init result ───────────────────────────────────────────────────────────────

sealed class PremiumInitResult {
  const PremiumInitResult();
}

class PremiumInitConfigured extends PremiumInitResult {
  const PremiumInitConfigured();
}

class PremiumInitUnconfigured extends PremiumInitResult {
  const PremiumInitUnconfigured();
}

class PremiumInitFailed extends PremiumInitResult {
  const PremiumInitFailed({required this.error});
  final Object error;
}

// ── Repository interface ──────────────────────────────────────────────────────

abstract interface class PremiumRepository {
  Future<PremiumInitResult> initializeForUser(String userId);
  Future<CustomerInfo?> getCustomerInfo();
  Future<CustomerInfo?> restorePurchases();
  Future<bool> isPremiumEntitled();
}
