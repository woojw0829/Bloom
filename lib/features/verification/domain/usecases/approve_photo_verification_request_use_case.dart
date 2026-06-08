import '../repositories/verification_repository.dart';

// ── Outcome sealed hierarchy ──────────────────────────────────────────────────

sealed class ApprovePhotoVerificationOutcome {
  const ApprovePhotoVerificationOutcome();
}

final class ApprovePhotoVerificationSuccess
    extends ApprovePhotoVerificationOutcome {
  const ApprovePhotoVerificationSuccess();
}

final class ApprovePhotoVerificationInvalidInput
    extends ApprovePhotoVerificationOutcome {
  const ApprovePhotoVerificationInvalidInput({required this.message});
  final String message;
}

final class ApprovePhotoVerificationFailure
    extends ApprovePhotoVerificationOutcome {
  const ApprovePhotoVerificationFailure();
}

// ── Use case ──────────────────────────────────────────────────────────────────

class ApprovePhotoVerificationRequestUseCase {
  const ApprovePhotoVerificationRequestUseCase({required this.repository});

  final VerificationRepository repository;

  Future<ApprovePhotoVerificationOutcome> call({
    required String requestId,
    required String userId,
    required String reviewerId,
  }) async {
    if (requestId.isEmpty) {
      return const ApprovePhotoVerificationInvalidInput(
        message: 'Request ID must not be empty.',
      );
    }
    if (userId.isEmpty) {
      return const ApprovePhotoVerificationInvalidInput(
        message: 'User ID must not be empty.',
      );
    }
    if (reviewerId.isEmpty) {
      return const ApprovePhotoVerificationInvalidInput(
        message: 'Reviewer ID must not be empty.',
      );
    }
    try {
      await repository.approvePhotoVerificationRequest(
        requestId: requestId,
        userId: userId,
        reviewerId: reviewerId,
      );
      return const ApprovePhotoVerificationSuccess();
    } catch (_) {
      return const ApprovePhotoVerificationFailure();
    }
  }
}
