import '../repositories/verification_repository.dart';

const int _maxRejectionReasonLength = 500;

// ── Outcome sealed hierarchy ──────────────────────────────────────────────────

sealed class RejectPhotoVerificationOutcome {
  const RejectPhotoVerificationOutcome();
}

final class RejectPhotoVerificationSuccess
    extends RejectPhotoVerificationOutcome {
  const RejectPhotoVerificationSuccess();
}

final class RejectPhotoVerificationInvalidInput
    extends RejectPhotoVerificationOutcome {
  const RejectPhotoVerificationInvalidInput({required this.message});
  final String message;
}

final class RejectPhotoVerificationFailure
    extends RejectPhotoVerificationOutcome {
  const RejectPhotoVerificationFailure();
}

// ── Use case ──────────────────────────────────────────────────────────────────

class RejectPhotoVerificationRequestUseCase {
  const RejectPhotoVerificationRequestUseCase({required this.repository});

  final VerificationRepository repository;

  Future<RejectPhotoVerificationOutcome> call({
    required String requestId,
    required String reviewerId,
    required String rejectionReason,
  }) async {
    if (requestId.isEmpty) {
      return const RejectPhotoVerificationInvalidInput(
        message: 'Request ID must not be empty.',
      );
    }
    if (reviewerId.isEmpty) {
      return const RejectPhotoVerificationInvalidInput(
        message: 'Reviewer ID must not be empty.',
      );
    }
    final trimmedReason = rejectionReason.trim();
    if (trimmedReason.isEmpty) {
      return const RejectPhotoVerificationInvalidInput(
        message: 'Rejection reason must not be empty.',
      );
    }
    if (trimmedReason.length > _maxRejectionReasonLength) {
      return const RejectPhotoVerificationInvalidInput(
        message: 'Rejection reason must be 500 characters or fewer.',
      );
    }
    try {
      await repository.rejectPhotoVerificationRequest(
        requestId: requestId,
        reviewerId: reviewerId,
        rejectionReason: trimmedReason,
      );
      return const RejectPhotoVerificationSuccess();
    } catch (_) {
      return const RejectPhotoVerificationFailure();
    }
  }
}
