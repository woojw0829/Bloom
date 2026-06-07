import 'package:bloom/features/verification/domain/models/verification_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── VerificationType ──────────────────────────────────────────────────────

  group('VerificationType', () {
    test('photo serializes to "photo"', () {
      expect(VerificationType.photo.firestoreValue, 'photo');
    });

    test('governmentId serializes to "government_id"', () {
      expect(VerificationType.governmentId.firestoreValue, 'government_id');
    });

    test('fromFirestore parses "photo"', () {
      expect(
        VerificationType.fromFirestore('photo'),
        VerificationType.photo,
      );
    });

    test('fromFirestore parses "government_id"', () {
      expect(
        VerificationType.fromFirestore('government_id'),
        VerificationType.governmentId,
      );
    });

    test('fromFirestore unknown value defaults to photo', () {
      expect(
        VerificationType.fromFirestore('unknown'),
        VerificationType.photo,
      );
    });
  });

  // ── VerificationRequestStatus ─────────────────────────────────────────────

  group('VerificationRequestStatus', () {
    test('pending serializes to "pending"', () {
      expect(VerificationRequestStatus.pending.firestoreValue, 'pending');
    });

    test('approved serializes to "approved"', () {
      expect(VerificationRequestStatus.approved.firestoreValue, 'approved');
    });

    test('rejected serializes to "rejected"', () {
      expect(VerificationRequestStatus.rejected.firestoreValue, 'rejected');
    });

    test('fromFirestore parses "pending"', () {
      expect(
        VerificationRequestStatus.fromFirestore('pending'),
        VerificationRequestStatus.pending,
      );
    });

    test('fromFirestore parses "approved"', () {
      expect(
        VerificationRequestStatus.fromFirestore('approved'),
        VerificationRequestStatus.approved,
      );
    });

    test('fromFirestore parses "rejected"', () {
      expect(
        VerificationRequestStatus.fromFirestore('rejected'),
        VerificationRequestStatus.rejected,
      );
    });

    test('fromFirestore unknown value defaults to pending', () {
      expect(
        VerificationRequestStatus.fromFirestore('unknown'),
        VerificationRequestStatus.pending,
      );
    });
  });

  // ── VerificationRequest.fromFirestore ─────────────────────────────────────

  group('VerificationRequest.fromFirestore', () {
    test('parses a complete photo verification document', () {
      final data = <String, dynamic>{
        'userId': 'user123',
        'verificationType': 'photo',
        'selfieImageUrl': 'verification_requests/user123/req456/selfie.jpg',
        'status': 'pending',
        'createdAt': null,
      };

      final req = VerificationRequest.fromFirestore('req456', data);

      expect(req.id, 'req456');
      expect(req.userId, 'user123');
      expect(req.verificationType, VerificationType.photo);
      expect(req.selfieImageUrl,
          'verification_requests/user123/req456/selfie.jpg');
      expect(req.status, VerificationRequestStatus.pending);
      expect(req.governmentIdImageUrl, isNull);
      expect(req.rejectionReason, isNull);
      expect(req.reviewedBy, isNull);
      expect(req.reviewedAt, isNull);
    });

    test('parses an approved document', () {
      final data = <String, dynamic>{
        'userId': 'userA',
        'verificationType': 'photo',
        'selfieImageUrl': 'verification_requests/userA/reqB/selfie.jpg',
        'status': 'approved',
        'createdAt': null,
      };

      final req = VerificationRequest.fromFirestore('reqB', data);
      expect(req.status, VerificationRequestStatus.approved);
    });

    test('parses a rejected document with rejectionReason', () {
      final data = <String, dynamic>{
        'userId': 'userA',
        'verificationType': 'photo',
        'selfieImageUrl': 'verification_requests/userA/reqC/selfie.jpg',
        'status': 'rejected',
        'rejectionReason': 'Photo was too dark.',
        'createdAt': null,
      };

      final req = VerificationRequest.fromFirestore('reqC', data);
      expect(req.status, VerificationRequestStatus.rejected);
      expect(req.rejectionReason, 'Photo was too dark.');
    });

    test('selfieImageUrl is a Storage path, not a download URL', () {
      final data = <String, dynamic>{
        'userId': 'user123',
        'verificationType': 'photo',
        'selfieImageUrl': 'verification_requests/user123/req789/selfie.jpg',
        'status': 'pending',
        'createdAt': null,
      };

      final req = VerificationRequest.fromFirestore('req789', data);

      // Must be a path, not a https:// URL.
      expect(req.selfieImageUrl, isNot(startsWith('https://')));
      expect(req.selfieImageUrl, startsWith('verification_requests/'));
    });

    test('handles missing optional fields gracefully', () {
      final data = <String, dynamic>{
        'userId': 'user1',
        'verificationType': 'photo',
        'selfieImageUrl': 'verification_requests/user1/r1/selfie.jpg',
        'status': 'pending',
      };

      expect(
        () => VerificationRequest.fromFirestore('r1', data),
        returnsNormally,
      );
    });

    test('handles unknown verificationType safely', () {
      final data = <String, dynamic>{
        'userId': 'user1',
        'verificationType': 'unknown_type',
        'selfieImageUrl': 'verification_requests/user1/r1/selfie.jpg',
        'status': 'pending',
      };

      final req = VerificationRequest.fromFirestore('r1', data);
      expect(req.verificationType, VerificationType.photo);
    });

    test('handles unknown status safely', () {
      final data = <String, dynamic>{
        'userId': 'user1',
        'verificationType': 'photo',
        'selfieImageUrl': 'verification_requests/user1/r1/selfie.jpg',
        'status': 'unknown_status',
      };

      final req = VerificationRequest.fromFirestore('r1', data);
      expect(req.status, VerificationRequestStatus.pending);
    });
  });
}
