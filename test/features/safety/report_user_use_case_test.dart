import 'package:bloom/features/safety/domain/models/user_report.dart';
import 'package:bloom/features/safety/domain/repositories/report_repository.dart';
import 'package:bloom/features/safety/domain/usecases/report_user_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake ──────────────────────────────────────────────────────────────────────

class _FakeReportRepo implements ReportRepository {
  String? lastReporterId;
  String? lastTargetUserId;
  ReportReason? lastReason;
  String? lastDescription;
  bool shouldThrow = false;

  @override
  Future<void> submitReport({
    required String reporterId,
    required String targetUserId,
    required ReportReason reason,
    required String description,
  }) async {
    lastReporterId = reporterId;
    lastTargetUserId = targetUserId;
    lastReason = reason;
    lastDescription = description;
    if (shouldThrow) throw Exception('Firestore error');
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeReportRepo repo;
  late ReportUserUseCase useCase;

  setUp(() {
    repo = _FakeReportRepo();
    useCase = ReportUserUseCase(reportRepository: repo);
  });

  // ── ReportReason serialization ───────────────────────────────────────────

  group('ReportReason.toJson', () {
    test('spam serializes to spam', () {
      expect(ReportReason.spam.toJson(), 'spam');
    });

    test('fakeProfile serializes to fake_profile', () {
      expect(ReportReason.fakeProfile.toJson(), 'fake_profile');
    });

    test('harassment serializes to harassment', () {
      expect(ReportReason.harassment.toJson(), 'harassment');
    });

    test('hateSpeech serializes to hate_speech', () {
      expect(ReportReason.hateSpeech.toJson(), 'hate_speech');
    });

    test('inappropriateContent serializes to inappropriate_content', () {
      expect(ReportReason.inappropriateContent.toJson(), 'inappropriate_content');
    });
  });

  group('ReportReason.tryFromJson', () {
    test('parses spam', () {
      expect(ReportReason.tryFromJson('spam'), ReportReason.spam);
    });

    test('parses fake_profile', () {
      expect(ReportReason.tryFromJson('fake_profile'), ReportReason.fakeProfile);
    });

    test('parses harassment', () {
      expect(ReportReason.tryFromJson('harassment'), ReportReason.harassment);
    });

    test('parses hate_speech', () {
      expect(ReportReason.tryFromJson('hate_speech'), ReportReason.hateSpeech);
    });

    test('parses inappropriate_content', () {
      expect(
        ReportReason.tryFromJson('inappropriate_content'),
        ReportReason.inappropriateContent,
      );
    });

    test('returns null for unknown value', () {
      expect(ReportReason.tryFromJson('unknown'), isNull);
    });

    test('returns null for null input', () {
      expect(ReportReason.tryFromJson(null), isNull);
    });
  });

  // ── ReportStatus parsing ─────────────────────────────────────────────────

  group('ReportStatus.fromJson', () {
    test('parses pending', () {
      expect(ReportStatus.fromJson('pending'), ReportStatus.pending);
    });

    test('parses reviewing', () {
      expect(ReportStatus.fromJson('reviewing'), ReportStatus.reviewing);
    });

    test('parses resolved', () {
      expect(ReportStatus.fromJson('resolved'), ReportStatus.resolved);
    });

    test('parses rejected', () {
      expect(ReportStatus.fromJson('rejected'), ReportStatus.rejected);
    });

    test('defaults to pending for unknown value', () {
      expect(ReportStatus.fromJson('something_else'), ReportStatus.pending);
    });

    test('defaults to pending for null', () {
      expect(ReportStatus.fromJson(null), ReportStatus.pending);
    });
  });

  // ── UserReport.fromFirestore ─────────────────────────────────────────────

  group('UserReport.fromFirestore', () {
    test('parses all fields from valid data', () {
      final report = UserReport.fromFirestore('docId', {
        'id': 'docId',
        'reporterId': 'user1',
        'targetUserId': 'user2',
        'reason': 'harassment',
        'description': 'some text',
        'status': 'reviewing',
      });
      expect(report.id, 'docId');
      expect(report.reporterId, 'user1');
      expect(report.targetUserId, 'user2');
      expect(report.reason, ReportReason.harassment);
      expect(report.description, 'some text');
      expect(report.status, ReportStatus.reviewing);
    });

    test('falls back to docId when id field missing', () {
      final report = UserReport.fromFirestore('docId', {});
      expect(report.id, 'docId');
    });

    test('falls back to spam for unknown reason', () {
      final report = UserReport.fromFirestore('x', {'reason': 'nonsense'});
      expect(report.reason, ReportReason.spam);
    });

    test('defaults to pending for unknown status', () {
      final report = UserReport.fromFirestore('x', {'status': 'nonsense'});
      expect(report.status, ReportStatus.pending);
    });
  });

  // ── ReportUserUseCase validation ─────────────────────────────────────────

  group('ReportUserUseCase validation', () {
    test('rejects empty reporterId', () async {
      final result = await useCase.execute(
        reporterId: '',
        targetUserId: 'user2',
        reason: ReportReason.spam,
        description: '',
      );
      expect(result, isA<ReportUserValidationError>());
      expect(repo.lastReporterId, isNull);
    });

    test('rejects whitespace-only reporterId', () async {
      final result = await useCase.execute(
        reporterId: '   ',
        targetUserId: 'user2',
        reason: ReportReason.spam,
        description: '',
      );
      expect(result, isA<ReportUserValidationError>());
    });

    test('rejects empty targetUserId', () async {
      final result = await useCase.execute(
        reporterId: 'user1',
        targetUserId: '',
        reason: ReportReason.spam,
        description: '',
      );
      expect(result, isA<ReportUserValidationError>());
      expect(repo.lastReporterId, isNull);
    });

    test('rejects whitespace-only targetUserId', () async {
      final result = await useCase.execute(
        reporterId: 'user1',
        targetUserId: '   ',
        reason: ReportReason.spam,
        description: '',
      );
      expect(result, isA<ReportUserValidationError>());
    });

    test('rejects self-report', () async {
      final result = await useCase.execute(
        reporterId: 'user1',
        targetUserId: 'user1',
        reason: ReportReason.spam,
        description: '',
      );
      expect(result, isA<ReportUserValidationError>());
      expect(repo.lastReporterId, isNull);
    });

    test('rejects description over max length', () async {
      final longDesc = 'a' * (kMaxReportDescriptionLength + 1);
      final result = await useCase.execute(
        reporterId: 'user1',
        targetUserId: 'user2',
        reason: ReportReason.spam,
        description: longDesc,
      );
      expect(result, isA<ReportUserValidationError>());
      expect(repo.lastReporterId, isNull);
    });

    test('accepts description at exactly max length', () async {
      final maxDesc = 'a' * kMaxReportDescriptionLength;
      final result = await useCase.execute(
        reporterId: 'user1',
        targetUserId: 'user2',
        reason: ReportReason.spam,
        description: maxDesc,
      );
      expect(result, isA<ReportUserSuccess>());
    });
  });

  // ── ReportUserUseCase behavior ───────────────────────────────────────────

  group('ReportUserUseCase behavior', () {
    test('calls repository for valid input', () async {
      await useCase.execute(
        reporterId: 'userA',
        targetUserId: 'userB',
        reason: ReportReason.fakeProfile,
        description: 'test',
      );
      expect(repo.lastReporterId, 'userA');
      expect(repo.lastTargetUserId, 'userB');
      expect(repo.lastReason, ReportReason.fakeProfile);
    });

    test('returns ReportUserSuccess for valid input', () async {
      final result = await useCase.execute(
        reporterId: 'userA',
        targetUserId: 'userB',
        reason: ReportReason.harassment,
        description: '',
      );
      expect(result, isA<ReportUserSuccess>());
    });

    test('trims description before passing to repository', () async {
      await useCase.execute(
        reporterId: 'userA',
        targetUserId: 'userB',
        reason: ReportReason.spam,
        description: '  hello  ',
      );
      expect(repo.lastDescription, 'hello');
    });

    test('passes empty trimmed description when blank', () async {
      await useCase.execute(
        reporterId: 'userA',
        targetUserId: 'userB',
        reason: ReportReason.spam,
        description: '   ',
      );
      expect(repo.lastDescription, '');
    });

    test('returns ReportUserFailure when repository throws', () async {
      repo.shouldThrow = true;
      final result = await useCase.execute(
        reporterId: 'userA',
        targetUserId: 'userB',
        reason: ReportReason.spam,
        description: '',
      );
      expect(result, isA<ReportUserFailure>());
    });

    test('does not throw even when repository throws', () async {
      repo.shouldThrow = true;
      await expectLater(
        useCase.execute(
          reporterId: 'userA',
          targetUserId: 'userB',
          reason: ReportReason.spam,
          description: '',
        ),
        completes,
      );
    });
  });
}
