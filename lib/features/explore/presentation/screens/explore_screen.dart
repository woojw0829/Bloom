import 'dart:async';

import 'package:bloom/l10n/app_localizations.dart';
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
import '../../../match/domain/models/swipe_action.dart';
import '../../../match/presentation/providers/match_celebration_provider.dart';
import '../../../match/presentation/widgets/match_celebration_sheet.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/models/discovery_profile.dart';
import '../providers/discovery_feed_provider.dart';
import '../providers/discovery_filters_provider.dart';
import '../widgets/discovery_card.dart';
import '../widgets/discovery_filter_sheet.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _swipeKey = GlobalKey<_SwipeStackState>();

  void _showMatchCelebration(MatchCelebrationState celebrationState) {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => MatchCelebrationSheet(
        profile: celebrationState.pendingLikedProfile,
        onKeepExploring: () {
          Navigator.of(context).pop();
          ref.read(matchCelebrationProvider.notifier).clearCelebration();
        },
      ),
    );
  }

  void _onSwipeAction(DiscoveryFeedNotifier notifier, SwipeAction action) {
    notifier.dismissTopWithAction(action);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final msg = switch (action) {
      SwipeAction.pass => l10n.swipePassedFeedback,
      SwipeAction.like => l10n.swipeLikedFeedback,
      SwipeAction.superLike => l10n.swipeSuperLikedFeedback,
    };
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MatchCelebrationState>(
      matchCelebrationProvider,
      (prev, next) {
        if (next.hasCelebration && !(prev?.hasCelebration ?? false)) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showMatchCelebration(next),
          );
        }
      },
    );

    final l10n = AppLocalizations.of(context);
    final state = ref.watch(discoveryFeedProvider);
    final notifier = ref.read(discoveryFeedProvider.notifier);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final activeFilterCount = ref.watch(discoveryFiltersProvider).activeCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(l10n.exploreTitle, style: AppTypography.subtitle),
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
              tooltip: l10n.exploreRefresh,
              onPressed: () => unawaited(notifier.refresh()),
            ),
        ],
      ),
      body: _buildBody(context, state, notifier, l10n, currentUser),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DiscoveryFeedState state,
    DiscoveryFeedNotifier notifier,
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

    // Stack temporarily exhausted while the next page is loading.
    if (state.remaining.isEmpty && state.isLoadingMore) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.isEmpty) {
      return _EmptyView(
        l10n: l10n,
        onRefresh: () => unawaited(notifier.refresh()),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xl + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          Expanded(
            child: _SwipeStack(
              key: _swipeKey,
              profiles: state.remaining,
              onAction: (action) => _onSwipeAction(notifier, action),
              currentUser: currentUser,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ActionButtons(
            enabled: state.remaining.isNotEmpty,
            l10n: l10n,
            onPass: () => _swipeKey.currentState?.dismiss(SwipeAction.pass),
            onLike: () => _swipeKey.currentState?.dismiss(SwipeAction.like),
            onSuperLike: () =>
                _swipeKey.currentState?.dismiss(SwipeAction.superLike),
          ),
          if (state.isLoadingMore)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
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

// ── Action buttons (Pass / Super Like / Like) ─────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.enabled,
    required this.l10n,
    required this.onPass,
    required this.onLike,
    required this.onSuperLike,
  });

  final bool enabled;
  final AppLocalizations l10n;
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onSuperLike;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.close_rounded,
          color: AppColors.swipePass,
          size: 56,
          onTap: enabled ? onPass : null,
          tooltip: l10n.swipePass,
        ),
        const SizedBox(width: AppSpacing.xxl),
        _ActionButton(
          icon: Icons.star_rounded,
          color: AppColors.swipeSuperLike,
          size: 48,
          onTap: enabled ? onSuperLike : null,
          tooltip: l10n.swipeSuperLike,
        ),
        const SizedBox(width: AppSpacing.xxl),
        _ActionButton(
          icon: Icons.favorite_rounded,
          color: AppColors.primary,
          size: 56,
          onTap: enabled ? onLike : null,
          tooltip: l10n.swipeLike,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isEnabled ? 0.25 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isEnabled
                  ? color.withValues(alpha: 0.3)
                  : AppColors.divider,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: isEnabled ? color : AppColors.textDisabled,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }
}

// ── Swipe stack ───────────────────────────────────────────────────────────────

class _SwipeStack extends StatefulWidget {
  const _SwipeStack({
    super.key,
    required this.profiles,
    required this.onAction,
    this.currentUser,
  });

  final List<DiscoveryProfile> profiles;
  final void Function(SwipeAction) onAction;
  final UserModel? currentUser;

  @override
  State<_SwipeStack> createState() => _SwipeStackState();
}

class _SwipeStackState extends State<_SwipeStack>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  bool _isDismissing = false;
  SwipeAction _pendingAction = SwipeAction.like;
  late final AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _animation = const AlwaysStoppedAnimation(Offset.zero);
    _controller.addListener(() {
      setState(() => _offset = _animation.value);
    });
    _controller.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isDismissing) {
      _isDismissing = false;
      widget.onAction(_pendingAction);
      // _offset is reset in didUpdateWidget when the new top card arrives.
    }
  }

  @override
  void didUpdateWidget(_SwipeStack old) {
    super.didUpdateWidget(old);
    // Reset drag state when the top card changes (new card after dismiss or refresh).
    final newTopId =
        widget.profiles.isEmpty ? null : widget.profiles[0].id;
    final oldTopId =
        old.profiles.isEmpty ? null : old.profiles[0].id;
    if (newTopId != oldTopId) {
      _controller.stop();
      _isDismissing = false;
      _offset = Offset.zero;
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_controller.isAnimating) return;
    setState(() => _offset += d.delta);
  }

  void _onPanEnd(DragEndDetails d) {
    if (_controller.isAnimating) return;
    final w = MediaQuery.of(context).size.width;
    final threshold = w * 0.35;
    final velX = d.velocity.pixelsPerSecond.dx;

    if (_offset.dx.abs() > threshold || velX.abs() > 800) {
      _dismissOffScreen(velX);
    } else {
      _snapBack();
    }
  }

  void _dismissOffScreen(double velocityX) {
    final w = MediaQuery.of(context).size.width;
    final dir = (_offset.dx >= 0 || velocityX > 0) ? 1.0 : -1.0;
    _pendingAction = dir > 0 ? SwipeAction.like : SwipeAction.pass;
    _isDismissing = true;
    _animation = Tween<Offset>(
      begin: _offset,
      end: Offset(dir * w * 1.6, _offset.dy + dir * 40),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward(from: 0);
  }

  void _snapBack() {
    _animation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward(from: 0);
  }

  /// Called by action buttons to dismiss the current card with a specific [action].
  void dismiss(SwipeAction action) {
    if (_controller.isAnimating || _isDismissing) return;
    if (widget.profiles.isEmpty) return;
    final size = MediaQuery.of(context).size;
    _pendingAction = action;
    _isDismissing = true;
    if (action == SwipeAction.superLike) {
      _animation = Tween<Offset>(
        begin: _offset,
        end: Offset(_offset.dx, -size.height * 1.5),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    } else {
      final dir = action == SwipeAction.pass ? -1.0 : 1.0;
      _animation = Tween<Offset>(
        begin: _offset,
        end: Offset(dir * size.width * 1.6, _offset.dy + dir * 40),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = widget.profiles;
    if (profiles.isEmpty) return const SizedBox.shrink();

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    // Rotation: up to ~14° at full screen width.
    final angle = (_offset.dx / w) * 0.25;
    // Second card rises and scales as first is dragged.
    final progress = (_offset.dx.abs() / (w * 0.4)).clamp(0.0, 1.0);
    final backScale = 0.95 + 0.05 * progress;
    final backTranslateY = 12.0 * (1.0 - progress);
    // Like / pass overlay opacity (horizontal drag).
    final likeOpacity = (_offset.dx / (w * 0.4)).clamp(0.0, 1.0);
    final passOpacity = (-_offset.dx / (w * 0.4)).clamp(0.0, 1.0);
    // Super like overlay: appears during upward dismiss animation.
    final superLikeOpacity =
        (_pendingAction == SwipeAction.superLike && _isDismissing)
            ? ((-_offset.dy) / (h * 0.15)).clamp(0.0, 1.0)
            : 0.0;

    return Stack(
      children: [
        // Second card (behind, slightly smaller and shifted down)
        if (profiles.length > 1)
          Positioned.fill(
            child: IgnorePointer(
              child: Transform.translate(
                offset: Offset(0, backTranslateY),
                child: Transform.scale(
                  scale: backScale,
                  child: DiscoveryCard(
                    profile: profiles[1],
                    currentUser: widget.currentUser,
                  ),
                ),
              ),
            ),
          ),

        // Top card (interactive)
        Positioned.fill(
          child: GestureDetector(
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Transform.translate(
              offset: _offset,
              child: Transform.rotate(
                angle: angle,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DiscoveryCard(
                      profile: profiles[0],
                      currentUser: widget.currentUser,
                    ),

                    // Like overlay (right swipe)
                    if (likeOpacity > 0)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: AppRadius.profileCardBorder,
                          child: ColoredBox(
                            color: AppColors.swipeLike
                                .withValues(alpha: likeOpacity * 0.35),
                          ),
                        ),
                      ),

                    // Pass overlay (left swipe)
                    if (passOpacity > 0)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: AppRadius.profileCardBorder,
                          child: ColoredBox(
                            color: AppColors.swipePass
                                .withValues(alpha: passOpacity * 0.35),
                          ),
                        ),
                      ),

                    // Super like overlay (upward dismiss from button)
                    if (superLikeOpacity > 0)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: AppRadius.profileCardBorder,
                          child: ColoredBox(
                            color: AppColors.swipeSuperLike
                                .withValues(alpha: superLikeOpacity * 0.35),
                          ),
                        ),
                      ),

                    // Direction label — LIKE
                    if (likeOpacity > 0.15)
                      Positioned(
                        top: AppSpacing.xl,
                        left: AppSpacing.xl,
                        child: _DirectionLabel(
                          icon: Icons.favorite_rounded,
                          color: AppColors.swipeLike,
                          opacity: likeOpacity,
                        ),
                      ),
                    // Direction label — PASS
                    if (passOpacity > 0.15)
                      Positioned(
                        top: AppSpacing.xl,
                        right: AppSpacing.xl,
                        child: _DirectionLabel(
                          icon: Icons.close_rounded,
                          color: AppColors.swipePass,
                          opacity: passOpacity,
                        ),
                      ),
                    // Direction label — SUPER LIKE
                    if (superLikeOpacity > 0.15)
                      Positioned(
                        top: AppSpacing.xl,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _DirectionLabel(
                            icon: Icons.star_rounded,
                            color: AppColors.swipeSuperLike,
                            opacity: superLikeOpacity,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DirectionLabel extends StatelessWidget {
  const _DirectionLabel({
    required this.icon,
    required this.color,
    required this.opacity,
  });

  final IconData icon;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2.5),
          borderRadius: AppRadius.cardBorder,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Icon(icon, color: color, size: 32),
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
            const Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.exploreEmptyTitle,
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.exploreEmptyBody,
              style: AppTypography.body
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            GradientButton(label: l10n.exploreRefresh, onPressed: onRefresh),
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
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.exploreErrorTitle,
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.exploreErrorBody,
              style: AppTypography.body
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            GradientButton(label: l10n.exploreRetry, onPressed: onRetry),
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
            const Icon(
              Icons.location_off_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.exploreNeedsLocationTitle,
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.exploreNeedsLocationBody,
              style: AppTypography.body
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            GradientButton(
              label: l10n.exploreUpdateLocation,
              onPressed: () => context.push(AppRoutes.profileLocation),
            ),
          ],
        ),
      ),
    );
  }
}
