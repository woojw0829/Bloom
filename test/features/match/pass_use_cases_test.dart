import 'package:bloom/features/match/domain/repositories/pass_repository.dart';
import 'package:bloom/features/match/domain/usecases/load_passed_user_ids_use_case.dart';
import 'package:bloom/features/match/domain/usecases/record_pass_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

class _FakePassRepository implements PassRepository {
  final Set<String> recorded = {};
  bool throws = false;

  @override
  Future<void> recordPass({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (throws) throw Exception('Firestore error');
    recorded.add(targetUserId);
  }

  @override
  Future<Set<String>> loadPassedUserIds(String currentUserId) async {
    if (throws) throw Exception('Firestore error');
    return Set.of(recorded);
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── RecordPassUseCase ───────────────────────────────────────────────────────

  group('RecordPassUseCase', () {
    test('returns validation error when currentUserId is empty', () async {
      final repo = _FakePassRepository();
      final useCase = RecordPassUseCase(repository: repo);

      final result = await useCase.call(
        currentUserId: '',
        targetUserId: 'user-b',
      );

      expect(result, isA<RecordPassValidationError>());
      expect(repo.recorded, isEmpty);
    });

    test('returns validation error when targetUserId is empty', () async {
      final repo = _FakePassRepository();
      final useCase = RecordPassUseCase(repository: repo);

      final result = await useCase.call(
        currentUserId: 'user-a',
        targetUserId: '',
      );

      expect(result, isA<RecordPassValidationError>());
      expect(repo.recorded, isEmpty);
    });

    test('returns validation error when currentUserId equals targetUserId',
        () async {
      final repo = _FakePassRepository();
      final useCase = RecordPassUseCase(repository: repo);

      final result = await useCase.call(
        currentUserId: 'user-a',
        targetUserId: 'user-a',
      );

      expect(result, isA<RecordPassValidationError>());
      expect(repo.recorded, isEmpty);
    });

    test('returns failure when repository throws', () async {
      final repo = _FakePassRepository()..throws = true;
      final useCase = RecordPassUseCase(repository: repo);

      final result = await useCase.call(
        currentUserId: 'user-a',
        targetUserId: 'user-b',
      );

      expect(result, isA<RecordPassFailure>());
    });

    test('returns success and records target when inputs are valid', () async {
      final repo = _FakePassRepository();
      final useCase = RecordPassUseCase(repository: repo);

      final result = await useCase.call(
        currentUserId: 'user-a',
        targetUserId: 'user-b',
      );

      expect(result, isA<RecordPassSuccess>());
      expect(repo.recorded, contains('user-b'));
    });
  });

  // ── LoadPassedUserIdsUseCase ────────────────────────────────────────────────

  group('LoadPassedUserIdsUseCase', () {
    test('returns empty set when currentUserId is empty', () async {
      final repo = _FakePassRepository();
      final useCase = LoadPassedUserIdsUseCase(repository: repo);

      final result = await useCase.call('');

      expect(result, isEmpty);
    });

    test('returns empty set when repository throws', () async {
      final repo = _FakePassRepository()..throws = true;
      final useCase = LoadPassedUserIdsUseCase(repository: repo);

      final result = await useCase.call('user-a');

      expect(result, isEmpty);
    });

    test('returns IDs from repository on success', () async {
      final repo = _FakePassRepository()..recorded.addAll(['user-b', 'user-c']);
      final useCase = LoadPassedUserIdsUseCase(repository: repo);

      final result = await useCase.call('user-a');

      expect(result, containsAll(['user-b', 'user-c']));
      expect(result, hasLength(2));
    });
  });
}
