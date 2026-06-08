import 'package:purchases_flutter/purchases_flutter.dart';

const String kPremiumEntitlementId = 'premium';

/// Returns true when [customerInfo] contains an active 'premium' entitlement.
/// Safe to call with null — returns false when the SDK is not yet configured.
bool isPremiumEntitled(CustomerInfo? customerInfo) {
  if (customerInfo == null) return false;
  return customerInfo.entitlements.active.containsKey(kPremiumEntitlementId);
}
