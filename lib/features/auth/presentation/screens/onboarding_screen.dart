import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/domain/failures/auth_failure.dart';
import '../../../auth/domain/usecases/complete_onboarding_usecase.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding/age_verification_step.dart';
import '../widgets/onboarding/discovery_preferences_step.dart';
import '../widgets/onboarding/identity_step.dart';
import '../widgets/onboarding/photo_upload_step.dart';
import '../widgets/onboarding/profile_creation_step.dart';
import '../widgets/onboarding/welcome_step.dart';
import '../widgets/onboarding_progress_bar.dart';

/// Total onboarding steps (0-indexed): welcome, identity, age, profile,
/// photos, preferences.
const int _kTotalSteps = 6;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (!mounted) return;
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentStep < _kTotalSteps - 1) _goToStep(_currentStep + 1);
  }

  void _back() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  Future<void> _complete() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<dynamic>>(onboardingProvider, (_, next) {
      if (next.hasError) {
        final err = next.error;
        if (err == null) return;
        final message = err is OnboardingException
            ? err.message
            : err is AuthFailure
                ? err.message
                : 'Something went wrong. Please try again.';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        ref.read(onboardingProvider.notifier).clearError();
      }
    });

    final isSubmitting = ref.watch(onboardingProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            if (_currentStep > 0)
              OnboardingProgressBar(
                currentStep: _currentStep - 1,
                totalSteps: _kTotalSteps - 1,
              )
            else
              const SizedBox(height: 4),
            const SizedBox(height: AppSpacing.lg),
            if (_currentStep > 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20),
                    onPressed: isSubmitting ? null : _back,
                  ),
                ),
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  WelcomeStep(onNext: _next),
                  IdentityStep(onNext: _next, onBack: _back),
                  AgeVerificationStep(onNext: _next, onBack: _back),
                  ProfileCreationStep(onNext: _next, onBack: _back),
                  PhotoUploadStep(onNext: _next, onBack: _back),
                  DiscoveryPreferencesStep(
                    onBack: _back,
                    isSubmitting: isSubmitting,
                    onComplete: _complete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
