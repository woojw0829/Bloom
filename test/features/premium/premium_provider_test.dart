import 'package:bloom/features/premium/domain/repositories/premium_repository.dart';
import 'package:bloom/features/premium/presentation/providers/premium_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show CustomerInfo;

// ── Fake repository ───────────────────────────────────────────────────────────

class _FakePremiumRepository implements PremiumRepository {
  @override
  Future<PremiumInitResult> initializeForUser(String userId) async =>
      const PremiumInitConfigured();

  @override
  Future<CustomerInfo?> getCustomerInfo() async => null;

  @override
  Future<CustomerInfo?> restorePurchases() async => null;

  @override
  Future<bool> isPremiumEntitled() async => false;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('premiumEntitlementProvider', () {
    test('returns false when customerInfoProvider is in loading state', () {
      final container = ProviderContainer(
        overrides: [
          premiumRepositoryProvider
              .overrideWithValue(_FakePremiumRepository()),
        ],
      );
      addTearDown(container.dispose);

      // customerInfoProvider is AsyncLoading initially — entitlement is false.
      expect(container.read(premiumEntitlementProvider), false);
    });

    test('returns false when customerInfo resolves to null', () async {
      final container = ProviderContainer(
        overrides: [
          premiumRepositoryProvider
              .overrideWithValue(_FakePremiumRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(customerInfoProvider.future);
      expect(container.read(premiumEntitlementProvider), false);
    });
  });

  group('customerInfoProvider', () {
    test('resolves to null when repository returns null', () async {
      final container = ProviderContainer(
        overrides: [
          premiumRepositoryProvider
              .overrideWithValue(_FakePremiumRepository()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(customerInfoProvider.future);
      expect(result, isNull);
    });

    test('does not throw when repository returns null', () async {
      final container = ProviderContainer(
        overrides: [
          premiumRepositoryProvider
              .overrideWithValue(_FakePremiumRepository()),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(customerInfoProvider.future),
        returnsNormally,
      );
    });
  });
}
