import '../models/user_report.dart';
import '../repositories/report_repository.dart';

sealed class ReportUserResult {}

class ReportUserSuccess extends ReportUserResult {}

class ReportUserValidationError extends ReportUserResult {
  ReportUserValidationError(this.reason);
  final String reason;
}

class ReportUserFailure extends ReportUserResult {}

const int kMaxReportDescriptionLength = 1000;

class ReportUserUseCase {
  const ReportUserUseCase({required this.reportRepository});

  final ReportRepository reportRepository;

  Future<ReportUserResult> execute({
    required String reporterId,
    required String targetUserId,
    required ReportReason reason,
    required String description,
  }) async {
    if (reporterId.trim().isEmpty) {
      return ReportUserValidationError('reporterId is empty');
    }
    if (targetUserId.trim().isEmpty) {
      return ReportUserValidationError('targetUserId is empty');
    }
    if (reporterId == targetUserId) {
      return ReportUserValidationError('cannot report self');
    }
    final trimmed = description.trim();
    if (trimmed.length > kMaxReportDescriptionLength) {
      return ReportUserValidationError('description too long');
    }

    try {
      await reportRepository.submitReport(
        reporterId: reporterId,
        targetUserId: targetUserId,
        reason: reason,
        description: trimmed,
      );
    } catch (_) {
      return ReportUserFailure();
    }

    return ReportUserSuccess();
  }
}
