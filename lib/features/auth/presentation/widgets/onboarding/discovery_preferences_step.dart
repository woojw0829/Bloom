import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_options.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/bloom_interest_chip.dart';
import '../../providers/onboarding_provider.dart';
import '../gradient_button.dart';

class DiscoveryPreferencesStep extends ConsumerWidget {
  const DiscoveryPreferencesStep({
    super.key,
    required this.onBack,
    required this.isSubmitting,
    required this.onComplete,
  });

  final VoidCallback onBack;
  final bool isSubmitting;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingProvider).valueOrNull;
    final minAge = state?.minAge ?? AppConstants.defaultMinAge;
    final maxAge = state?.maxAge ?? AppConstants.defaultMaxAge;
    final maxDist = state?.maxDistanceKm ?? AppConstants.defaultMaxDistanceKm;
    final prefIdentities = state?.preferredIdentities ?? <String>[];
    final prefGoals = state?.preferredGoals ?? <String>[];
    final notifier = ref.read(onboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.onboardingDiscoveryTitle, style: AppTypography.heading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.onboardingDiscoveryBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Age range ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.onboardingAgeRange, style: AppTypography.subtitle),
              Text(
                l10n.onboardingAgeRangeValue(minAge, maxAge),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RangeSlider(
            values: RangeValues(minAge.toDouble(), maxAge.toDouble()),
            min: AppConstants.minAge.toDouble(),
            max: 80,
            divisions: 62,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.divider,
            onChanged: (v) =>
                notifier.setAgeRange(v.start.round(), v.end.round()),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Max distance ───────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.onboardingMaxDistance, style: AppTypography.subtitle),
              Text(
                l10n.onboardingMaxDistanceValue(maxDist),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: maxDist.toDouble(),
            min: 5,
            max: AppConstants.maxDistanceKm.toDouble(),
            divisions: 19,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.divider,
            onChanged: (v) => notifier.setMaxDistance(v.round()),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Preferred identities ───────────────────────────────────────────
          Text(l10n.onboardingShowMe, style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.onboardingShowMeHint, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppOptions.identities.map((id) {
              return BloomInterestChip(
                label: id,
                selected: prefIdentities.contains(id),
                onTap: () => notifier.togglePreferredIdentity(id),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Preferred goals ────────────────────────────────────────────────
          Text(l10n.onboardingLookingFor, style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.onboardingLookingForHint, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppOptions.relationshipGoals.map((goal) {
              return BloomInterestChip(
                label: goal,
                selected: prefGoals.contains(goal),
                onTap: () => notifier.togglePreferredGoal(goal),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),

          GradientButton(
            label: isSubmitting
                ? l10n.onboardingCreatingProfile
                : l10n.onboardingLetsBloom,
            onPressed: isSubmitting ? null : onComplete,
            isLoading: isSubmitting,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
