import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/utils/verification_level_utils.dart';

enum VerificationBadgeSize { small, medium }

/// Displays a level-specific verification badge.
///
/// - 'photo'         → "Photo verified" (gradient pill or icon)
/// - 'government_id' → "Verified" (gradient pill or icon)
/// - 'none' / other  → [SizedBox.shrink]
///
/// Set [showLabel] to false to render an icon-only badge (with tooltip and
/// semantic label) suited for compact layouts such as browse list rows.
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({
    super.key,
    required this.verificationLevel,
    this.size = VerificationBadgeSize.small,
    this.showLabel = true,
  });

  final String verificationLevel;
  final VerificationBadgeSize size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final level = normalizedVerificationLevel(verificationLevel);
    if (level == 'none') return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final isPhoto = level == 'photo';
    final label =
        isPhoto ? l10n.verificationBadgePhoto : l10n.verificationBadgeVerified;
    final semantic = isPhoto
        ? l10n.verificationBadgePhotoSemantic
        : l10n.verificationBadgeVerifiedSemantic;

    if (!showLabel) {
      return Semantics(
        label: semantic,
        child: Tooltip(
          message: label,
          child: Icon(
            Icons.verified_outlined,
            size: size == VerificationBadgeSize.small ? 18.0 : 22.0,
            color: AppColors.primary,
          ),
        ),
      );
    }

    final iconSize = size == VerificationBadgeSize.small ? 14.0 : 16.0;

    return Semantics(
      label: semantic,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradient),
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
              Icon(Icons.verified_outlined,
                  size: iconSize, color: AppColors.white),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style:
                    AppTypography.captionMedium.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
