import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/failures/auth_failure.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/gradient_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendReset() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authNotifierProvider.notifier)
        .sendPasswordReset(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, next) {
      if (next.hasError) {
        final error = next.error;
        final message =
            error is AuthFailure ? error.message : 'An unexpected error occurred.';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        ref.read(authNotifierProvider.notifier).clearError();
      }
      if (next.hasValue && !next.isLoading && !next.hasError) {
        setState(() => _emailSent = true);
      }
    });

    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: isLoading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: _emailSent
              ? _SuccessView(l10n: l10n)
              : _FormView(
                  l10n: l10n,
                  formKey: _formKey,
                  emailController: _emailController,
                  isLoading: isLoading,
                  onSend: _onSendReset,
                ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.l10n,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSend,
  });

  final AppLocalizations l10n;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.forgotPasswordTitle, style: AppTypography.heading),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.forgotPasswordSubtitle,
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: emailController,
                label: l10n.loginEmail,
                hint: l10n.loginEmailHint,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                enabled: !isLoading,
                autofillHints: const [AutofillHints.email],
                onFieldSubmitted: (_) => onSend(),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.loginEmailRequired;
                  }
                  if (!v.contains('@')) {
                    return l10n.loginEmailInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
              GradientButton(
                label: l10n.forgotPasswordSendEmail,
                onPressed: isLoading ? null : onSend,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          color: AppColors.primary,
          size: 64,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.forgotPasswordCheckInbox, style: AppTypography.heading),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.forgotPasswordEmailSent,
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            l10n.forgotPasswordBackToSignIn,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
