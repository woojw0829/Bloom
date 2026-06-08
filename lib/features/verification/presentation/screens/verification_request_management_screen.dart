import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/verification_request.dart';
import '../providers/verification_management_provider.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class VerificationRequestManagementScreen extends ConsumerWidget {
  const VerificationRequestManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final adminAsync = ref.watch(adminClaimProvider);

    ref.listen<VerificationManagementState>(
      verificationManagementControllerProvider,
      (prev, next) {
        if (next.lastSuccessAction == 'approved' &&
            prev?.lastSuccessAction != 'approved') {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(l10n.verificationManagementApproved)),
            );
          ref
              .read(verificationManagementControllerProvider.notifier)
              .clearFeedback();
        }
        if (next.lastSuccessAction == 'rejected' &&
            prev?.lastSuccessAction != 'rejected') {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(l10n.verificationManagementRejected)),
            );
          ref
              .read(verificationManagementControllerProvider.notifier)
              .clearFeedback();
        }
        if (next.lastError == 'failed' && prev?.lastError != 'failed') {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(l10n.verificationManagementActionFailed)),
            );
          ref
              .read(verificationManagementControllerProvider.notifier)
              .clearFeedback();
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(l10n.verificationManagementTitle),
      ),
      body: adminAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => _AccessDenied(l10n: l10n),
        data: (isAdmin) =>
            isAdmin ? _RequestList(l10n: l10n) : _AccessDenied(l10n: l10n),
      ),
    );
  }
}

// ── Access denied ─────────────────────────────────────────────────────────────

class _AccessDenied extends StatelessWidget {
  const _AccessDenied({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.verificationManagementAccessDenied,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Request list ──────────────────────────────────────────────────────────────

class _RequestList extends ConsumerWidget {
  const _RequestList({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync =
        ref.watch(pendingPhotoVerificationRequestsProvider);

    return Column(
      children: [
        _PhotoOnlyNotice(l10n: l10n),
        Expanded(
          child: requestsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, _) => Center(
              child: Text(
                l10n.verificationManagementLoadFailed,
                style: AppTypography.body
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            data: (requests) => requests.isEmpty
                ? Center(
                    child: Text(
                      l10n.verificationManagementEmpty,
                      style: AppTypography.body
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: requests.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) => _RequestCard(
                      l10n: l10n,
                      request: requests[i],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ── Photo-only notice banner ──────────────────────────────────────────────────

class _PhotoOnlyNotice extends StatelessWidget {
  const _PhotoOnlyNotice({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.verificationManagementPhotoOnlyNotice,
              style: AppTypography.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Request card ──────────────────────────────────────────────────────────────

class _RequestCard extends ConsumerWidget {
  const _RequestCard({
    required this.l10n,
    required this.request,
  });

  final AppLocalizations l10n;
  final VerificationRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(verificationManagementControllerProvider);
    final notifier =
        ref.read(verificationManagementControllerProvider.notifier);
    final isThisProcessing = ctrl.processingRequestId == request.id;

    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RequestMeta(request: request),
            const SizedBox(height: AppSpacing.md),
            _SelfiePreview(l10n: l10n, requestId: request.id),
            const SizedBox(height: AppSpacing.md),
            _ActionRow(
              l10n: l10n,
              request: request,
              isProcessing: isThisProcessing,
              onApprove: () async {
                final confirmed = await _showApproveDialog(context, l10n);
                if (confirmed == true) {
                  unawaited(
                    notifier.approve(
                      requestId: request.id,
                      userId: request.userId,
                    ),
                  );
                }
              },
              onReject: () async {
                final reason = await _showRejectDialog(context, l10n);
                if (reason != null && reason.trim().isNotEmpty) {
                  unawaited(
                    notifier.reject(
                      requestId: request.id,
                      rejectionReason: reason,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showApproveDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.verificationManagementApproveTitle),
        content: Text(l10n.verificationManagementApproveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.verificationManagementApprove),
          ),
        ],
      ),
    );
  }

  Future<String?> _showRejectDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => _RejectDialog(l10n: l10n, controller: controller),
    );
  }
}

// ── Request metadata row ──────────────────────────────────────────────────────

class _RequestMeta extends StatelessWidget {
  const _RequestMeta({required this.request});

  final VerificationRequest request;

  @override
  Widget build(BuildContext context) {
    final dateStr = request.createdAt != null
        ? DateFormat.yMMMd().add_jm().format(request.createdAt!)
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User: ${request.userId}',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Submitted: $dateStr',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Selfie image preview (signed URL) ─────────────────────────────────────────

class _SelfiePreview extends ConsumerWidget {
  const _SelfiePreview({required this.l10n, required this.requestId});

  final AppLocalizations l10n;
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync =
        ref.watch(verificationSelfieSignedUrlProvider(requestId));

    return ClipRRect(
      borderRadius: AppRadius.cardBorder,
      child: Container(
        height: 200,
        width: double.infinity,
        color: AppColors.background,
        child: urlAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.verificationManagementImageLoadFailed,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          data: (url) => url != null
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(
                    child: Text(
                      l10n.verificationManagementImageLoadFailed,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    l10n.verificationManagementImageLoadFailed,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Action row ────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.l10n,
    required this.request,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  final AppLocalizations l10n;
  final VerificationRequest request;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    if (isProcessing) {
      return const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: Text(l10n.verificationManagementReject),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilledButton(
            onPressed: onApprove,
            child: Text(l10n.verificationManagementApprove),
          ),
        ),
      ],
    );
  }
}

// ── Reject dialog ─────────────────────────────────────────────────────────────

class _RejectDialog extends StatefulWidget {
  const _RejectDialog({required this.l10n, required this.controller});

  final AppLocalizations l10n;
  final TextEditingController controller;

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.verificationManagementRejectTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.l10n.verificationManagementRejectReasonHint,
              errorText: _error,
            ),
            maxLines: 3,
            maxLength: 500,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final reason = widget.controller.text.trim();
            if (reason.isEmpty) {
              setState(() {
                _error =
                    widget.l10n.verificationManagementRejectReasonRequired;
              });
              return;
            }
            Navigator.of(context).pop(reason);
          },
          child: Text(widget.l10n.verificationManagementReject),
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}
