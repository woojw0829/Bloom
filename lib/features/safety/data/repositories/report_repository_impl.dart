import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/user_report.dart';
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<void> submitReport({
    required String reporterId,
    required String targetUserId,
    required ReportReason reason,
    required String description,
  }) async {
    final docRef = _firestore.collection('reports').doc();
    await docRef.set({
      'id': docRef.id,
      'reporterId': reporterId,
      'targetUserId': targetUserId,
      'reason': reason.toJson(),
      'description': description,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
