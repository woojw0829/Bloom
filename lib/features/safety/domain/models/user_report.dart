import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportReason {
  spam,
  fakeProfile,
  harassment,
  hateSpeech,
  inappropriateContent;

  String toJson() => switch (this) {
        ReportReason.spam => 'spam',
        ReportReason.fakeProfile => 'fake_profile',
        ReportReason.harassment => 'harassment',
        ReportReason.hateSpeech => 'hate_speech',
        ReportReason.inappropriateContent => 'inappropriate_content',
      };

  static ReportReason? tryFromJson(String? value) => switch (value) {
        'spam' => ReportReason.spam,
        'fake_profile' => ReportReason.fakeProfile,
        'harassment' => ReportReason.harassment,
        'hate_speech' => ReportReason.hateSpeech,
        'inappropriate_content' => ReportReason.inappropriateContent,
        _ => null,
      };
}

enum ReportStatus {
  pending,
  reviewing,
  resolved,
  rejected;

  static ReportStatus fromJson(String? value) => switch (value) {
        'reviewing' => ReportStatus.reviewing,
        'resolved' => ReportStatus.resolved,
        'rejected' => ReportStatus.rejected,
        _ => ReportStatus.pending,
      };
}

class UserReport {
  const UserReport({
    required this.id,
    required this.reporterId,
    required this.targetUserId,
    required this.reason,
    required this.description,
    required this.status,
    this.createdAt,
    this.reviewedBy,
    this.reviewedAt,
  });

  final String id;
  final String reporterId;
  final String targetUserId;
  final ReportReason reason;
  final String description;
  final ReportStatus status;
  final DateTime? createdAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  factory UserReport.fromFirestore(String docId, Map<String, dynamic> data) {
    return UserReport(
      id: data['id'] is String ? data['id'] as String : docId,
      reporterId: data['reporterId'] as String? ?? '',
      targetUserId: data['targetUserId'] as String? ?? '',
      reason: ReportReason.tryFromJson(data['reason'] as String?) ??
          ReportReason.spam,
      description: data['description'] as String? ?? '',
      status: ReportStatus.fromJson(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      reviewedBy: data['reviewedBy'] as String?,
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
    );
  }
}
