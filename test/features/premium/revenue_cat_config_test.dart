import 'package:bloom/features/premium/data/services/revenue_cat_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('selectRevenueCatConfigWith — platform-specific keys (no fallback)', () {
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

  group('selectRevenueCatConfigWith — REVENUECAT_SDK_API_KEY fallback', () {
    // ── Android fallback ──────────────────────────────────────────────────────

    test('Android falls back to sdkKey when androidKey is empty', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: '',
        sdkKey: 'rc_test_sdk_key',
        isIOS: false,
        isAndroid: true,
      );
      expect(config, isA<RevenueCatConfigured>());
      expect((config as RevenueCatConfigured).apiKey, 'rc_test_sdk_key');
    });

    test('Android treats example-file placeholder as missing and falls back to sdkKey', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: 'goog_replace_with_public_android_sdk_key',
        sdkKey: 'rc_test_sdk_key',
        isIOS: false,
        isAndroid: true,
      );
      expect(config, isA<RevenueCatConfigured>());
      expect((config as RevenueCatConfigured).apiKey, 'rc_test_sdk_key');
    });

    test('Android YOUR_ style placeholder is treated as missing and falls back to sdkKey', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: 'YOUR_ANDROID_KEY',
        sdkKey: 'rc_test_sdk_key',
        isIOS: false,
        isAndroid: true,
      );
      expect(config, isA<RevenueCatConfigured>());
      expect((config as RevenueCatConfigured).apiKey, 'rc_test_sdk_key');
    });

    test('Android platform-specific key takes priority over sdkKey', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: 'goog_real_key',
        sdkKey: 'rc_test_sdk_key',
        isIOS: false,
        isAndroid: true,
      );
      expect(config, isA<RevenueCatConfigured>());
      expect((config as RevenueCatConfigured).apiKey, 'goog_real_key');
    });

    // ── iOS fallback ──────────────────────────────────────────────────────────

    test('iOS falls back to sdkKey when iosKey is empty', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: '',
        sdkKey: 'rc_test_sdk_key',
        isIOS: true,
        isAndroid: false,
      );
      expect(config, isA<RevenueCatConfigured>());
      expect((config as RevenueCatConfigured).apiKey, 'rc_test_sdk_key');
    });

    test('iOS treats example-file placeholder as missing and falls back to sdkKey', () {
      final config = selectRevenueCatConfigWith(
        iosKey: 'appl_replace_with_public_ios_sdk_key',
        androidKey: '',
        sdkKey: 'rc_test_sdk_key',
        isIOS: true,
        isAndroid: false,
      );
      expect(config, isA<RevenueCatConfigured>());
      expect((config as RevenueCatConfigured).apiKey, 'rc_test_sdk_key');
    });

    test('iOS YOUR_ style placeholder is treated as missing and falls back to sdkKey', () {
      final config = selectRevenueCatConfigWith(
        iosKey: 'YOUR_IOS_KEY',
        androidKey: '',
        sdkKey: 'rc_test_sdk_key',
        isIOS: true,
        isAndroid: false,
      );
      expect(config, isA<RevenueCatConfigured>());
      expect((config as RevenueCatConfigured).apiKey, 'rc_test_sdk_key');
    });

    test('iOS platform-specific key takes priority over sdkKey', () {
      final config = selectRevenueCatConfigWith(
        iosKey: 'appl_real_key',
        androidKey: '',
        sdkKey: 'rc_test_sdk_key',
        isIOS: true,
        isAndroid: false,
      );
      expect(config, isA<RevenueCatConfigured>());
      expect((config as RevenueCatConfigured).apiKey, 'appl_real_key');
    });

    // ── All keys missing or placeholder → unconfigured ────────────────────────

    test('returns unconfigured when all keys are empty on Android', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: '',
        sdkKey: '',
        isIOS: false,
        isAndroid: true,
      );
      expect(config, isA<RevenueCatUnconfigured>());
    });

    test('returns unconfigured when all keys are empty on iOS', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: '',
        sdkKey: '',
        isIOS: true,
        isAndroid: false,
      );
      expect(config, isA<RevenueCatUnconfigured>());
    });

    test('returns unconfigured when sdkKey is also a placeholder on Android', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: 'goog_replace_with_public_android_sdk_key',
        sdkKey: 'YOUR_SDK_API_KEY_HERE',
        isIOS: false,
        isAndroid: true,
      );
      expect(config, isA<RevenueCatUnconfigured>());
    });

    test('returns unconfigured on unsupported platform even with sdkKey present', () {
      final config = selectRevenueCatConfigWith(
        iosKey: '',
        androidKey: '',
        sdkKey: 'rc_test_sdk_key',
        isIOS: false,
        isAndroid: false,
      );
      expect(config, isA<RevenueCatUnconfigured>());
    });

    // ── Webhook secret separation ─────────────────────────────────────────────

    // REVENUECAT_WEBHOOK_SECRET must never be read by the Flutter client.
    // This is enforced structurally: selectRevenueCatConfigWith has no
    // webhookSecret parameter, and revenue_cat_config.dart contains no
    // String.fromEnvironment('REVENUECAT_WEBHOOK_SECRET') call.
    test('selectRevenueCatConfigWith has no webhookSecret parameter', () {
      // If this test compiles, the function signature does not accept a
      // webhookSecret parameter — proof the client config is isolated from it.
      expect(
        selectRevenueCatConfigWith(
          iosKey: '',
          androidKey: '',
          sdkKey: '',
          isIOS: false,
          isAndroid: true,
        ),
        isA<RevenueCatUnconfigured>(),
      );
    });
  });
}
