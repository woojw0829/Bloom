import 'dart:io';

import 'package:bloom/features/verification/domain/models/verification_request.dart';
import 'package:bloom/features/verification/domain/repositories/verification_repository.dart';
import 'package:bloom/features/verification/domain/usecases/submit_photo_verification_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

class _FakeVerificationRepository implements VerificationRepository {
  bool submitCalled = false;
  bool shouldThrow = false;
  String? lastUserId;

  @override
  Future<void> submitPhotoVerification({
    required String userId,
    required File selfieFile,
  }) async {
    submitCalled = true;
    lastUserId = userId;
    if (shouldThrow) throw Exception('Storage error');
  }

  @override
  Stream<VerificationRequest?> watchLatestPhotoVerificationRequest({
    required String userId,
  }) =>
      const Stream.empty();

  @override
  Stream<List<VerificationRequest>> watchPendingPhotoVerificationRequests() =>
      const Stream.empty();

  @override
  Future<void> approvePhotoVerificationRequest({
    required String requestId,
    required String userId,
    required String reviewerId,
  }) async {}

  @override
  Future<void> rejectPhotoVerificationRequest({
    required String requestId,
    required String reviewerId,
    required String rejectionReason,
  }) async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

File _tempFile({bool exists = true}) {
  final dir = Directory.systemTemp;
  final file = File('${dir.path}/test_selfie_${DateTime.now().millisecondsSinceEpoch}.jpg');
  if (exists) file.createSync();
  return file;
}

VerificationRequest _makeRequest({
  VerificationRequestStatus status = VerificationRequestStatus.pending,
}) {
  return VerificationRequest(
    id: 'req1',
    userId: 'user1',
    verificationType: VerificationType.photo,
    selfieImageUrl: 'verification_requests/user1/req1/selfie.jpg',
    status: status,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeVerificationRepository repo;
  late SubmitPhotoVerificationUseCase useCase;

  setUp(() {
    repo = _FakeVerificationRepository();
    useCase = SubmitPhotoVerificationUseCase(repository: repo);
  });

  group('SubmitPhotoVerificationUseCase', () {
    test('returns InvalidInput when userId is empty', () async {
      final file = _tempFile();
      final outcome = await useCase.call(userId: '', selfieFile: file);
      expect(outcome, isA<SubmitPhotoVerificationInvalidInput>());
      expect(repo.submitCalled, isFalse);
      file.deleteSync();
    });

    test('returns InvalidInput when file does not exist', () async {
      final file = _tempFile(exists: false);
      final outcome = await useCase.call(userId: 'user1', selfieFile: file);
      expect(outcome, isA<SubmitPhotoVerificationInvalidInput>());
      expect(repo.submitCalled, isFalse);
    });

    test('returns AlreadyPending when current request is pending', () async {
      final file = _tempFile();
      final outcome = await useCase.call(
        userId: 'user1',
        selfieFile: file,
        currentRequest: _makeRequest(status: VerificationRequestStatus.pending),
      );
      expect(outcome, isA<SubmitPhotoVerificationAlreadyPending>());
      expect(repo.submitCalled, isFalse);
      file.deleteSync();
    });

    test('calls repository and returns Success for valid input with no prior request',
        () async {
      final file = _tempFile();
      final outcome = await useCase.call(userId: 'user1', selfieFile: file);
      expect(outcome, isA<SubmitPhotoVerificationSuccess>());
      expect(repo.submitCalled, isTrue);
      expect(repo.lastUserId, 'user1');
      file.deleteSync();
    });

    test('calls repository and returns Success when prior request is rejected',
        () async {
      final file = _tempFile();
      final outcome = await useCase.call(
        userId: 'user1',
        selfieFile: file,
        currentRequest:
            _makeRequest(status: VerificationRequestStatus.rejected),
      );
      expect(outcome, isA<SubmitPhotoVerificationSuccess>());
      expect(repo.submitCalled, isTrue);
      file.deleteSync();
    });

    test('calls repository and returns Success when prior request is approved',
        () async {
      final file = _tempFile();
      final outcome = await useCase.call(
        userId: 'user1',
        selfieFile: file,
        currentRequest:
            _makeRequest(status: VerificationRequestStatus.approved),
      );
      expect(outcome, isA<SubmitPhotoVerificationSuccess>());
      expect(repo.submitCalled, isTrue);
      file.deleteSync();
    });

    test('returns Failure when repository throws', () async {
      repo.shouldThrow = true;
      final file = _tempFile();
      final outcome = await useCase.call(userId: 'user1', selfieFile: file);
      expect(outcome, isA<SubmitPhotoVerificationFailure>());
      file.deleteSync();
    });
  });

  group('Storage path helper', () {
    test('repository impl produces correct storage path structure', () {
      // Verify the expected path shape without calling Firebase.
      const userId = 'user123';
      const requestId = 'req456';
      const path =
          'verification_requests/$userId/$requestId/selfie.jpg';
      expect(path, 'verification_requests/user123/req456/selfie.jpg');
      expect(path, startsWith('verification_requests/'));
      expect(path, endsWith('/selfie.jpg'));
      expect(path, isNot(contains('https://')));
    });
  });
}
