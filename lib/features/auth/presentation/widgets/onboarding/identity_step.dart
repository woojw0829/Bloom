import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_options.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/bloom_interest_chip.dart';
import '../../providers/onboarding_provider.dart';
import '../gradient_button.dart';

class IdentityStep extends ConsumerWidget {
  const IdentityStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingProvider).valueOrNull;
    final selected = state?.identity;
    final canProceed = selected != null && selected.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.onboardingIdentityTitle, style: AppTypography.heading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.onboardingIdentityBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: AppOptions.identities.map((identity) {
                  return BloomInterestChip(
                    label: identity,
                    selected: selected == identity,
                    onTap: () => ref
                        .read(onboardingProvider.notifier)
                        .setIdentity(identity),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: l10n.continueAction,
            onPressed: canProceed ? onNext : null,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
