import 'dart:async';

import 'package:bloom/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/profile_photos_provider.dart';

class ProfilePhotoManagementScreen extends ConsumerWidget {
  const ProfilePhotoManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(profilePhotosProvider);
    final notifier = ref.read(profilePhotosProvider.notifier);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    ref.listen<ProfilePhotosState>(profilePhotosProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(l10n.managePhotosTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              0,
            ),
            child: Text(
              l10n.managePhotosHint,
              style:
                  AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: state.photos.isEmpty
                ? _EmptyState(
                    l10n: l10n,
                    isBusy: state.isBusy,
                    onAdd: () => unawaited(notifier.addPhoto()),
                  )
                : ReorderableListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.xl + bottomPad,
                    ),
                    buildDefaultDragHandles: false,
                    itemCount: state.photos.length,
                    onReorderItem: state.isBusy
                        ? (_, _) {}
                        : (oldIndex, newIndex) => unawaited(
                              notifier.reorderPhotos(oldIndex, newIndex),
                            ),
                    itemBuilder: (context, index) {
                      final url = state.photos[index];
                      return _PhotoTile(
                        key: ValueKey(url),
                        l10n: l10n,
                        index: index,
                        url: url,
                        isPrimary: index == 0,
                        isBusy: state.isBusy,
                        canDelete: state.photos.length > 1,
                        onDelete: () =>
                            unawaited(notifier.deletePhoto(index)),
                        onSetPrimary: index == 0
                            ? null
                            : () =>
                                unawaited(notifier.setPrimary(index)),
                      );
                    },
                  ),
          ),
          if (state.photos.length < AppConstants.maxProfilePhotos)
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.lg + bottomPad,
              ),
              child: OutlinedButton.icon(
                onPressed:
                    state.isBusy ? null : () => unawaited(notifier.addPhoto()),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(
                  l10n.managePhotosAddButton(
                    state.photos.length,
                    AppConstants.maxProfilePhotos,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Photo tile ────────────────────────────────────────────────────────────────

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    super.key,
    required this.l10n,
    required this.index,
    required this.url,
    required this.isPrimary,
    required this.isBusy,
    required this.canDelete,
    required this.onDelete,
    this.onSetPrimary,
  });

  final AppLocalizations l10n;
  final int index;
  final String url;
  final bool isPrimary;
  final bool isBusy;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback? onSetPrimary;

  @override
  Widget build(BuildContext context) {
    final hasMenu = !isBusy && (onSetPrimary != null || canDelete);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            enabled: !isBusy,
            child: const Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: Icon(Icons.drag_handle, color: AppColors.textSecondary),
            ),
          ),
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: url,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  const ColoredBox(color: AppColors.primaryLight),
              errorWidget: (_, _, _) => const ColoredBox(
                color: AppColors.primaryLight,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Primary badge
          Expanded(
            child: isPrimary
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.managePhotosPrimary,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Actions menu
          if (hasMenu)
            PopupMenuButton<_PhotoAction>(
              onSelected: (action) {
                if (action == _PhotoAction.setPrimary) onSetPrimary?.call();
                if (action == _PhotoAction.delete) onDelete();
              },
              itemBuilder: (_) => [
                if (onSetPrimary != null)
                  PopupMenuItem(
                    value: _PhotoAction.setPrimary,
                    child: Text(l10n.managePhotosSetAsPrimary),
                  ),
                if (canDelete)
                  PopupMenuItem(
                    value: _PhotoAction.delete,
                    child: Text(l10n.managePhotosDelete),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

enum _PhotoAction { setPrimary, delete }

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.l10n,
    required this.isBusy,
    required this.onAdd,
  });

  final AppLocalizations l10n;
  final bool isBusy;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.managePhotosEmpty,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: isBusy ? null : onAdd,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(l10n.addPhoto),
            ),
          ],
        ),
      ),
    );
  }
}
