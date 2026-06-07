import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../../explore/domain/models/discovery_profile.dart';

class MatchCelebrationSheet extends StatelessWidget {
  const MatchCelebrationSheet({
    super.key,
    required this.profile,
    required this.onKeepExploring,
  });

  final DiscoveryProfile? profile;
  final VoidCallback onKeepExploring;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = profile?.nickname ?? l10n.matchCelebrationFallbackName;
    final age = profile?.age;
    final primaryPhoto =
        (profile?.profileImages.isNotEmpty ?? false) ? profile!.profileImages.first : null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.modalBorder,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.divider,
              borderRadius: AppRadius.pillBorder,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Celebration icon with gradient tint
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: const Icon(
              Icons.favorite_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text(
            l10n.matchCelebrationTitle,
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Subtitle
          Text(
            l10n.matchCelebrationSubtitle(name),
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Profile avatar
          if (primaryPhoto != null)
            ClipOval(
              child: Image.network(
                primaryPhoto,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _AvatarPlaceholder(name: name),
              ),
            )
          else
            _AvatarPlaceholder(name: name),
          const SizedBox(height: AppSpacing.md),

          // Name and optional age
          Text(
            age != null ? '$name, $age' : name,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Keep exploring button
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: l10n.matchCelebrationKeepExploring,
              onPressed: onKeepExploring,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTypography.heading.copyWith(
            color: AppColors.white,
            fontSize: 36,
          ),
        ),
      ),
    );
  }
}
