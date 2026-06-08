import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/verification_request.dart';
import '../../domain/usecases/approve_photo_verification_request_use_case.dart';
import '../../domain/usecases/reject_photo_verification_request_use_case.dart';
import 'verification_provider.dart';

// ── Admin claim ───────────────────────────────────────────────────────────────

/// Reads the 'admin' custom claim from the current user's ID token.
/// Force-refreshes the token to ensure the claim is current.
/// Returns false if the user is unauthenticated or the claim is absent.
final adminClaimProvider = FutureProvider<bool>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  final result = await user.getIdTokenResult(true);
  return result.claims?['admin'] == true;
});

// ── Pending requests stream ───────────────────────────────────────────────────

final pendingPhotoVerificationRequestsProvider =
    StreamProvider.autoDispose<List<VerificationRequest>>((ref) {
  return ref
      .watch(verificationRepositoryProvider)
      .watchPendingPhotoVerificationRequests();
});

// ── Use cases ─────────────────────────────────────────────────────────────────

final approvePhotoVerificationRequestUseCaseProvider =
    Provider<ApprovePhotoVerificationRequestUseCase>((ref) {
  return ApprovePhotoVerificationRequestUseCase(
    repository: ref.watch(verificationRepositoryProvider),
  );
});

final rejectPhotoVerificationRequestUseCaseProvider =
    Provider<RejectPhotoVerificationRequestUseCase>((ref) {
  return RejectPhotoVerificationRequestUseCase(
    repository: ref.watch(verificationRepositoryProvider),
  );
});

// ── Signed URL ────────────────────────────────────────────────────────────────

/// Fetches a short-lived signed URL for the selfie image of a given request.
/// Returns null on any error so the UI can show a graceful fallback.
final verificationSelfieSignedUrlProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, requestId) async {
  try {
    final callable = FirebaseFunctions.instance
        .httpsCallable('getVerificationImageSignedUrl');
    final result = await callable
        .call<Map<String, dynamic>>({'requestId': requestId, 'imageType': 'selfie'});
    return result.data['url'] as String?;
  } catch (_) {
    return null;
  }
});

// ── Management controller ─────────────────────────────────────────────────────

class VerificationManagementState {
  const VerificationManagementState({
    this.processingRequestId,
    this.lastError,
    this.lastSuccessAction,
  });

  /// ID of the request currently being approved or rejected.
  final String? processingRequestId;
  final String? lastError;

  /// 'approved' | 'rejected' | null — used to trigger snackbars.
  final String? lastSuccessAction;

  bool get isProcessing => processingRequestId != null;

  VerificationManagementState copyWith({
    String? processingRequestId,
    String? lastError,
    String? lastSuccessAction,
    bool clearProcessing = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return VerificationManagementState(
      processingRequestId:
          clearProcessing ? null : (processingRequestId ?? this.processingRequestId),
      lastError: clearError ? null : (lastError ?? this.lastError),
      lastSuccessAction:
          clearSuccess ? null : (lastSuccessAction ?? this.lastSuccessAction),
    );
  }
}

final verificationManagementControllerProvider = NotifierProvider.autoDispose<
    VerificationManagementController, VerificationManagementState>(
  VerificationManagementController.new,
);

class VerificationManagementController
    extends AutoDisposeNotifier<VerificationManagementState> {
  @override
  VerificationManagementState build() => const VerificationManagementState();

  Future<void> approve({
    required String requestId,
    required String userId,
  }) async {
    if (state.isProcessing) return;
    final reviewerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (reviewerId.isEmpty) return;

    state = state.copyWith(
      processingRequestId: requestId,
      clearError: true,
      clearSuccess: true,
    );

    final outcome = await ref
        .read(approvePhotoVerificationRequestUseCaseProvider)
        .call(requestId: requestId, userId: userId, reviewerId: reviewerId);

    switch (outcome) {
      case ApprovePhotoVerificationSuccess():
        state = state.copyWith(
          clearProcessing: true,
          lastSuccessAction: 'approved',
        );
      case ApprovePhotoVerificationInvalidInput(:final message):
        state = state.copyWith(clearProcessing: true, lastError: message);
      case ApprovePhotoVerificationFailure():
        state = state.copyWith(clearProcessing: true, lastError: 'failed');
    }
  }

  Future<void> reject({
    required String requestId,
    required String rejectionReason,
  }) async {
    if (state.isProcessing) return;
    final reviewerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (reviewerId.isEmpty) return;

    state = state.copyWith(
      processingRequestId: requestId,
      clearError: true,
      clearSuccess: true,
    );

    final outcome = await ref
        .read(rejectPhotoVerificationRequestUseCaseProvider)
        .call(
          requestId: requestId,
          reviewerId: reviewerId,
          rejectionReason: rejectionReason,
        );

    switch (outcome) {
      case RejectPhotoVerificationSuccess():
        state = state.copyWith(
          clearProcessing: true,
          lastSuccessAction: 'rejected',
        );
      case RejectPhotoVerificationInvalidInput(:final message):
        state = state.copyWith(clearProcessing: true, lastError: message);
      case RejectPhotoVerificationFailure():
        state = state.copyWith(clearProcessing: true, lastError: 'failed');
    }
  }

  void clearFeedback() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
