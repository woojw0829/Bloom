import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../features/profile/presentation/providers/profile_providers.dart';
import '../../data/repositories/verification_repository_impl.dart';
import '../../domain/models/verification_request.dart';
import '../../domain/repositories/verification_repository.dart';
import '../../domain/usecases/submit_photo_verification_use_case.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepositoryImpl();
});

// ── Use case ──────────────────────────────────────────────────────────────────

final submitPhotoVerificationUseCaseProvider =
    Provider<SubmitPhotoVerificationUseCase>((ref) {
  return SubmitPhotoVerificationUseCase(
    repository: ref.watch(verificationRepositoryProvider),
  );
});

// ── Latest request stream ─────────────────────────────────────────────────────

final latestPhotoVerificationRequestProvider =
    StreamProvider.autoDispose<VerificationRequest?>((ref) {
  final userId =
      ref.watch(currentUserProvider.select((a) => a.valueOrNull?.id ?? ''));
  if (userId.isEmpty) return const Stream.empty();
  return ref
      .watch(verificationRepositoryProvider)
      .watchLatestPhotoVerificationRequest(userId: userId);
});

// ── Controller state ──────────────────────────────────────────────────────────

class PhotoVerificationState {
  const PhotoVerificationState({
    this.selectedFile,
    this.isSubmitting = false,
    this.error,
    this.submitted = false,
  });

  final File? selectedFile;
  final bool isSubmitting;
  final String? error;
  final bool submitted;
}

// ── Controller ────────────────────────────────────────────────────────────────

final photoVerificationControllerProvider = NotifierProvider.autoDispose<
    PhotoVerificationController, PhotoVerificationState>(
  PhotoVerificationController.new,
);

class PhotoVerificationController
    extends AutoDisposeNotifier<PhotoVerificationState> {
  static final _picker = ImagePicker();

  @override
  PhotoVerificationState build() => const PhotoVerificationState();

  Future<void> pickImage() async {
    if (state.isSubmitting) return;
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (file == null) return;
    state = PhotoVerificationState(selectedFile: File(file.path));
  }

  Future<SubmitPhotoVerificationOutcome?> submit() async {
    if (state.isSubmitting) return null;
    final file = state.selectedFile;
    if (file == null) return null;

    final userId = ref.read(currentUserProvider).valueOrNull?.id;
    if (userId == null || userId.isEmpty) return null;

    final currentRequest =
        ref.read(latestPhotoVerificationRequestProvider).valueOrNull;

    state = PhotoVerificationState(
      selectedFile: file,
      isSubmitting: true,
    );

    final outcome =
        await ref.read(submitPhotoVerificationUseCaseProvider).call(
              userId: userId,
              selfieFile: file,
              currentRequest: currentRequest,
            );

    switch (outcome) {
      case SubmitPhotoVerificationSuccess():
        state = const PhotoVerificationState(submitted: true);
      case SubmitPhotoVerificationAlreadyPending():
        // The UI shows the pending state from latestPhotoVerificationRequestProvider.
        state = PhotoVerificationState(selectedFile: file);
      case SubmitPhotoVerificationInvalidInput(:final message):
        state = PhotoVerificationState(
          selectedFile: file,
          error: message,
        );
      case SubmitPhotoVerificationFailure():
        state = PhotoVerificationState(
          selectedFile: file,
          error: 'failed',
        );
    }

    return outcome;
  }

  void clearError() {
    if (state.error == null) return;
    state = PhotoVerificationState(selectedFile: state.selectedFile);
  }
}
