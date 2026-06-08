import 'dart:io';

// Compile-time constants injected via --dart-define.
// Empty string when not provided — never crash, just leave SDK unconfigured.
const String _iosKey = String.fromEnvironment('REVENUECAT_IOS_API_KEY');
const String _androidKey = String.fromEnvironment('REVENUECAT_ANDROID_API_KEY');

// ── Config model ──────────────────────────────────────────────────────────────

sealed class RevenueCatPlatformConfig {
  const RevenueCatPlatformConfig();
}

class RevenueCatConfigured extends RevenueCatPlatformConfig {
  const RevenueCatConfigured({required this.apiKey});
  final String apiKey;
}

class RevenueCatUnconfigured extends RevenueCatPlatformConfig {
  const RevenueCatUnconfigured();
}

// ── Selection ─────────────────────────────────────────────────────────────────

/// Selects the correct RevenueCat public API key for the current platform.
/// Returns [RevenueCatUnconfigured] when the key is missing or the platform
/// is not supported — the app must not crash in that case.
RevenueCatPlatformConfig selectRevenueCatConfig() {
  return selectRevenueCatConfigWith(
    iosKey: _iosKey,
    androidKey: _androidKey,
    isIOS: Platform.isIOS || Platform.isMacOS,
    isAndroid: Platform.isAndroid,
  );
}

/// Testable variant — accepts explicit platform flags and key values
/// so tests can exercise every branch without running on real devices.
RevenueCatPlatformConfig selectRevenueCatConfigWith({
  required String iosKey,
  required String androidKey,
  required bool isIOS,
  required bool isAndroid,
}) {
  if (isIOS) {
    return iosKey.isNotEmpty
        ? RevenueCatConfigured(apiKey: iosKey)
        : const RevenueCatUnconfigured();
  }
  if (isAndroid) {
    return androidKey.isNotEmpty
        ? RevenueCatConfigured(apiKey: androidKey)
        : const RevenueCatUnconfigured();
  }
  return const RevenueCatUnconfigured();
}
