import 'package:bloom/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/usecases/unblock_user_use_case.dart';
import '../providers/safety_center_provider.dart';

class SafetyCenterScreen extends ConsumerWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final blockedAsync = ref.watch(safetyCenterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(l10n.safetyCenterTitle, style: AppTypography.bodyMedium),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
        ),
        children: [
          _Header(l10n: l10n),
          const Divider(color: AppColors.divider, height: 1),
          _BlockedUsersSection(l10n: l10n, blockedAsync: blockedAsync),
          const Divider(color: AppColors.divider, height: 1),
          _SafetyTipsSection(l10n: l10n),
          const Divider(color: AppColors.divider, height: 1),
          _InfoSection(l10n: l10n),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppColors.primary, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.safetyCenterTitle,
                style: AppTypography.subtitle
                    .copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.safetyCenterDescription,
            style:
                AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Blocked Users ─────────────────────────────────────────────────────────────

class _BlockedUsersSection extends ConsumerWidget {
  const _BlockedUsersSection({
    required this.l10n,
    required this.blockedAsync,
  });

  final AppLocalizations l10n;
  final AsyncValue<List<BlockedUserPreview>> blockedAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
          child: Text(
            l10n.safetyBlockedUsersTitle,
            style: AppTypography.label
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        blockedAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              l10n.safetyBlockedUsersEmpty,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          data: (list) => list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0,
                      AppSpacing.xl, AppSpacing.xl),
                  child: Text(
                    l10n.safetyBlockedUsersEmpty,
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary),
                  ),
                )
              : Column(
                  children: [
                    for (final preview in list)
                      _BlockedUserRow(
                        key: ValueKey(preview.userId),
                        preview: preview,
                        l10n: l10n,
                        onUnblock: () =>
                            _confirmUnblock(context, ref, preview),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _confirmUnblock(
    BuildContext context,
    WidgetRef ref,
    BlockedUserPreview preview,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.safetyUnblockTitle),
        content: Text(l10n.safetyUnblockBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.safetyUnblockCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.safetyUnblockConfirm,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final result =
        await ref.read(safetyCenterProvider.notifier).unblock(preview.userId);

    if (!context.mounted) return;
    final message = result is UnblockUserSuccess
        ? l10n.safetyUnblockSuccess
        : l10n.safetyUnblockFailed;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _BlockedUserRow extends StatelessWidget {
  const _BlockedUserRow({
    super.key,
    required this.preview,
    required this.l10n,
    required this.onUnblock,
  });

  final BlockedUserPreview preview;
  final AppLocalizations l10n;
  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    final displayName =
        preview.displayName ?? l10n.safetyBlockedUserFallback;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      leading: _Avatar(photoUrl: preview.photoUrl),
      title: Text(displayName, style: AppTypography.body),
      trailing: OutlinedButton(
        onPressed: onUnblock,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(l10n.safetyUnblock,
            style: AppTypography.caption
                .copyWith(color: AppColors.textPrimary)),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primaryLight,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: photoUrl!,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => const _DefaultAvatar(),
          ),
        ),
      );
    }
    return const CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primaryLight,
      child: _DefaultAvatar(),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.person_rounded,
        size: 28, color: AppColors.primary);
  }
}

// ── Safety Tips ───────────────────────────────────────────────────────────────

class _SafetyTipsSection extends StatelessWidget {
  const _SafetyTipsSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.safetyTipsTitle,
            style:
                AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          _TipRow(l10n.safetyTipFinancialInfo),
          _TipRow(l10n.safetyTipPublicPlace),
          _TipRow(l10n.safetyTipReportSuspicious),
          _TipRow(l10n.safetyTipBlockUncomfortable),
          _TipRow(l10n.safetyTipTrustInstincts),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle_outline,
                size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: AppTypography.body),
          ),
        ],
      ),
    );
  }
}

// ── Info cards ────────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(
            title: l10n.safetyReportInfoTitle,
            body: l10n.safetyReportInfoBody,
            icon: Icons.flag_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoCard(
            title: l10n.safetyBlockInfoTitle,
            body: l10n.safetyBlockInfoBody,
            icon: Icons.block_outlined,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(body,
                      style: AppTypography.body
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
