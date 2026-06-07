import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../widgets/gradient_button.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          const Icon(
            Icons.local_florist_rounded,
            color: AppColors.primary,
            size: 72,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.onboardingWelcomeTitle,
            style: AppTypography.display.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.onboardingWelcomeBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _ValueRow(
            icon: Icons.verified_user_outlined,
            label: l10n.onboardingVerifiedProfiles,
          ),
          const SizedBox(height: AppSpacing.md),
          _ValueRow(
            icon: Icons.lock_outline_rounded,
            label: l10n.onboardingPrivacyProtected,
          ),
          const SizedBox(height: AppSpacing.md),
          _ValueRow(
            icon: Icons.favorite_border_rounded,
            label: l10n.onboardingRealConnections,
          ),
          const Spacer(flex: 2),
          GradientButton(label: l10n.onboardingGetStarted, onPressed: onNext),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(label, style: AppTypography.body),
        ),
      ],
    );
  }
}
