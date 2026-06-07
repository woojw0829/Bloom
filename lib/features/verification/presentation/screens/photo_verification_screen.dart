import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/verification_request.dart';
import '../providers/verification_provider.dart';

class PhotoVerificationScreen extends ConsumerWidget {
  const PhotoVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final requestAsync = ref.watch(latestPhotoVerificationRequestProvider);

    ref.listen<PhotoVerificationState>(
      photoVerificationControllerProvider,
      (prev, next) {
        if (next.submitted && prev?.submitted != true) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(l10n.photoVerificationSubmitted)),
            );
        }
        if (next.error == 'failed' && prev?.error != 'failed') {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(l10n.photoVerificationFailed)),
            );
          ref.read(photoVerificationControllerProvider.notifier).clearError();
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(l10n.verificationTitle),
      ),
      body: requestAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => _SubmissionForm(l10n: l10n),
        data: (request) => switch (request?.status) {
          VerificationRequestStatus.pending => _PendingView(l10n: l10n),
          VerificationRequestStatus.approved => _ApprovedView(l10n: l10n),
          VerificationRequestStatus.rejected =>
            _RejectedView(l10n: l10n, rejectionReason: request?.rejectionReason),
          null => _SubmissionForm(l10n: l10n),
        },
      ),
    );
  }
}

// ── Submission form ───────────────────────────────────────────────────────────

class _SubmissionForm extends ConsumerWidget {
  const _SubmissionForm({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(photoVerificationControllerProvider);
    final notifier = ref.read(photoVerificationControllerProvider.notifier);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl + bottomPad,
      ),
      children: [
        Text(
          l10n.photoVerificationTitle,
          style: AppTypography.heading,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.photoVerificationDescription,
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PrivacyNote(label: l10n.photoVerificationPrivacyNote),
        const SizedBox(height: AppSpacing.xl),
        if (ctrl.selectedFile != null) ...[
          _ImagePreview(file: ctrl.selectedFile!),
          const SizedBox(height: AppSpacing.lg),
        ],
        OutlinedButton.icon(
          onPressed: ctrl.isSubmitting
              ? null
              : () => unawaited(notifier.pickImage()),
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(
            ctrl.selectedFile == null
                ? l10n.photoVerificationPickPhoto
                : l10n.photoVerificationChangePhoto,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed:
              ctrl.isSubmitting || ctrl.selectedFile == null
                  ? null
                  : () => unawaited(notifier.submit()),
          child: ctrl.isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(l10n.photoVerificationSubmit),
        ),
      ],
    );
  }
}

// ── Pending view ──────────────────────────────────────────────────────────────

class _PendingView extends StatelessWidget {
  const _PendingView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      icon: Icons.hourglass_top_rounded,
      iconColor: AppColors.primary,
      title: l10n.photoVerificationPendingTitle,
      body: l10n.photoVerificationPendingBody,
    );
  }
}

// ── Approved view ─────────────────────────────────────────────────────────────

class _ApprovedView extends StatelessWidget {
  const _ApprovedView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      icon: Icons.verified_rounded,
      iconColor: Colors.green,
      title: l10n.photoVerificationApprovedTitle,
      body: l10n.photoVerificationApprovedBody,
    );
  }
}

// ── Rejected view ─────────────────────────────────────────────────────────────

class _RejectedView extends ConsumerWidget {
  const _RejectedView({
    required this.l10n,
    this.rejectionReason,
  });

  final AppLocalizations l10n;
  final String? rejectionReason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(photoVerificationControllerProvider);
    final notifier = ref.read(photoVerificationControllerProvider.notifier);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl + bottomPad,
      ),
      children: [
        _StatusCard(
          icon: Icons.cancel_outlined,
          iconColor: AppColors.error,
          title: l10n.photoVerificationRejectedTitle,
          body: l10n.photoVerificationRejectedBody,
        ),
        if (rejectionReason != null && rejectionReason!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.cardBorder,
            ),
            child: Text(
              rejectionReason!,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (ctrl.selectedFile != null) ...[
          _ImagePreview(file: ctrl.selectedFile!),
          const SizedBox(height: AppSpacing.lg),
        ],
        OutlinedButton.icon(
          onPressed: ctrl.isSubmitting
              ? null
              : () => unawaited(notifier.pickImage()),
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(
            ctrl.selectedFile == null
                ? l10n.photoVerificationPickPhoto
                : l10n.photoVerificationChangePhoto,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed:
              ctrl.isSubmitting || ctrl.selectedFile == null
                  ? null
                  : () => unawaited(notifier.submit()),
          child: ctrl.isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(l10n.photoVerificationSubmit),
        ),
      ],
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: iconColor),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTypography.heading, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.cardBorder,
      child: Image.file(
        file,
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
