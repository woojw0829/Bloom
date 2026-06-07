import 'package:cloud_firestore/cloud_firestore.dart';

enum VerificationType {
  photo,
  governmentId;

  String get firestoreValue => switch (this) {
        VerificationType.photo => 'photo',
        VerificationType.governmentId => 'government_id',
      };

  static VerificationType fromFirestore(String value) => switch (value) {
        'photo' => VerificationType.photo,
        'government_id' => VerificationType.governmentId,
        _ => VerificationType.photo,
      };
}

enum VerificationRequestStatus {
  pending,
  approved,
  rejected;

  String get firestoreValue => name;

  static VerificationRequestStatus fromFirestore(String value) =>
      switch (value) {
        'approved' => VerificationRequestStatus.approved,
        'rejected' => VerificationRequestStatus.rejected,
        _ => VerificationRequestStatus.pending,
      };
}

class VerificationRequest {
  const VerificationRequest({
    required this.id,
    required this.userId,
    required this.verificationType,
    required this.selfieImageUrl,
    this.governmentIdImageUrl,
    required this.status,
    this.rejectionReason,
    this.reviewedBy,
    this.reviewedAt,
    this.createdAt,
  });

  final String id;
  final String userId;
  final VerificationType verificationType;

  // Stores a Firebase Storage path, never a public download URL.
  final String selfieImageUrl;

  final String? governmentIdImageUrl;
  final VerificationRequestStatus status;
  final String? rejectionReason;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  factory VerificationRequest.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return VerificationRequest(
      id: id,
      userId: data['userId'] as String? ?? '',
      verificationType: VerificationType.fromFirestore(
        data['verificationType'] as String? ?? 'photo',
      ),
      selfieImageUrl: data['selfieImageUrl'] as String? ?? '',
      governmentIdImageUrl: data['governmentIdImageUrl'] as String?,
      status: VerificationRequestStatus.fromFirestore(
        data['status'] as String? ?? 'pending',
      ),
      rejectionReason: data['rejectionReason'] as String?,
      reviewedBy: data['reviewedBy'] as String?,
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
