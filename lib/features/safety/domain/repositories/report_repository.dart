import '../models/user_report.dart';

abstract class ReportRepository {
  Future<void> submitReport({
    required String reporterId,
    required String targetUserId,
    required ReportReason reason,
    required String description,
  });
}
