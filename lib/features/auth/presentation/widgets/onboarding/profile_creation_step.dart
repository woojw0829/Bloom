import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_options.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/bloom_interest_chip.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/onboarding_state.dart';
import '../auth_text_field.dart';
import '../gradient_button.dart';

class ProfileCreationStep extends ConsumerStatefulWidget {
  const ProfileCreationStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  ConsumerState<ProfileCreationStep> createState() =>
      _ProfileCreationStepState();
}

class _ProfileCreationStepState extends ConsumerState<ProfileCreationStep> {
  late final TextEditingController _nicknameController;
  late final TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Pre-fill controllers from provider state (handles back-navigation).
  void _maybeInitControllers(OnboardingState? state) {
    if (_initialised || state == null) return;
    _nicknameController.text = state.nickname;
    _bioController.text = state.bio;
    _initialised = true;
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setNickname(_nicknameController.text);
    notifier.setBio(_bioController.text);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingProvider).valueOrNull;
    _maybeInitControllers(state);
    final selectedGoal = state?.relationshipGoal ?? '';
    final selectedInterests = state?.interests ?? <String>[];

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.onboardingProfileTitle, style: AppTypography.heading),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.onboardingProfileBody,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            AuthTextField(
              controller: _nicknameController,
              label: l10n.onboardingNickname,
              hint: l10n.onboardingNicknameHint,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.onboardingNicknameRequired;
                }
                if (v.trim().length > 30) {
                  return l10n.onboardingNicknameTooLong;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthTextField(
              controller: _bioController,
              label: l10n.onboardingBio,
              hint: l10n.onboardingBioHint,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              validator: (v) {
                if (v != null && v.length > 500) {
                  return l10n.onboardingBioTooLong;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.onboardingRelationshipGoal, style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: AppOptions.relationshipGoals.map((goal) {
                return BloomInterestChip(
                  label: goal,
                  selected: selectedGoal == goal,
                  onTap: () => ref
                      .read(onboardingProvider.notifier)
                      .setRelationshipGoal(goal),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.onboardingInterests, style: AppTypography.subtitle),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.onboardingInterestsHint, style: AppTypography.caption),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: AppOptions.interests.map((interest) {
                final isSelected = selectedInterests.contains(interest);
                return BloomInterestChip(
                  label: interest,
                  selected: isSelected,
                  onTap: () {
                    if (isSelected || selectedInterests.length < 10) {
                      ref
                          .read(onboardingProvider.notifier)
                          .toggleInterest(interest);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GradientButton(label: l10n.continueAction, onPressed: _onContinue),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
