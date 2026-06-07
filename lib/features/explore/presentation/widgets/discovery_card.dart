import 'package:bloom/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/bloom_interest_chip.dart';
import '../../domain/models/compatibility_score.dart';
import '../../domain/models/discovery_profile.dart';
import '../../domain/services/compatibility_score_calculator.dart';

class DiscoveryCard extends StatelessWidget {
  const DiscoveryCard({
    super.key,
    required this.profile,
    this.currentUser,
  });

  final DiscoveryProfile profile;

  /// When provided, a compatibility score badge is shown at the top-left.
  /// Scoring is synchronous and uses only public fields — no Firestore access.
  final UserModel? currentUser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final score = currentUser != null
        ? CompatibilityScoreCalculator.compute(
            currentUser: currentUser!,
            candidate: profile,
          )
        : null;

    return ClipRRect(
      borderRadius: AppRadius.profileCardBorder,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Photo(imageUrl: profile.profileImages.isNotEmpty
              ? profile.profileImages.first
              : null),
          const _GradientOverlay(),
          // Compatibility score badge — top-left, non-interactive (swipe surface)
          if (score != null)
            Positioned(
              top: AppSpacing.xl,
              left: AppSpacing.xl,
              child: _ScoreBadge(score: score, l10n: l10n),
            ),
          Positioned(
            top: AppSpacing.xl,
            right: AppSpacing.xl,
            child: _BadgesColumn(profile: profile, l10n: l10n),
          ),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.xl,
            child: _CardInfo(profile: profile),
          ),
        ],
      ),
    );
  }
}

// ── Photo ─────────────────────────────────────────────────────────────────────

class _Photo extends StatelessWidget {
  const _Photo({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) return const _PhotoPlaceholder();
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, _) => const ColoredBox(color: AppColors.primaryLight),
      errorWidget: (_, _, _) => const _PhotoPlaceholder(),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

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

// ── Gradient overlay ──────────────────────────────────────────────────────────

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.45, 1.0],
          colors: [Color(0x00000000), Color(0xCC000000)],
        ),
      ),
    );
  }
}

// ── Badges (top-right) ────────────────────────────────────────────────────────

class _BadgesColumn extends StatelessWidget {
  const _BadgesColumn({required this.profile, required this.l10n});

  final DiscoveryProfile profile;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final showVerified = profile.verificationLevel != 'none';
    final showPremium = profile.premium && profile.premiumBadgeVisible;

    if (!showVerified && !showPremium) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showVerified)
          _Badge(
            icon: Icons.verified_outlined,
            label: l10n.exploreVerified,
            colors: AppColors.primaryGradient,
          ),
        if (showVerified && showPremium)
          const SizedBox(height: AppSpacing.xs),
        if (showPremium)
          _Badge(
            icon: Icons.workspace_premium_outlined,
            label: l10n.explorePremium,
            colors: AppColors.premiumGradient,
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: AppRadius.pillBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.white),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.captionMedium
                  .copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Score badge (top-left) ────────────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.l10n});

  final CompatibilityScore score;
  final AppLocalizations l10n;

  Color get _color {
    if (score.percentage >= 80) return AppColors.scoreHigh;
    if (score.percentage >= 50) return AppColors.scoreMedium;
    return AppColors.scoreLow;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.82),
        borderRadius: AppRadius.pillBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          l10n.compatibilityMatchPercent(score.percentage),
          style: AppTypography.captionMedium.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}

// ── Card info (bottom overlay) ────────────────────────────────────────────────

class _CardInfo extends StatelessWidget {
  const _CardInfo({required this.profile});

  final DiscoveryProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name + age
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                profile.nickname,
                style: AppTypography.heading.copyWith(color: AppColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${profile.age}',
              style:
                  AppTypography.subtitle.copyWith(color: AppColors.white),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Identity chip
        if (profile.identity.isNotEmpty) ...[
          _IdentityChip(label: profile.identity),
          const SizedBox(height: AppSpacing.xs),
        ],

        // City
        if (profile.city.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.white),
              const SizedBox(width: AppSpacing.xs),
              Text(
                profile.city,
                style: AppTypography.caption.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Interests (up to 4)
        if (profile.interests.isNotEmpty)
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: profile.interests
                .take(4)
                .map((i) => BloomInterestChip(
                      label: i,
                      selected: true,
                      readOnly: true,
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class _IdentityChip extends StatelessWidget {
  const _IdentityChip({required this.label});

  final String label;

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
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
