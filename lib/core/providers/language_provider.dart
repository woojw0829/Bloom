import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

enum AppLanguage {
  system,
  english,
  korean;

  Locale? get locale => switch (this) {
        AppLanguage.system => null,
        AppLanguage.english => const Locale('en'),
        AppLanguage.korean => const Locale('ko'),
      };

  static const _prefKey = 'app_language';

  static AppLanguage _fromString(String? value) => switch (value) {
        'en' => AppLanguage.english,
        'ko' => AppLanguage.korean,
        _ => AppLanguage.system,
      };

  String get _storageValue => switch (this) {
        AppLanguage.english => 'en',
        AppLanguage.korean => 'ko',
        AppLanguage.system => 'system',
      };
}

// ── Provider ──────────────────────────────────────────────────────────────────

final languageProvider =
    AsyncNotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

/// Exposes the resolved [Locale] for [MaterialApp.locale].
/// Returns null for [AppLanguage.system] so Flutter falls back to device locale.
final resolvedLocaleProvider = Provider<Locale?>((ref) {
  return ref.watch(languageProvider).valueOrNull?.locale;
});

class LanguageNotifier extends AsyncNotifier<AppLanguage> {
  @override
  Future<AppLanguage> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(AppLanguage._prefKey);
      return AppLanguage._fromString(stored);
    } catch (_) {
      return AppLanguage.system;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prev = state.valueOrNull ?? AppLanguage.system;
    state = AsyncData(language);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppLanguage._prefKey, language._storageValue);
    } catch (_) {
      state = AsyncData(prev);
      rethrow;
    }
  }
}
