import 'dart:io';

import '../models/verification_request.dart';

abstract interface class VerificationRepository {
  Future<void> submitPhotoVerification({
    required String userId,
    required File selfieFile,
  });

  Stream<VerificationRequest?> watchLatestPhotoVerificationRequest({
    required String userId,
  });

  Stream<List<VerificationRequest>> watchPendingPhotoVerificationRequests();

  Future<void> approvePhotoVerificationRequest({
    required String requestId,
    required String userId,
    required String reviewerId,
  });

  Future<void> rejectPhotoVerificationRequest({
    required String requestId,
    required String reviewerId,
    required String rejectionReason,
  });
}
