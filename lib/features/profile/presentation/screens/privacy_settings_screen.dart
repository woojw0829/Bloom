import 'dart:async';

import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_options.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/bloom_interest_chip.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../providers/privacy_settings_provider.dart';

// ── Display mappings (file-private) ──────────────────────────────────────────

Map<String, String> _visibilityLabels(AppLocalizations l10n) => {
      'public': l10n.privacyPublic,
      'hidden': l10n.privacyHidden,
      'selective': l10n.privacySelective,
    };

Map<String, String> _visibilityDescriptions(AppLocalizations l10n) => {
      'public': l10n.privacyPublicDesc,
      'hidden': l10n.privacyHiddenDesc,
      'selective': l10n.privacySelectiveDesc,
    };

// ── Screen ────────────────────────────────────────────────────────────────────

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(privacySettingsProvider);
    final notifier = ref.read(privacySettingsProvider.notifier);
    final isSaving = state.isSaving;

    final labels = _visibilityLabels(l10n);
    final descriptions = _visibilityDescriptions(l10n);

    ref.listen<PrivacySettingsState>(privacySettingsProvider, (prev, next) {
      if (next.saveError != null && next.saveError != prev?.saveError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.saveError!)));
      }
      if (prev?.isSaving == true && !next.isSaving && next.saveError == null) {
        if (context.mounted) context.pop();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(l10n.privacyTitle),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Profile visibility ──────────────────────────────────────────
            Text(l10n.privacyProfileVisibility, style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.xs),
            Text(
              descriptions[state.profileVisibility] ?? '',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final option in AppOptions.profileVisibilityOptions)
                  BloomInterestChip(
                    label: labels[option]!,
                    selected: state.profileVisibility == option,
                    onTap: isSaving
                        ? null
                        : () => notifier.setProfileVisibility(option),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(color: AppColors.divider),
            const SizedBox(height: AppSpacing.sm),

            // ── Visibility toggles ──────────────────────────────────────────
            Text(l10n.privacyWhoCanSeeYou, style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.xs),
            SwitchListTile(
              title: Text(l10n.privacyOnlineStatus, style: AppTypography.body),
              subtitle: Text(
                l10n.privacyOnlineStatusDesc,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              value: state.onlineStatusVisible,
              activeThumbColor: AppColors.primary,
              onChanged: isSaving
                  ? null
                  : (v) => notifier.setOnlineStatusVisible(v),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: Text(l10n.privacyLastSeen, style: AppTypography.body),
              subtitle: Text(
                l10n.privacyLastSeenDesc,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              value: state.lastSeenVisible,
              activeThumbColor: AppColors.primary,
              onChanged:
                  isSaving ? null : (v) => notifier.setLastSeenVisible(v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Save ────────────────────────────────────────────────────────
            GradientButton(
              label: l10n.saveChanges,
              isLoading: isSaving,
              onPressed:
                  isSaving ? null : () => unawaited(notifier.saveChanges()),
            ),
          ],
        ),
      ),
    );
  }
}
