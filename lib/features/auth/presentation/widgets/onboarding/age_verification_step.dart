import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../providers/onboarding_provider.dart';
import '../gradient_button.dart';

class AgeVerificationStep extends ConsumerStatefulWidget {
  const AgeVerificationStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  ConsumerState<AgeVerificationStep> createState() =>
      _AgeVerificationStepState();
}

class _AgeVerificationStepState extends ConsumerState<AgeVerificationStep> {
  DateTime? _selectedDate;
  String? _errorMessage;

  bool _isAtLeast18(DateTime date) {
    final now = DateTime.now();
    int age = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }
    return age >= AppConstants.minAge;
  }

  Future<void> _pickDate(AppLocalizations l10n) async {
    final now = DateTime.now();
    final oldest = DateTime(now.year - AppConstants.maxAge);
    final youngest = DateTime(now.year - AppConstants.minAge);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year - 25),
      firstDate: oldest,
      lastDate: youngest,
      helpText: l10n.onboardingSelectBirthdateHelp,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _errorMessage =
            _isAtLeast18(picked) ? null : l10n.onboardingAgeTooYoung;
      });
      if (_isAtLeast18(picked)) {
        ref.read(onboardingProvider.notifier).setBirthDate(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final existing = ref.watch(onboardingProvider).valueOrNull?.birthDate;
    final displayDate = _selectedDate ?? existing;
    final canProceed =
        displayDate != null && _isAtLeast18(displayDate) && _errorMessage == null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.onboardingAgeTitle, style: AppTypography.heading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.onboardingAgeBody,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          _DateButton(
            selectedDate: displayDate,
            placeholder: l10n.onboardingSelectBirthdate,
            onTap: () => _pickDate(l10n),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage!,
              style: AppTypography.caption.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
          const Spacer(flex: 2),
          GradientButton(
            label: l10n.continueAction,
            onPressed: canProceed ? widget.onNext : null,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.selectedDate,
    required this.placeholder,
    required this.onTap,
  });

  final DateTime? selectedDate;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = selectedDate == null
        ? placeholder
        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedDate != null ? AppColors.primary : AppColors.border,
            width: selectedDate != null ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.body.copyWith(
                color: selectedDate != null
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
