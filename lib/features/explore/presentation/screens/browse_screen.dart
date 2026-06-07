import 'dart:async';

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
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/models/compatibility_score.dart';
import '../../domain/models/discovery_profile.dart';
import '../../domain/services/compatibility_score_calculator.dart';
import '../providers/browse_feed_provider.dart';
import '../providers/discovery_filters_provider.dart';
import '../widgets/discovery_filter_sheet.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 300) return;
    final s = ref.read(browseFeedProvider);
    if (!s.isLoading && !s.isLoadingMore && s.hasMore) {
      unawaited(ref.read(browseFeedProvider.notifier).loadMore());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(browseFeedProvider);
    final notifier = ref.read(browseFeedProvider.notifier);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    final activeFilterCount =
        ref.watch(discoveryFiltersProvider).activeCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(l10n.browseTitle, style: AppTypography.subtitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined,
                color: AppColors.textSecondary),
            tooltip: l10n.mapDiscoveryOpenMap,
            onPressed: () => context.push(AppRoutes.exploreMap),
          ),
          _FilterButton(
            activeCount: activeFilterCount,
            onTap: () => showDiscoveryFilterSheet(context),
          ),
          if (!state.isLoading)
            IconButton(
              icon: const Icon(Icons.refresh_outlined,
                  color: AppColors.textSecondary),
              tooltip: l10n.browseRefresh,
              onPressed: () => unawaited(notifier.refresh()),
            ),
        ],
      ),
      body: _buildBody(context, state, notifier, l10n, currentUser),
    );
  }

  Widget _buildBody(
    BuildContext context,
    BrowseFeedState state,
    BrowseFeedNotifier notifier,
    AppLocalizations l10n,
    UserModel? currentUser,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.needsLocation) {
      return _NeedsLocationView(l10n: l10n);
    }

    if (state.hasError) {
      return _ErrorView(
        l10n: l10n,
        onRetry: () => unawaited(notifier.refresh()),
      );
    }

    if (state.isEmpty) {
      return _EmptyView(
        l10n: l10n,
        onRefresh: () => unawaited(notifier.refresh()),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: notifier.refresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.only(
          bottom: AppSpacing.xl + MediaQuery.of(context).padding.bottom,
        ),
        itemCount: state.profiles.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          color: AppColors.divider,
          indent: AppSpacing.lg + _Thumbnail.size + AppSpacing.md,
        ),
        itemBuilder: (context, index) {
          if (index == state.profiles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          }
          return _ProfileRow(
            profile: state.profiles[index],
            l10n: l10n,
            currentUser: currentUser,
          );
        },
      ),
    );
  }
}

// ── Filter button with active-count badge ─────────────────────────────────────

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.onTap});

  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.tune_rounded,
            color: activeCount > 0
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
          if (activeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$activeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Profile row ───────────────────────────────────────────────────────────────

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.profile,
    required this.l10n,
    this.currentUser,
  });

  final DiscoveryProfile profile;
  final AppLocalizations l10n;
  final UserModel? currentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumbnail(
            imageUrl: profile.profileImages.isNotEmpty
                ? profile.profileImages.first
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _ProfileInfo(
              profile: profile,
              l10n: l10n,
              currentUser: currentUser,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Thumbnail ─────────────────────────────────────────────────────────────────

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.imageUrl});

  final String? imageUrl;

  static const double size = 90;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (imageUrl != null) {
      child = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => const ColoredBox(color: AppColors.primaryLight),
        errorWidget: (_, _, _) => const _AvatarFallback(),
      );
    } else {
      child = const _AvatarFallback();
    }

    return ClipRRect(
      borderRadius: AppRadius.cardBorder,
      child: SizedBox(width: size, height: size, child: child),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.primaryLight,
      child: Center(
        child: Icon(Icons.person_rounded, size: 44, color: AppColors.primary),
      ),
    );
  }
}

// ── Profile info ──────────────────────────────────────────────────────────────

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({
    required this.profile,
    required this.l10n,
    this.currentUser,
  });

  final DiscoveryProfile profile;
  final AppLocalizations l10n;
  final UserModel? currentUser;

  @override
  Widget build(BuildContext context) {
    final score = currentUser != null
        ? CompatibilityScoreCalculator.compute(
            currentUser: currentUser!,
            candidate: profile,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${profile.nickname}, ${profile.age}',
                style: AppTypography.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (profile.verificationLevel != 'none')
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: Tooltip(
                  message: l10n.browseVerified,
                  child: const Icon(
                    Icons.verified_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            if (profile.premium && profile.premiumBadgeVisible)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: Tooltip(
                  message: l10n.browsePremium,
                  child: const Icon(
                    Icons.workspace_premium_outlined,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            if (score != null)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: _ScoreChip(
                  score: score,
                  l10n: l10n,
                  onTap: () => _showCompatibilityReasonSheet(
                    context, score, l10n,
                  ),
                ),
              ),
          ],
        ),

        if (profile.identity.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          _IdentityChip(label: profile.identity),
        ],

        if (profile.city.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  profile.city,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        if (profile.bio.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            profile.bio,
            style: AppTypography.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        if (profile.interests.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: profile.interests
                .take(3)
                .map((tag) => _InterestTag(label: tag))
                .toList(),
          ),
        ],
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
          horizontal: AppSpacing.sm,
          vertical: 2,
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

class _InterestTag extends StatelessWidget {
  const _InterestTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.pillBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        child: Text(label, style: AppTypography.caption),
      ),
    );
  }
}

// ── Compatibility score chip (Browse rows) ────────────────────────────────────

void _showCompatibilityReasonSheet(
  BuildContext context,
  CompatibilityScore score,
  AppLocalizations l10n,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _CompatibilityReasonSheet(score: score, l10n: l10n),
  );
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.score,
    required this.l10n,
    required this.onTap,
  });

  final CompatibilityScore score;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  Color get _color {
    if (score.percentage >= 80) return AppColors.scoreHigh;
    if (score.percentage >= 50) return AppColors.scoreMedium;
    return AppColors.scoreLow;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: AppRadius.pillBorder,
          border: Border.all(color: _color.withValues(alpha: 0.45)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
          child: Text(
            '${score.percentage}%',
            style: AppTypography.captionMedium.copyWith(color: _color),
          ),
        ),
      ),
    );
  }
}

class _CompatibilityReasonSheet extends StatelessWidget {
  const _CompatibilityReasonSheet({required this.score, required this.l10n});

  final CompatibilityScore score;
  final AppLocalizations l10n;

  Color get _color {
    if (score.percentage >= 80) return AppColors.scoreHigh;
    if (score.percentage >= 50) return AppColors.scoreMedium;
    return AppColors.scoreLow;
  }

  IconData _iconFor(CompatibilityReason r) => switch (r) {
    CompatibilityReason.sharedInterests => Icons.interests_rounded,
    CompatibilityReason.relationshipGoal => Icons.favorite_border_rounded,
    CompatibilityReason.identityFit => Icons.person_outline_rounded,
    CompatibilityReason.ageRange => Icons.cake_outlined,
    CompatibilityReason.nearbyArea => Icons.location_on_outlined,
    CompatibilityReason.verified => Icons.verified_outlined,
  };

  String _labelFor(CompatibilityReason r) => switch (r) {
    CompatibilityReason.sharedInterests => l10n.compatibilityReasonSharedInterests,
    CompatibilityReason.relationshipGoal => l10n.compatibilityReasonRelationshipGoal,
    CompatibilityReason.identityFit => l10n.compatibilityReasonIdentityFit,
    CompatibilityReason.ageRange => l10n.compatibilityReasonAgeRange,
    CompatibilityReason.nearbyArea => l10n.compatibilityReasonNearbyArea,
    CompatibilityReason.verified => l10n.compatibilityReasonVerified,
  };

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return ClipRRect(
      borderRadius: AppRadius.modalBorder,
      child: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            bottomPadding + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.compatibilityAboutTitle, style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.compatibilityMatchPercent(score.percentage),
                style: AppTypography.label.copyWith(color: _color),
              ),
              if (score.reasons.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                ...score.reasons.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(_iconFor(r), size: 18, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(_labelFor(r), style: AppTypography.body),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (score.isApproximateDistanceUsed) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.compatibilityApproxNote,
                  style: AppTypography.caption,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.l10n, required this.onRefresh});

  final AppLocalizations l10n;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline_rounded,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.browseEmptyTitle,
                style: AppTypography.subtitle, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.browseEmptyBody,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            GradientButton(label: l10n.browseRefresh, onPressed: onRefresh),
          ],
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.l10n, required this.onRetry});

  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.browseErrorTitle,
                style: AppTypography.subtitle, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.browseErrorBody,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            GradientButton(label: l10n.browseRetry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

// ── Needs-location state ──────────────────────────────────────────────────────

class _NeedsLocationView extends StatelessWidget {
  const _NeedsLocationView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_outlined,
                size: 64, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.browseNeedsLocationTitle,
                style: AppTypography.subtitle, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.browseNeedsLocationBody,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            GradientButton(
              label: l10n.browseUpdateLocation,
              onPressed: () => context.push(AppRoutes.profileLocation),
            ),
          ],
        ),
      ),
    );
  }
}
