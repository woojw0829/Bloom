import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/report_user_use_case.dart';

final reportRepositoryProvider = Provider<ReportRepository>(
  (_) => ReportRepositoryImpl(),
);

final reportUserUseCaseProvider = Provider<ReportUserUseCase>(
  (ref) => ReportUserUseCase(
    reportRepository: ref.watch(reportRepositoryProvider),
  ),
);
