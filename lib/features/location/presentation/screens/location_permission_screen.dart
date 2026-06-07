import 'dart:async';

import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../providers/location_permission_provider.dart';
import '../providers/location_update_provider.dart';

// ── File-private helpers ──────────────────────────────────────────────────────

IconData _iconFor(LocationPermissionStatus status) => switch (status) {
      LocationPermissionStatus.granted => Icons.check_circle_outline,
      LocationPermissionStatus.serviceDisabled =>
        Icons.location_disabled_outlined,
      LocationPermissionStatus.deniedForever => Icons.lock_outline,
      _ => Icons.location_on_outlined,
    };

Color _iconColorFor(LocationPermissionStatus status) => switch (status) {
      LocationPermissionStatus.granted => AppColors.primary,
      LocationPermissionStatus.serviceDisabled => AppColors.warning,
      _ => AppColors.textSecondary,
    };

String _statusMessageFor(
        LocationPermissionStatus status, AppLocalizations l10n) =>
    switch (status) {
      LocationPermissionStatus.granted => l10n.locationPermissionGrantedStatus,
      LocationPermissionStatus.serviceDisabled =>
        l10n.locationPermissionServiceDisabled,
      LocationPermissionStatus.deniedForever =>
        l10n.locationPermissionDeniedForever,
      _ => l10n.locationPermissionDenied,
    };

String _actionLabelFor(
        LocationPermissionStatus status, AppLocalizations l10n) =>
    switch (status) {
      LocationPermissionStatus.serviceDisabled => l10n.openLocationSettings,
      LocationPermissionStatus.deniedForever => l10n.openAppSettings,
      _ => l10n.locationPermissionAllow,
    };

Future<void> _handleAction(
  LocationPermissionStatus status,
  LocationPermissionNotifier notifier,
) =>
    switch (status) {
      LocationPermissionStatus.serviceDisabled =>
        notifier.openLocationSettings(),
      LocationPermissionStatus.deniedForever => notifier.openAppSettings(),
      _ => notifier.requestPermission(),
    };

String _updateErrorMessage(UpdateLocationError error, AppLocalizations l10n) =>
    switch (error) {
      UpdateLocationError.serviceDisabled =>
        l10n.locationServiceDisabledForUpdate,
      UpdateLocationError.permissionDenied =>
        l10n.locationPermissionRequiredForUpdate,
      _ => l10n.locationUpdateFailed,
    };

/// Returns a localised relative-time string for the last-updated timestamp.
/// Uses the [timeago] package for natural language formatting in both
/// English and Korean. Coordinates are never accessed.
String _formatLastUpdated(
  DateTime? updatedAt,
  AppLocalizations l10n,
  String languageCode,
) {
  if (updatedAt == null) return l10n.locationNotUpdatedYet;
  final relative = timeago.format(updatedAt, locale: languageCode);
  return l10n.locationLastUpdated(relative);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class LocationPermissionScreen extends ConsumerWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final state = ref.watch(locationPermissionProvider);
    final notifier = ref.read(locationPermissionProvider.notifier);
    final updateState = ref.watch(locationUpdateProvider);
    final updateNotifier = ref.read(locationUpdateProvider.notifier);

    // Null while loading; DateTime? when stream emits.
    final lastUpdatedAt =
        ref.watch(lastLocationUpdatedAtProvider).valueOrNull;

    // Permission-check/request errors.
    ref.listen<LocationPermissionState>(locationPermissionProvider,
        (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    // Location-update completion: success SnackBar or typed-error SnackBar.
    ref.listen<LocationUpdateState>(locationUpdateProvider, (prev, next) {
      if (prev?.isUpdating == true && !next.isUpdating) {
        if (next.error == null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                SnackBar(content: Text(l10n.locationUpdateSuccess)));
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(_updateErrorMessage(next.error!, l10n)),
            ));
        }
      }
    });

    final granted = state.status == LocationPermissionStatus.granted;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(l10n.locationPermissionTitle),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status icon ─────────────────────────────────────────────────
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: state.isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    : Icon(
                        _iconFor(state.status),
                        size: 48,
                        color: _iconColorFor(state.status),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Title ───────────────────────────────────────────────────────
            Text(
              l10n.locationPermissionMainTitle,
              style: AppTypography.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Privacy body ────────────────────────────────────────────────
            Text(
              l10n.locationPermissionBody,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Status card ─────────────────────────────────────────────────
            if (!state.isLoading)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: granted ? AppColors.primaryLight : AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: AppRadius.cardBorder,
                ),
                child: Text(
                  _statusMessageFor(state.status, l10n),
                  style: AppTypography.caption.copyWith(
                    color: granted
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Action area ─────────────────────────────────────────────────
            if (granted && !state.isLoading) ...[
              // "Permission granted" label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.locationPermissionGrantedLabel,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Last-updated caption ───────────────────────────────────
              // Shows relative time of last successful update (timestamp only;
              // no coordinates are exposed).
              Text(
                _formatLastUpdated(lastUpdatedAt, l10n, locale),
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // "Update location" button
              GradientButton(
                label: l10n.locationUpdateButton,
                isLoading: updateState.isUpdating,
                onPressed: updateState.isUpdating
                    ? null
                    : () => unawaited(
                          updateNotifier.updateCurrentLocation(),
                        ),
              ),
            ] else if (!state.isLoading)
              GradientButton(
                label: _actionLabelFor(state.status, l10n),
                isLoading: state.isLoading,
                onPressed: state.isLoading
                    ? null
                    : () => unawaited(
                          _handleAction(state.status, notifier),
                        ),
              ),
          ],
        ),
      ),
    );
  }
}
