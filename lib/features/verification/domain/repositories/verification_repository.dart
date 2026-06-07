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
}
