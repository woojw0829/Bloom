import 'dart:async';

import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../domain/models/nearby_user_count.dart';
import '../providers/map_discovery_provider.dart';
import '../providers/map_my_location_provider.dart';

class MapDiscoveryScreen extends ConsumerStatefulWidget {
  const MapDiscoveryScreen({super.key});

  @override
  ConsumerState<MapDiscoveryScreen> createState() => _MapDiscoveryScreenState();
}

class _MapDiscoveryScreenState extends ConsumerState<MapDiscoveryScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController?.dispose();
    _mapController = controller;
  }

  Future<void> _onMyLocationPressed() async {
    final pos = await ref
        .read(mapMyLocationProvider.notifier)
        .requestAndGetLocation();
    // pos is used only for camera animation — never logged or displayed as text.
    if (pos != null && mounted) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(pos.latitude, pos.longitude),
          13,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(mapDiscoveryProvider);
    final notifier = ref.read(mapDiscoveryProvider.notifier);
    final myLocationState = ref.watch(mapMyLocationProvider);

    // Show a brief snackbar when the device position is temporarily unavailable.
    ref.listen<MapMyLocationState>(
      mapMyLocationProvider,
      (prev, next) {
        if (next.error == MapMyLocationError.unavailable &&
            prev?.error != MapMyLocationError.unavailable) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.mapMyLocationUnavailable),
                duration: const Duration(seconds: 3),
              ),
            );
            ref.read(mapMyLocationProvider.notifier).clearError();
          });
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(l10n.mapDiscoveryTitle, style: AppTypography.subtitle),
        actions: [
          if (!state.isLoading)
            IconButton(
              icon: const Icon(Icons.refresh_outlined,
                  color: AppColors.textSecondary),
              onPressed: () => unawaited(notifier.refresh()),
            ),
        ],
      ),
      body: _buildBody(context, state, notifier, l10n, myLocationState),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MapDiscoveryState state,
    MapDiscoveryNotifier notifier,
    AppLocalizations l10n,
    MapMyLocationState myLocationState,
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

    final center = state.currentUserPoint;
    if (center == null) {
      return _NeedsLocationView(l10n: l10n);
    }

    return _MapContent(
      l10n: l10n,
      state: state,
      initialTarget: LatLng(center.lat, center.lng),
      onMapCreated: _onMapCreated,
      myLocationHasPermission: myLocationState.hasPermission,
      isLocating: myLocationState.isChecking,
      locationError: myLocationState.error,
      onMyLocationPressed: _onMyLocationPressed,
      onOpenSettings: () =>
          unawaited(ref.read(mapMyLocationProvider.notifier).openSettings()),
      onOpenLocationSettings: () => unawaited(
          ref.read(mapMyLocationProvider.notifier).openLocationSettings()),
    );
  }
}

// ── Map widget ────────────────────────────────────────────────────────────────

class _MapContent extends StatelessWidget {
  const _MapContent({
    required this.l10n,
    required this.state,
    required this.initialTarget,
    required this.onMapCreated,
    required this.myLocationHasPermission,
    required this.isLocating,
    this.locationError,
    required this.onMyLocationPressed,
    required this.onOpenSettings,
    required this.onOpenLocationSettings,
  });

  final AppLocalizations l10n;
  final MapDiscoveryState state;
  final LatLng initialTarget;
  final void Function(GoogleMapController) onMapCreated;
  final bool myLocationHasPermission;
  final bool isLocating;
  final MapMyLocationError? locationError;
  final Future<void> Function() onMyLocationPressed;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenLocationSettings;

  Set<Circle> _buildRadiusCircle(LatLng center) {
    return {
      Circle(
        circleId: const CircleId('nearby_radius'),
        center: center,
        // 5 km in metres — matches the fixed search radius.
        radius: 5000,
        fillColor: AppColors.primary.withValues(alpha: 0.07),
        strokeColor: AppColors.primary.withValues(alpha: 0.35),
        strokeWidth: 1,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    // Count card sits above the my-location button.
    final cardBottom = safeBottom + AppSpacing.sm + 44 + AppSpacing.sm;

    final showPermissionCard = locationError != null &&
        locationError != MapMyLocationError.unavailable;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialTarget,
            // Zoom ~12 shows the 5 km radius area clearly.
            zoom: 12,
          ),
          // No user markers — individual user positions are never shown.
          markers: const {},
          // 5 km radius circle centred on the current user's approximate location.
          circles: _buildRadiusCircle(initialTarget),
          // Show the device blue-dot only when permission is confirmed granted.
          // Rendered locally only — never exposed to other users or Firestore.
          myLocationEnabled: myLocationHasPermission,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          compassEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: onMapCreated,
        ),

        // Privacy notice — top left, non-intrusive.
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          child: _PrivacyNote(l10n: l10n),
        ),

        // Permission card or nearby count card — above the my-location button.
        if (showPermissionCard)
          Positioned(
            bottom: cardBottom,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            child: _LocationPermissionCard(
              l10n: l10n,
              error: locationError!,
              onAllow: () => unawaited(onMyLocationPressed()),
              onOpenSettings: onOpenSettings,
              onOpenLocationSettings: onOpenLocationSettings,
            ),
          )
        else if (state.nearbyCount != null)
          Positioned(
            bottom: cardBottom,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            child: _NearbyCountCard(l10n: l10n, count: state.nearbyCount!),
          ),

        // My location button — bottom right, always visible.
        Positioned(
          bottom: safeBottom + AppSpacing.sm,
          right: AppSpacing.md,
          child: _MyLocationButton(
            label: l10n.mapMyLocation,
            isLoading: isLocating,
            onPressed: onMyLocationPressed,
          ),
        ),
      ],
    );
  }
}

// ── Nearby count card ─────────────────────────────────────────────────────────

class _NearbyCountCard extends StatelessWidget {
  const _NearbyCountCard({required this.l10n, required this.count});

  final AppLocalizations l10n;
  final NearbyUserCount count;

  String _countLabel() {
    return switch (count.bucket) {
      NearbyCountBucket.none => l10n.mapNearbyNoUsers,
      NearbyCountBucket.fewerThanFive => l10n.mapNearbyFewerThanFive,
      NearbyCountBucket.fivePlus => l10n.mapNearbyCountPlus(5),
      NearbyCountBucket.tenPlus => l10n.mapNearbyCountPlus(10),
      NearbyCountBucket.fifteenPlus => l10n.mapNearbyCountPlus(15),
      NearbyCountBucket.twentyPlus => l10n.mapNearbyCountPlus(20),
      NearbyCountBucket.twentyFivePlus => l10n.mapNearbyCountPlus(25),
      NearbyCountBucket.thirtyPlus => l10n.mapNearbyCountPlus(30),
      NearbyCountBucket.thirtyFivePlus => l10n.mapNearbyCountPlus(35),
      NearbyCountBucket.fortyPlus => l10n.mapNearbyCountPlus(40),
      NearbyCountBucket.fortyFivePlus => l10n.mapNearbyCountPlus(45),
      NearbyCountBucket.fiftyPlus => l10n.mapNearbyCountPlus(50),
    };
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(l10n.mapNearbyTitle, style: AppTypography.bodyMedium),
                const Spacer(),
                Text(
                  l10n.mapNearbyRadiusLabel(count.radiusKm),
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _countLabel(),
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.mapNearbyPrivacyNotice,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── My location button ────────────────────────────────────────────────────────

class _MyLocationButton extends StatelessWidget {
  const _MyLocationButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: isLoading ? null : () => unawaited(onPressed()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(
                    Icons.my_location_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                const SizedBox(width: AppSpacing.xs + 2),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Privacy note ──────────────────────────────────────────────────────────────

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 12,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              l10n.mapNearbyPrivacyNotice,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Location permission card ──────────────────────────────────────────────────

class _LocationPermissionCard extends StatelessWidget {
  const _LocationPermissionCard({
    required this.l10n,
    required this.error,
    required this.onAllow,
    required this.onOpenSettings,
    required this.onOpenLocationSettings,
  });

  final AppLocalizations l10n;
  final MapMyLocationError error;
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    final isDeniedForever = error == MapMyLocationError.permissionDeniedForever;
    final isServiceDisabled = error == MapMyLocationError.serviceDisabled;

    final actionLabel = isServiceDisabled
        ? l10n.openLocationSettings
        : isDeniedForever
            ? l10n.openAppSettings
            : l10n.mapMyLocationPermissionAction;
    final onAction = isServiceDisabled
        ? onOpenLocationSettings
        : isDeniedForever
            ? onOpenSettings
            : onAllow;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_off_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.mapMyLocationPermissionTitle,
                    style: AppTypography.captionMedium,
                  ),
                  Text(
                    l10n.mapMyLocationPermissionBody,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                minimumSize: const Size(44, 44),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel,
                style: AppTypography.captionMedium
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── State views ───────────────────────────────────────────────────────────────

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
            Text(l10n.mapDiscoveryErrorTitle,
                style: AppTypography.subtitle, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.mapNearbyLoadFailed,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            GradientButton(label: l10n.mapDiscoveryRetry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

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
            Text(l10n.mapDiscoveryNeedsLocationTitle,
                style: AppTypography.subtitle, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.mapDiscoveryNeedsLocationBody,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            GradientButton(
              label: l10n.mapDiscoveryUpdateLocation,
              onPressed: () => context.push(AppRoutes.profileLocation),
            ),
          ],
        ),
      ),
    );
  }
}
