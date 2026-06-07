import 'package:bloom/features/match/domain/models/match_record.dart';
import 'package:bloom/features/match/domain/repositories/match_repository.dart';
import 'package:bloom/features/match/domain/usecases/unmatch_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements MatchRepository {
  String? lastMatchId;
  String? lastCurrentUserId;
  bool shouldThrow = false;

  @override
  Future<void> unmatch({
    required String matchId,
    required String currentUserId,
  }) async {
    lastMatchId = matchId;
    lastCurrentUserId = currentUserId;
    if (shouldThrow) throw Exception('Firestore error');
  }

  @override
  Stream<List<MatchRecord>> watchActiveMatches(String _) =>
      const Stream.empty();
}

void main() {
  late _FakeRepo repo;
  late UnmatchUseCase useCase;

  setUp(() {
    repo = _FakeRepo();
    useCase = UnmatchUseCase(repo);
  });

  group('UnmatchUseCase', () {
    test('rejects empty matchId — returns validation error', () async {
      final result = await useCase.execute(
        matchId: '',
        currentUserId: 'user1',
      );
      expect(result, isA<UnmatchValidationError>());
      expect(repo.lastMatchId, isNull);
    });

    test('rejects whitespace-only matchId', () async {
      final result = await useCase.execute(
        matchId: '   ',
        currentUserId: 'user1',
      );
      expect(result, isA<UnmatchValidationError>());
      expect(repo.lastMatchId, isNull);
    });

    test('rejects empty currentUserId — returns validation error', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        currentUserId: '',
      );
      expect(result, isA<UnmatchValidationError>());
      expect(repo.lastCurrentUserId, isNull);
    });

    test('rejects whitespace-only currentUserId', () async {
      final result = await useCase.execute(
        matchId: 'match1',
        currentUserId: '   ',
      );
      expect(result, isA<UnmatchValidationError>());
      expect(repo.lastCurrentUserId, isNull);
    });

    test('calls repository for valid input', () async {
      await useCase.execute(matchId: 'match1', currentUserId: 'user1');
      expect(repo.lastMatchId, 'match1');
      expect(repo.lastCurrentUserId, 'user1');
    });

    test('returns UnmatchSuccess for valid input', () async {
      final result =
          await useCase.execute(matchId: 'match1', currentUserId: 'user1');
      expect(result, isA<UnmatchSuccess>());
    });

    test('returns UnmatchFailure when repository throws', () async {
      repo.shouldThrow = true;
      final result =
          await useCase.execute(matchId: 'match1', currentUserId: 'user1');
      expect(result, isA<UnmatchFailure>());
    });

    test('does not throw when repository throws', () async {
      repo.shouldThrow = true;
      await expectLater(
        useCase.execute(matchId: 'match1', currentUserId: 'user1'),
        completes,
      );
    });
  });
}
