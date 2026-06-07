import 'package:bloom/features/match/domain/models/like_record.dart';
import 'package:bloom/features/match/domain/repositories/like_repository.dart';
import 'package:bloom/features/match/domain/usecases/load_liked_user_ids_use_case.dart';
import 'package:bloom/features/match/domain/usecases/record_like_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

class _FakeLikeRepository implements LikeRepository {
  final Map<String, String> recorded = {}; // likeId -> type
  bool throws = false;

  @override
  Future<void> recordLike({
    required String fromUserId,
    required String toUserId,
    required LikeType type,
  }) async {
    if (throws) throw Exception('Firestore error');
    recorded[makeLikeId(fromUserId, toUserId)] = type.firestoreValue;
  }

  @override
  Future<Set<String>> loadSentLikedUserIds(String fromUserId) async {
    if (throws) throw Exception('Firestore error');
    return recorded.keys
        .where((id) => id.startsWith('${fromUserId}_'))
        .map((id) => id.substring(fromUserId.length + 1))
        .toSet();
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── LikeType ─────────────────────────────────────────────────────────────────

  group('LikeType', () {
    test('like maps to Firestore value "like"', () {
      expect(LikeType.like.firestoreValue, equals('like'));
    });

    test('superLike maps to Firestore value "super_like"', () {
      expect(LikeType.superLike.firestoreValue, equals('super_like'));
    });
  });

  // ── makeLikeId ────────────────────────────────────────────────────────────────

  group('makeLikeId', () {
    test('produces deterministic id from fromUserId and toUserId', () {
      expect(makeLikeId('userA', 'userB'), equals('userA_userB'));
    });

    test('is not symmetric — from/to order matters', () {
      expect(makeLikeId('userA', 'userB'), isNot(equals(makeLikeId('userB', 'userA'))));
    });
  });

  // ── RecordLikeUseCase ─────────────────────────────────────────────────────────

  group('RecordLikeUseCase', () {
    test('returns validation error when fromUserId is empty', () async {
      final repo = _FakeLikeRepository();
      final useCase = RecordLikeUseCase(repository: repo);

      final result = await useCase.call(
        fromUserId: '',
        toUserId: 'user-b',
        type: LikeType.like,
      );

      expect(result, isA<RecordLikeValidationError>());
      expect(repo.recorded, isEmpty);
    });

    test('returns validation error when toUserId is empty', () async {
      final repo = _FakeLikeRepository();
      final useCase = RecordLikeUseCase(repository: repo);

      final result = await useCase.call(
        fromUserId: 'user-a',
        toUserId: '',
        type: LikeType.like,
      );

      expect(result, isA<RecordLikeValidationError>());
      expect(repo.recorded, isEmpty);
    });

    test('returns validation error when fromUserId equals toUserId', () async {
      final repo = _FakeLikeRepository();
      final useCase = RecordLikeUseCase(repository: repo);

      final result = await useCase.call(
        fromUserId: 'user-a',
        toUserId: 'user-a',
        type: LikeType.like,
      );

      expect(result, isA<RecordLikeValidationError>());
      expect(repo.recorded, isEmpty);
    });

    test('returns failure when repository throws', () async {
      final repo = _FakeLikeRepository()..throws = true;
      final useCase = RecordLikeUseCase(repository: repo);

      final result = await useCase.call(
        fromUserId: 'user-a',
        toUserId: 'user-b',
        type: LikeType.like,
      );

      expect(result, isA<RecordLikeFailure>());
    });

    test('records like with correct type when inputs are valid', () async {
      final repo = _FakeLikeRepository();
      final useCase = RecordLikeUseCase(repository: repo);

      final result = await useCase.call(
        fromUserId: 'user-a',
        toUserId: 'user-b',
        type: LikeType.like,
      );

      expect(result, isA<RecordLikeSuccess>());
      expect(repo.recorded[makeLikeId('user-a', 'user-b')], equals('like'));
    });

    test('records super like with correct type when inputs are valid', () async {
      final repo = _FakeLikeRepository();
      final useCase = RecordLikeUseCase(repository: repo);

      final result = await useCase.call(
        fromUserId: 'user-a',
        toUserId: 'user-b',
        type: LikeType.superLike,
      );

      expect(result, isA<RecordLikeSuccess>());
      expect(
        repo.recorded[makeLikeId('user-a', 'user-b')],
        equals('super_like'),
      );
    });
  });

  // ── LoadLikedUserIdsUseCase ────────────────────────────────────────────────────

  group('LoadLikedUserIdsUseCase', () {
    test('returns empty set when fromUserId is empty', () async {
      final repo = _FakeLikeRepository();
      final useCase = LoadLikedUserIdsUseCase(repository: repo);

      final result = await useCase.call('');

      expect(result, isEmpty);
    });

    test('returns empty set when repository throws', () async {
      final repo = _FakeLikeRepository()..throws = true;
      final useCase = LoadLikedUserIdsUseCase(repository: repo);

      final result = await useCase.call('user-a');

      expect(result, isEmpty);
    });

    test('returns toUserIds from repository on success', () async {
      final repo = _FakeLikeRepository()
        ..recorded[makeLikeId('user-a', 'user-b')] = 'like'
        ..recorded[makeLikeId('user-a', 'user-c')] = 'super_like';
      final useCase = LoadLikedUserIdsUseCase(repository: repo);

      final result = await useCase.call('user-a');

      expect(result, containsAll(['user-b', 'user-c']));
      expect(result, hasLength(2));
    });
  });
}
