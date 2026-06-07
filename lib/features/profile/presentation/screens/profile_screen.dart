import 'package:bloom/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/bloom_interest_chip.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const _LoadingScaffold(),
      error: (_, _) => const _ErrorScaffold(),
      data: (user) => user == null
          ? const _LoadingScaffold()
          : _ProfileContent(user: user),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            l10n.profileErrorLoad,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _PhotoAppBar(
            user: user,
            onEdit: () => context.push(AppRoutes.profileEdit),
            onManagePhotos: () => context.push(AppRoutes.profilePhotos),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  _NameRow(user: user),
                  const SizedBox(height: AppSpacing.sm),
                  _IdentityBadge(identity: user.identity),
                  if (user.city.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _LocationRow(city: user.city),
                  ],
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _SectionLabel(l10n.profileAbout),
                    const SizedBox(height: AppSpacing.sm),
                    Text(user.bio, style: AppTypography.body),
                  ],
                  if (user.relationshipGoal.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _SectionLabel(l10n.profileLookingFor),
                    const SizedBox(height: AppSpacing.sm),
                    _GoalChip(goal: user.relationshipGoal),
                  ],
                  if (user.interests.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _SectionLabel(l10n.profileInterests),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final interest in user.interests)
                          BloomInterestChip(
                            label: interest,
                            selected: true,
                            readOnly: true,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(color: AppColors.divider),
                  _PrivacyTile(
                    label: l10n.profilePrivacyTile,
                    onTap: () => context.push(AppRoutes.profilePrivacy),
                  ),
                  _NotificationsTile(
                    label: l10n.profileNotificationsTile,
                    subtitle: l10n.profileNotificationsSubtitle,
                    onTap: () =>
                        context.push(AppRoutes.profileNotificationSettings),
                  ),
                  _LocationTile(
                    label: l10n.profileLocationTile,
                    subtitle: l10n.profileLocationSubtitle,
                    onTap: () => context.push(AppRoutes.profileLocation),
                  ),
                  _LanguageTile(
                    label: l10n.profileLanguageTile,
                    subtitle: l10n.profileLanguageSubtitle,
                    onTap: () => context.push(AppRoutes.profileLanguage),
                  ),
                  _SafetyTile(
                    label: l10n.profileSafetyTile,
                    subtitle: l10n.profileSafetySubtitle,
                    onTap: () => context.push(AppRoutes.profileSafety),
                  ),
                  SizedBox(
                    height: AppSpacing.xxxl +
                        MediaQuery.of(context).padding.bottom,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SliverAppBar with first profile photo ─────────────────────────────────────

class _PhotoAppBar extends StatelessWidget {
  const _PhotoAppBar({
    required this.user,
    required this.onEdit,
    required this.onManagePhotos,
  });

  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onManagePhotos;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: AppColors.surface,
      title: Text(user.nickname, style: AppTypography.bodyMedium),
      actions: [
        IconButton(
          icon: const Icon(Icons.photo_library_outlined),
          tooltip: 'Manage photos',
          onPressed: onManagePhotos,
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit profile',
          onPressed: onEdit,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: user.profileImages.isEmpty
            ? const _AvatarPlaceholder()
            : CachedNetworkImage(
                imageUrl: user.profileImages.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) =>
                    const ColoredBox(color: AppColors.primaryLight),
                errorWidget: (context, url, error) =>
                    const _AvatarPlaceholder(),
              ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.primaryLight,
      child: Center(
        child: Icon(Icons.person_rounded, size: 96, color: AppColors.primary),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// Computes current age from birthDate at render time so it never goes stale.
// user.age is stored in Firestore for query purposes only; never use it for UI.
int _ageFromBirthDate(DateTime birthDate) {
  final now = DateTime.now();
  int age = now.year - birthDate.year;
  if (now.month < birthDate.month ||
      (now.month == birthDate.month && now.day < birthDate.day)) {
    age--;
  }
  return age;
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _NameRow extends StatelessWidget {
  const _NameRow({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(user.nickname, style: AppTypography.heading),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${_ageFromBirthDate(user.birthDate)}',
          style: AppTypography.subtitle.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _IdentityBadge extends StatelessWidget {
  const _IdentityBadge({required this.identity});

  final String identity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppRadius.pillBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          identity,
          style: AppTypography.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.city});

  final String city;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(city, style: AppTypography.caption),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.label.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _NotificationsTile extends StatelessWidget {
  const _NotificationsTile({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.notifications_outlined,
        color: AppColors.textSecondary,
      ),
      title: Text(label, style: AppTypography.body),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _PrivacyTile extends StatelessWidget {
  const _PrivacyTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.lock_outline,
        color: AppColors.textSecondary,
      ),
      title: Text(label, style: AppTypography.body),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.location_on_outlined,
        color: AppColors.textSecondary,
      ),
      title: Text(label, style: AppTypography.body),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.language_outlined,
        color: AppColors.textSecondary,
      ),
      title: Text(label, style: AppTypography.body),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _SafetyTile extends StatelessWidget {
  const _SafetyTile({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.shield_outlined,
        color: AppColors.textSecondary,
      ),
      title: Text(label, style: AppTypography.body),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.goal});

  final String goal;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: AppRadius.pillBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          goal,
          style: AppTypography.caption.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
