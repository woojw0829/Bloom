import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/usecases/update_profile_photos_use_case.dart';
import 'profile_providers.dart';
import 'user_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

/// Transient state for the photo management screen.
/// Lives only while [ProfilePhotoManagementScreen] is in the tree.
class ProfilePhotosState {
  const ProfilePhotosState({
    this.photos = const [],
    this.isBusy = false,
    this.error,
  });

  final List<String> photos;

  /// True during any async operation (upload or Firestore write).
  final bool isBusy;

  /// Non-null after a failed operation. Always user-readable.
  final String? error;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final profilePhotosProvider =
    NotifierProvider.autoDispose<ProfilePhotosNotifier, ProfilePhotosState>(
  ProfilePhotosNotifier.new,
);

class ProfilePhotosNotifier extends AutoDisposeNotifier<ProfilePhotosState> {
  static final _picker = ImagePicker();

  @override
  ProfilePhotosState build() {
    // Read once — not watch — so Firestore stream updates never overwrite
    // in-progress edits.
    final user = ref.read(currentUserProvider).valueOrNull;
    return ProfilePhotosState(
      photos: List<String>.from(user?.profileImages ?? []),
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> addPhoto() async {
    if (state.isBusy) return;
    if (state.photos.length >= AppConstants.maxProfilePhotos) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (file == null) return; // user cancelled

    final prev = state.photos;
    state = ProfilePhotosState(photos: prev, isBusy: true);

    try {
      final urls = await ref.read(userRepositoryProvider).uploadProfilePhotos(
            userId: user.id,
            photoPaths: [file.path],
          );
      await _persistOrRevert([...prev, ...urls], prev);
    } catch (_) {
      state = ProfilePhotosState(
        photos: prev,
        error: 'Failed to upload photo. Please try again.',
      );
    }
  }

  Future<void> deletePhoto(int index) async {
    if (state.isBusy) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final urlToDelete = state.photos[index];
    final prev = state.photos;
    final updated = List<String>.from(prev)..removeAt(index);

    state = ProfilePhotosState(photos: prev, isBusy: true);

    final succeeded = await _persistOrRevert(updated, prev);
    if (succeeded) {
      // Best-effort Storage cleanup — non-blocking; failure is silent.
      unawaited(
        ref.read(userRepositoryProvider).deleteProfilePhoto(
              userId: user.id,
              photoUrl: urlToDelete,
            ),
      );
    }
  }

  /// [oldIndex] and [newIndex] come directly from the [onReorderItem] callback,
  /// which already delivers the final insertion index (no adjustment needed).
  Future<void> reorderPhotos(int oldIndex, int newIndex) async {
    if (state.isBusy) return;
    final prev = state.photos;
    final updated = List<String>.from(prev);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    state = ProfilePhotosState(photos: updated, isBusy: true); // optimistic
    await _persistOrRevert(updated, prev);
  }

  Future<void> setPrimary(int index) async {
    if (state.isBusy || index == 0) return;
    final prev = state.photos;
    final updated = List<String>.from(prev);
    final item = updated.removeAt(index);
    updated.insert(0, item);

    state = ProfilePhotosState(photos: updated, isBusy: true); // optimistic
    await _persistOrRevert(updated, prev);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  /// Writes [updated] to Firestore. On failure, reverts state to [prev].
  /// Returns true if the write succeeded.
  Future<bool> _persistOrRevert(
    List<String> updated,
    List<String> prev,
  ) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return false;
    try {
      await UpdateProfilePhotosUseCase(ref.read(userRepositoryProvider))
          .call(currentUser: user, photoUrls: updated);
      state = ProfilePhotosState(photos: updated);
      return true;
    } catch (e) {
      state = ProfilePhotosState(
        photos: prev,
        error: e is ProfilePhotosException
            ? e.message
            : 'Failed to save. Please try again.',
      );
      return false;
    }
  }
}
