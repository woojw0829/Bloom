import 'dart:io';

// Compile-time constants injected via --dart-define.
// Empty string when not provided — never crash, just leave SDK unconfigured.
const String _iosKey = String.fromEnvironment('REVENUECAT_IOS_API_KEY');
const String _androidKey = String.fromEnvironment('REVENUECAT_ANDROID_API_KEY');

// Development / test fallback key — used when platform-specific key is absent.
// Platform-specific keys always take priority over this key.
const String _sdkKey = String.fromEnvironment('REVENUECAT_SDK_API_KEY');

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
/// Platform-specific keys take priority over [REVENUECAT_SDK_API_KEY].
/// Placeholder values (e.g. from example files) are treated as missing.
/// Returns [RevenueCatUnconfigured] when no valid key is found or the platform
/// is not supported — the app must not crash in that case.
RevenueCatPlatformConfig selectRevenueCatConfig() {
  return selectRevenueCatConfigWith(
    iosKey: _iosKey,
    androidKey: _androidKey,
    sdkKey: _sdkKey,
    isIOS: Platform.isIOS || Platform.isMacOS,
    isAndroid: Platform.isAndroid,
  );
}

/// Testable variant — accepts explicit platform flags and key values
/// so tests can exercise every branch without running on real devices.
/// [sdkKey] is optional; when omitted it defaults to empty (no fallback).
RevenueCatPlatformConfig selectRevenueCatConfigWith({
  required String iosKey,
  required String androidKey,
  String sdkKey = '',
  required bool isIOS,
  required bool isAndroid,
}) {
  if (isIOS) {
    final key = _firstValidKey([iosKey, sdkKey]);
    return key != null
        ? RevenueCatConfigured(apiKey: key)
        : const RevenueCatUnconfigured();
  }
  if (isAndroid) {
    final key = _firstValidKey([androidKey, sdkKey]);
    return key != null
        ? RevenueCatConfigured(apiKey: key)
        : const RevenueCatUnconfigured();
  }
  return const RevenueCatUnconfigured();
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Returns the first key from [candidates] that is not empty and not a
/// placeholder value (e.g. from example files). Returns null if none found.
String? _firstValidKey(List<String> candidates) {
  for (final k in candidates) {
    if (_isValidKey(k)) return k;
  }
  return null;
}

/// A key is valid if it is non-empty and does not contain placeholder markers
/// used in example files ('replace_with', 'YOUR_').
bool _isValidKey(String key) =>
    key.isNotEmpty &&
    !key.contains('replace_with') &&
    !key.contains('YOUR_');
