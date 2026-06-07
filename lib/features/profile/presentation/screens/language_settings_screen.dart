import 'package:bloom/core/providers/language_provider.dart';
import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final langAsync = ref.watch(languageProvider);
    final current = langAsync.valueOrNull ?? AppLanguage.system;
    final notifier = ref.read(languageProvider.notifier);

    Future<void> select(AppLanguage language) async {
      try {
        await notifier.setLanguage(language);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.languageErrorSave)));
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(l10n.languageTitle),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xl + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          _LanguageOption(
            label: l10n.languageSystemDefault,
            selected: current == AppLanguage.system,
            onTap: () => select(AppLanguage.system),
          ),
          _LanguageOption(
            label: l10n.languageEnglish,
            selected: current == AppLanguage.english,
            onTap: () => select(AppLanguage.english),
          ),
          _LanguageOption(
            label: l10n.languageKorean,
            selected: current == AppLanguage.korean,
            onTap: () => select(AppLanguage.korean),
          ),
        ],
      ),
    );
  }
}

// ── Option tile ───────────────────────────────────────────────────────────────

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: AppTypography.body.copyWith(
          color: selected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
