import 'dart:io';

import 'package:bloom/features/verification/domain/models/verification_request.dart';
import 'package:bloom/features/verification/domain/repositories/verification_repository.dart';
import 'package:bloom/features/verification/domain/usecases/approve_photo_verification_request_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

class _FakeVerificationRepository implements VerificationRepository {
  bool approveCalled = false;
  bool shouldThrow = false;
  String? lastApprovedRequestId;
  String? lastApprovedUserId;
  String? lastApprovedReviewerId;

  @override
  Future<void> approvePhotoVerificationRequest({
    required String requestId,
    required String userId,
    required String reviewerId,
  }) async {
    approveCalled = true;
    lastApprovedRequestId = requestId;
    lastApprovedUserId = userId;
    lastApprovedReviewerId = reviewerId;
    if (shouldThrow) throw Exception('Firestore error');
  }

  @override
  Future<void> rejectPhotoVerificationRequest({
    required String requestId,
    required String reviewerId,
    required String rejectionReason,
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
  late ApprovePhotoVerificationRequestUseCase useCase;

  setUp(() {
    repo = _FakeVerificationRepository();
    useCase = ApprovePhotoVerificationRequestUseCase(repository: repo);
  });

  group('ApprovePhotoVerificationRequestUseCase', () {
    test('returns InvalidInput when requestId is empty', () async {
      final outcome = await useCase.call(
        requestId: '',
        userId: 'user1',
        reviewerId: 'admin1',
      );
      expect(outcome, isA<ApprovePhotoVerificationInvalidInput>());
      expect(repo.approveCalled, isFalse);
    });

    test('returns InvalidInput when userId is empty', () async {
      final outcome = await useCase.call(
        requestId: 'req1',
        userId: '',
        reviewerId: 'admin1',
      );
      expect(outcome, isA<ApprovePhotoVerificationInvalidInput>());
      expect(repo.approveCalled, isFalse);
    });

    test('returns InvalidInput when reviewerId is empty', () async {
      final outcome = await useCase.call(
        requestId: 'req1',
        userId: 'user1',
        reviewerId: '',
      );
      expect(outcome, isA<ApprovePhotoVerificationInvalidInput>());
      expect(repo.approveCalled, isFalse);
    });

    test('calls repository and returns Success for valid input', () async {
      final outcome = await useCase.call(
        requestId: 'req1',
        userId: 'user1',
        reviewerId: 'admin1',
      );
      expect(outcome, isA<ApprovePhotoVerificationSuccess>());
      expect(repo.approveCalled, isTrue);
      expect(repo.lastApprovedRequestId, 'req1');
      expect(repo.lastApprovedUserId, 'user1');
      expect(repo.lastApprovedReviewerId, 'admin1');
    });

    test('returns Failure when repository throws', () async {
      repo.shouldThrow = true;
      final outcome = await useCase.call(
        requestId: 'req1',
        userId: 'user1',
        reviewerId: 'admin1',
      );
      expect(outcome, isA<ApprovePhotoVerificationFailure>());
    });

    test('passes all three IDs correctly to repository', () async {
      await useCase.call(
        requestId: 'requestXYZ',
        userId: 'userABC',
        reviewerId: 'adminDEF',
      );
      expect(repo.lastApprovedRequestId, 'requestXYZ');
      expect(repo.lastApprovedUserId, 'userABC');
      expect(repo.lastApprovedReviewerId, 'adminDEF');
    });
  });
}
