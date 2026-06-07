import 'dart:async';

import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final isSaving = state.isSaving;

    ref.listen<NotificationSettingsState>(notificationSettingsProvider,
        (prev, next) {
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
        title: Text(l10n.notificationsTitle),
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
            Text(l10n.notificationsKeepUpdated,
                style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.xs),
            SwitchListTile(
              title:
                  Text(l10n.notificationsMatch, style: AppTypography.body),
              subtitle: Text(
                l10n.notificationsMatchDesc,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              value: state.match,
              activeThumbColor: AppColors.primary,
              onChanged: isSaving ? null : notifier.setMatch,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title:
                  Text(l10n.notificationsMessage, style: AppTypography.body),
              subtitle: Text(
                l10n.notificationsMessageDesc,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              value: state.message,
              activeThumbColor: AppColors.primary,
              onChanged: isSaving ? null : notifier.setMessage,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: Text(l10n.notificationsLike, style: AppTypography.body),
              subtitle: Text(
                l10n.notificationsLikeDesc,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              value: state.like,
              activeThumbColor: AppColors.primary,
              onChanged: isSaving ? null : notifier.setLike,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: Text(l10n.notificationsVerification,
                  style: AppTypography.body),
              subtitle: Text(
                l10n.notificationsVerificationDesc,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              value: state.verification,
              activeThumbColor: AppColors.primary,
              onChanged: isSaving ? null : notifier.setVerification,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.xxl),
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
