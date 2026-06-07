import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/failures/auth_failure.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/social_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onSignIn() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
  }

  void _onGoogleSignIn() {
    ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  void _onAppleSignIn() {
    ref.read(authNotifierProvider.notifier).signInWithApple();
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
    });

    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxxxl),
              _BloomHeader(tagline: l10n.loginTagline),
              const SizedBox(height: AppSpacing.xxxxl),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthTextField(
                      controller: _emailController,
                      label: l10n.loginEmail,
                      hint: l10n.loginEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.email],
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
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
                    const SizedBox(height: AppSpacing.lg),
                    AuthTextField(
                      controller: _passwordController,
                      label: l10n.loginPassword,
                      isPassword: true,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _onSignIn(),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.loginPasswordRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.push(AppRoutes.forgotPassword),
                        child: Text(
                          l10n.loginForgotPassword,
                          style: AppTypography.label.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GradientButton(
                      label: l10n.loginSignIn,
                      onPressed: isLoading ? null : _onSignIn,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _OrDivider(label: l10n.loginOr),
                    const SizedBox(height: AppSpacing.xl),
                    SocialSignInButton(
                      label: l10n.loginContinueWithGoogle,
                      onPressed: isLoading ? null : _onGoogleSignIn,
                      isLoading: isLoading,
                    ),
                    if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                      const SizedBox(height: AppSpacing.md),
                      SocialSignInButton(
                        label: l10n.loginContinueWithApple,
                        onPressed: isLoading ? null : _onAppleSignIn,
                        isLoading: isLoading,
                        isDark: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              _SignUpRow(
                noAccountText: l10n.loginNoAccount,
                signUpText: l10n.loginSignUp,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────────

class _BloomHeader extends StatelessWidget {
  const _BloomHeader({required this.tagline});

  final String tagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.local_florist_rounded,
          color: AppColors.primary,
          size: 52,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'bloom',
          style: AppTypography.display.copyWith(
            color: AppColors.primary,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          tagline,
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label,
            style:
                AppTypography.caption.copyWith(color: AppColors.textDisabled),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}

class _SignUpRow extends StatelessWidget {
  const _SignUpRow({
    required this.noAccountText,
    required this.signUpText,
    required this.isLoading,
  });

  final String noAccountText;
  final String signUpText;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          noAccountText,
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: isLoading ? null : () => context.push(AppRoutes.register),
          child: Text(
            signUpText,
            style:
                AppTypography.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
