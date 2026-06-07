import 'dart:io';

import 'package:bloom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../providers/onboarding_provider.dart';
import '../gradient_button.dart';

class PhotoUploadStep extends ConsumerWidget {
  const PhotoUploadStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  Future<void> _pickPhoto(WidgetRef ref) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (file != null) {
      ref.read(onboardingProvider.notifier).addPhoto(file.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingProvider).valueOrNull;
    final photoPaths = state?.photoPaths ?? <String>[];
    final canProceed = photoPaths.isNotEmpty;
    final canAddMore = photoPaths.length < AppConstants.maxProfilePhotos;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.onboardingPhotosTitle, style: AppTypography.heading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.onboardingPhotosBody(AppConstants.maxProfilePhotos),
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: photoPaths.isEmpty
                ? _EmptyPhotoSlot(
                    label: l10n.onboardingTapToAddPhoto,
                    onTap: () => _pickPhoto(ref),
                  )
                : _PhotoList(
                    photoPaths: photoPaths,
                    primaryLabel: l10n.onboardingPhotoPrimary,
                    addLabel: l10n.addPhoto,
                    canAddMore: canAddMore,
                    onAdd: () => _pickPhoto(ref),
                    onRemove: (i) =>
                        ref.read(onboardingProvider.notifier).removePhoto(i),
                    onReorder: (o, n) => ref
                        .read(onboardingProvider.notifier)
                        .reorderPhotos(o, n),
                  ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: l10n.continueAction,
            onPressed: canProceed ? onNext : null,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _EmptyPhotoSlot extends StatelessWidget {
  const _EmptyPhotoSlot({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.primary, size: 48),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: const TextStyle(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _PhotoList extends StatelessWidget {
  const _PhotoList({
    required this.photoPaths,
    required this.primaryLabel,
    required this.addLabel,
    required this.canAddMore,
    required this.onAdd,
    required this.onRemove,
    required this.onReorder,
  });

  final List<String> photoPaths;
  final String primaryLabel;
  final String addLabel;
  final bool canAddMore;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final void Function(int, int) onReorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photoPaths.length,
            onReorderItem: onReorder,
            itemBuilder: (_, index) {
              return _PhotoCard(
                key: ValueKey(photoPaths[index]),
                path: photoPaths[index],
                isPrimary: index == 0,
                primaryLabel: primaryLabel,
                onRemove: () => onRemove(index),
              );
            },
          ),
        ),
        if (canAddMore) ...[
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
            label: Text(
              addLabel,
              style: AppTypography.label.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    super.key,
    required this.path,
    required this.isPrimary,
    required this.primaryLabel,
    required this.onRemove,
  });

  final String path;
  final bool isPrimary;
  final String primaryLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(path),
              width: 120,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          if (isPrimary)
            Positioned(
              bottom: AppSpacing.sm,
              left: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  primaryLabel,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
