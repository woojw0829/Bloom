import 'package:bloom/features/premium/domain/constants/premium_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kPremiumEntitlementId', () {
    test('is "premium"', () {
      expect(kPremiumEntitlementId, 'premium');
    });
  });

  group('isPremiumEntitled', () {
    test('returns false when customerInfo is null', () {
      expect(isPremiumEntitled(null), false);
    });

    // Non-null CustomerInfo requires real purchases_flutter SDK instances
    // which depend on platform channels. Full entitlement path is verified
    // via integration tests once RevenueCat is configured with real keys.
  });
}
