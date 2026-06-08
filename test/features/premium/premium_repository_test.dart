import 'package:bloom/features/premium/data/repositories/premium_repository_impl.dart';
import 'package:bloom/features/premium/data/services/revenue_cat_service.dart';
import 'package:bloom/features/premium/domain/repositories/premium_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// ── Fake RevenueCat service ───────────────────────────────────────────────────

class _FakeRevenueCatService implements RevenueCatService {
  _FakeRevenueCatService({
    this.initResult = RevenueCatInitResult.configured,
    this.customerInfo,
    this.throwOnInit = false,
    this.throwOnGetInfo = false,
    this.throwOnRestore = false,
  });

  final RevenueCatInitResult initResult;
  final CustomerInfo? customerInfo;
  final bool throwOnInit;
  final bool throwOnGetInfo;
  final bool throwOnRestore;

  @override
  Future<RevenueCatInitResult> configure({required String userId}) async {
    if (throwOnInit) throw Exception('SDK init error');
    return initResult;
  }

  @override
  Future<void> logIn(String userId) async {}

  @override
  Future<void> logOut() async {}

  @override
  Future<CustomerInfo?> getCustomerInfo() async {
    if (throwOnGetInfo) throw Exception('SDK get info error');
    return customerInfo;
  }

  @override
  Future<CustomerInfo?> restorePurchases() async {
    if (throwOnRestore) throw Exception('SDK restore error');
    return customerInfo;
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('PremiumRepositoryImpl.initializeForUser', () {
    test('returns PremiumInitConfigured when service returns configured', () async {
      final repo = PremiumRepositoryImpl(
        service: _FakeRevenueCatService(
          initResult: RevenueCatInitResult.configured,
        ),
      );
      final result = await repo.initializeForUser('uid123');
      expect(result, isA<PremiumInitConfigured>());
    });

    test('returns PremiumInitUnconfigured when service returns unconfigured', () async {
      final repo = PremiumRepositoryImpl(
        service: _FakeRevenueCatService(
          initResult: RevenueCatInitResult.unconfigured,
        ),
      );
      final result = await repo.initializeForUser('uid123');
      expect(result, isA<PremiumInitUnconfigured>());
    });

    test('returns PremiumInitFailed when service returns error result', () async {
      final repo = PremiumRepositoryImpl(
        service: _FakeRevenueCatService(
          initResult: RevenueCatInitResult.error,
        ),
      );
      final result = await repo.initializeForUser('uid123');
      expect(result, isA<PremiumInitFailed>());
    });

    test('returns PremiumInitFailed when service throws', () async {
      final repo = PremiumRepositoryImpl(
        service: _FakeRevenueCatService(throwOnInit: true),
      );
      final result = await repo.initializeForUser('uid123');
      expect(result, isA<PremiumInitFailed>());
    });
  });

  group('PremiumRepositoryImpl.getCustomerInfo', () {
    test('returns null when service returns null', () async {
      final repo = PremiumRepositoryImpl(
        service: _FakeRevenueCatService(customerInfo: null),
      );
      expect(await repo.getCustomerInfo(), isNull);
    });

    test('returns null when service throws', () async {
      final repo = PremiumRepositoryImpl(
        service: _FakeRevenueCatService(throwOnGetInfo: true),
      );
      expect(await repo.getCustomerInfo(), isNull);
    });
  });

  group('PremiumRepositoryImpl.restorePurchases', () {
    test('returns null when service returns null', () async {
      final repo = PremiumRepositoryImpl(
        service: _FakeRevenueCatService(customerInfo: null),
      );
      expect(await repo.restorePurchases(), isNull);
    });

    test('returns null when service throws', () async {
      final repo = PremiumRepositoryImpl(
        service: _FakeRevenueCatService(throwOnRestore: true),
      );
      expect(await repo.restorePurchases(), isNull);
    });
  });

  group('PremiumRepositoryImpl.isPremiumEntitled', () {
    test('returns false when customerInfo is null', () async {
      final repo = PremiumRepositoryImpl(
        service: _FakeRevenueCatService(customerInfo: null),
      );
      expect(await repo.isPremiumEntitled(), false);
    });

    test('returns false when getCustomerInfo throws', () async {
      final repo = PremiumRepositoryImpl(
        service: _FakeRevenueCatService(throwOnGetInfo: true),
      );
      expect(await repo.isPremiumEntitled(), false);
    });
  });
}
