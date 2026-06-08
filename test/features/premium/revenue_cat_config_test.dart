import 'package:bloom/features/premium/data/services/revenue_cat_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('selectRevenueCatConfigWith', () {
    test('returns configured with iOS key on iOS', () {
      final config = selectRevenueCatConfigWith(
        iosKey: 'appl_test_key',
        androidKey: '',
        isIOS: true,
        isAndroid: false,
      );
      expect(config, isA<RevenueCatConfigured>());
      expect((config as RevenueCatConfigured).apiKey, 'appl_test_key');
    });

    test('returns configured with Android key on Android', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: 'goog_test_key',
        isIOS: false,
        isAndroid: true,
      );
      expect(config, isA<RevenueCatConfigured>());
      expect((config as RevenueCatConfigured).apiKey, 'goog_test_key');
    });

    test('returns unconfigured when iOS key is empty on iOS', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: 'goog_test_key',
        isIOS: true,
        isAndroid: false,
      );
      expect(config, isA<RevenueCatUnconfigured>());
    });

    test('returns unconfigured when Android key is empty on Android', () {
      final config = selectRevenueCatConfigWith(
        iosKey: 'appl_test_key',
        androidKey: '',
        isIOS: false,
        isAndroid: true,
      );
      expect(config, isA<RevenueCatUnconfigured>());
    });

    test('returns unconfigured on unsupported platform (not iOS, not Android)', () {
      final config = selectRevenueCatConfigWith(
        iosKey: 'appl_test_key',
        androidKey: 'goog_test_key',
        isIOS: false,
        isAndroid: false,
      );
      expect(config, isA<RevenueCatUnconfigured>());
    });

    test('returns unconfigured when both keys empty on iOS', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: '',
        isIOS: true,
        isAndroid: false,
      );
      expect(config, isA<RevenueCatUnconfigured>());
    });

    test('returns unconfigured when both keys empty on Android', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: '',
        isIOS: false,
        isAndroid: true,
      );
      expect(config, isA<RevenueCatUnconfigured>());
    });

    test('iOS takes precedence when both flags are true (should not happen)', () {
      // When both flags are true the iOS branch wins because it is checked first.
      final config = selectRevenueCatConfigWith(
        iosKey: 'appl_key',
        androidKey: 'goog_key',
        isIOS: true,
        isAndroid: true,
      );
      expect(config, isA<RevenueCatConfigured>());
      expect((config as RevenueCatConfigured).apiKey, 'appl_key');
    });
  });
}
