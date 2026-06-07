import 'dart:io';

import '../models/verification_request.dart';
import '../repositories/verification_repository.dart';

// ── Outcome sealed hierarchy ──────────────────────────────────────────────────

sealed class SubmitPhotoVerificationOutcome {
  const SubmitPhotoVerificationOutcome();
}

final class SubmitPhotoVerificationSuccess
    extends SubmitPhotoVerificationOutcome {
  const SubmitPhotoVerificationSuccess();
}

final class SubmitPhotoVerificationAlreadyPending
    extends SubmitPhotoVerificationOutcome {
  const SubmitPhotoVerificationAlreadyPending();
}

final class SubmitPhotoVerificationInvalidInput
    extends SubmitPhotoVerificationOutcome {
  const SubmitPhotoVerificationInvalidInput({required this.message});
  final String message;
}

final class SubmitPhotoVerificationFailure
    extends SubmitPhotoVerificationOutcome {
  const SubmitPhotoVerificationFailure();
}

// ── Use case ──────────────────────────────────────────────────────────────────

class SubmitPhotoVerificationUseCase {
  const SubmitPhotoVerificationUseCase({required this.repository});

  final VerificationRepository repository;

  Future<SubmitPhotoVerificationOutcome> call({
    required String userId,
    required File selfieFile,
    VerificationRequest? currentRequest,
  }) async {
    if (userId.isEmpty) {
      return const SubmitPhotoVerificationInvalidInput(
        message: 'User ID must not be empty.',
      );
    }

    if (!selfieFile.existsSync()) {
      return const SubmitPhotoVerificationInvalidInput(
        message: 'Selected image file does not exist.',
      );
    }

    if (currentRequest != null &&
        currentRequest.status == VerificationRequestStatus.pending) {
      return const SubmitPhotoVerificationAlreadyPending();
    }

    try {
      await repository.submitPhotoVerification(
        userId: userId,
        selfieFile: selfieFile,
      );
      return const SubmitPhotoVerificationSuccess();
    } catch (_) {
      return const SubmitPhotoVerificationFailure();
    }
  }
}
