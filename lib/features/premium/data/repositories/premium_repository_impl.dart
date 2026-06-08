import 'package:purchases_flutter/purchases_flutter.dart';

import '../../domain/constants/premium_constants.dart' as premium_utils;
import '../../domain/repositories/premium_repository.dart';
import '../services/revenue_cat_service.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  PremiumRepositoryImpl({RevenueCatService? service})
      : _service = service ?? RevenueCatServiceImpl();

  final RevenueCatService _service;

  @override
  Future<PremiumInitResult> initializeForUser(String userId) async {
    try {
      final result = await _service.configure(userId: userId);
      return switch (result) {
        RevenueCatInitResult.configured => const PremiumInitConfigured(),
        RevenueCatInitResult.unconfigured => const PremiumInitUnconfigured(),
        RevenueCatInitResult.error => const PremiumInitFailed(
            error: 'RevenueCat service returned an error state',
          ),
      };
    } catch (e) {
      return PremiumInitFailed(error: e);
    }
  }

  @override
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await _service.getCustomerInfo();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CustomerInfo?> restorePurchases() async {
    try {
      return await _service.restorePurchases();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isPremiumEntitled() async {
    final info = await getCustomerInfo();
    return premium_utils.isPremiumEntitled(info);
  }
}
