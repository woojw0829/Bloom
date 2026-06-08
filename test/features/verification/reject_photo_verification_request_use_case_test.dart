import 'dart:io';

import 'package:bloom/features/verification/domain/models/verification_request.dart';
import 'package:bloom/features/verification/domain/repositories/verification_repository.dart';
import 'package:bloom/features/verification/domain/usecases/reject_photo_verification_request_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

class _FakeVerificationRepository implements VerificationRepository {
  bool rejectCalled = false;
  bool shouldThrow = false;
  String? lastRejectedRequestId;
  String? lastRejectedReviewerId;
  String? lastRejectionReason;

  @override
  Future<void> rejectPhotoVerificationRequest({
    required String requestId,
    required String reviewerId,
    required String rejectionReason,
  }) async {
    rejectCalled = true;
    lastRejectedRequestId = requestId;
    lastRejectedReviewerId = reviewerId;
    lastRejectionReason = rejectionReason;
    if (shouldThrow) throw Exception('Firestore error');
  }

  @override
  Future<void> approvePhotoVerificationRequest({
    required String requestId,
    required String userId,
    required String reviewerId,
  }) async {}

  @override
  Stream<List<VerificationRequest>> watchPendingPhotoVerificationRequests() =>
      const Stream.empty();

  @override
  Future<void> submitPhotoVerification({
    required String userId,
    required File selfieFile,
  }) async {}

  @override
  Stream<VerificationRequest?> watchLatestPhotoVerificationRequest({
    required String userId,
  }) =>
      const Stream.empty();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeVerificationRepository repo;
  late RejectPhotoVerificationRequestUseCase useCase;

  setUp(() {
    repo = _FakeVerificationRepository();
    useCase = RejectPhotoVerificationRequestUseCase(repository: repo);
  });

  group('RejectPhotoVerificationRequestUseCase', () {
    test('returns InvalidInput when requestId is empty', () async {
      final outcome = await useCase.call(
        requestId: '',
        reviewerId: 'admin1',
        rejectionReason: 'Not a selfie.',
      );
      expect(outcome, isA<RejectPhotoVerificationInvalidInput>());
      expect(repo.rejectCalled, isFalse);
    });

    test('returns InvalidInput when reviewerId is empty', () async {
      final outcome = await useCase.call(
        requestId: 'req1',
        reviewerId: '',
        rejectionReason: 'Not a selfie.',
      );
      expect(outcome, isA<RejectPhotoVerificationInvalidInput>());
      expect(repo.rejectCalled, isFalse);
    });

    test('returns InvalidInput when rejectionReason is empty', () async {
      final outcome = await useCase.call(
        requestId: 'req1',
        reviewerId: 'admin1',
        rejectionReason: '',
      );
      expect(outcome, isA<RejectPhotoVerificationInvalidInput>());
      expect(repo.rejectCalled, isFalse);
    });

    test('returns InvalidInput when rejectionReason is whitespace only',
        () async {
      final outcome = await useCase.call(
        requestId: 'req1',
        reviewerId: 'admin1',
        rejectionReason: '   ',
      );
      expect(outcome, isA<RejectPhotoVerificationInvalidInput>());
      expect(repo.rejectCalled, isFalse);
    });

    test('returns InvalidInput when rejectionReason exceeds 500 characters',
        () async {
      final longReason = 'A' * 501;
      final outcome = await useCase.call(
        requestId: 'req1',
        reviewerId: 'admin1',
        rejectionReason: longReason,
      );
      expect(outcome, isA<RejectPhotoVerificationInvalidInput>());
      expect(repo.rejectCalled, isFalse);
    });

    test('accepts rejectionReason of exactly 500 characters', () async {
      final exactReason = 'A' * 500;
      final outcome = await useCase.call(
        requestId: 'req1',
        reviewerId: 'admin1',
        rejectionReason: exactReason,
      );
      expect(outcome, isA<RejectPhotoVerificationSuccess>());
      expect(repo.rejectCalled, isTrue);
    });

    test('trims whitespace from rejectionReason before passing to repository',
        () async {
      await useCase.call(
        requestId: 'req1',
        reviewerId: 'admin1',
        rejectionReason: '  Photo unclear.  ',
      );
      expect(repo.lastRejectionReason, 'Photo unclear.');
    });

    test('calls repository and returns Success for valid input', () async {
      final outcome = await useCase.call(
        requestId: 'req1',
        reviewerId: 'admin1',
        rejectionReason: 'Photo unclear.',
      );
      expect(outcome, isA<RejectPhotoVerificationSuccess>());
      expect(repo.rejectCalled, isTrue);
      expect(repo.lastRejectedRequestId, 'req1');
      expect(repo.lastRejectedReviewerId, 'admin1');
      expect(repo.lastRejectionReason, 'Photo unclear.');
    });

    test('returns Failure when repository throws', () async {
      repo.shouldThrow = true;
      final outcome = await useCase.call(
        requestId: 'req1',
        reviewerId: 'admin1',
        rejectionReason: 'Photo unclear.',
      );
      expect(outcome, isA<RejectPhotoVerificationFailure>());
    });
  });
}
