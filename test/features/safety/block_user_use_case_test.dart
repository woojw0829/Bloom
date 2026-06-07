import 'package:bloom/features/match/domain/models/match_record.dart';
import 'package:bloom/features/match/domain/repositories/match_repository.dart';
import 'package:bloom/features/safety/domain/models/blocked_user.dart';
import 'package:bloom/features/safety/domain/repositories/block_repository.dart';
import 'package:bloom/features/safety/domain/usecases/block_user_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeBlockRepo implements BlockRepository {
  String? lastCurrentUserId;
  String? lastBlockedUserId;
  bool shouldThrow = false;

  @override
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    lastCurrentUserId = currentUserId;
    lastBlockedUserId = blockedUserId;
    if (shouldThrow) throw Exception('Firestore error');
  }

  @override
  Future<bool> isBlocked({
    required String currentUserId,
    required String targetUserId,
  }) async =>
      false;

  @override
  Stream<Set<String>> watchBlockedUserIds({required String currentUserId}) =>
      const Stream.empty();

  @override
  Future<List<BlockedUser>> fetchBlockedUsers({
    required String currentUserId,
  }) async =>
      [];

  @override
  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {}
}

class _FakeMatchRepo implements MatchRepository {
  String? lastMatchId;
  bool shouldThrow = false;

  @override
  Future<void> unmatch({
    required String matchId,
    required String currentUserId,
  }) async {
    lastMatchId = matchId;
    if (shouldThrow) throw Exception('no match');
  }

  @override
  Stream<List<MatchRecord>> watchActiveMatches(String _) =>
      const Stream.empty();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeBlockRepo blockRepo;
  late _FakeMatchRepo matchRepo;
  late BlockUserUseCase useCase;

  setUp(() {
    blockRepo = _FakeBlockRepo();
    matchRepo = _FakeMatchRepo();
    useCase = BlockUserUseCase(
      blockRepository: blockRepo,
      matchRepository: matchRepo,
    );
  });

  group('BlockedUser.fromFirestore', () {
    test('uses blockedUserId field when present', () {
      final user = BlockedUser.fromFirestore('docId', {'blockedUserId': 'abc'});
      expect(user.blockedUserId, 'abc');
    });

    test('falls back to doc ID when field is missing', () {
      final user = BlockedUser.fromFirestore('docId', {});
      expect(user.blockedUserId, 'docId');
    });

    test('falls back to doc ID when field is not a string', () {
      final user = BlockedUser.fromFirestore('docId', {'blockedUserId': 42});
      expect(user.blockedUserId, 'docId');
    });
  });

  group('blockMakeMatchId', () {
    test('produces sorted underscore-joined ID', () {
      expect(blockMakeMatchId('userB', 'userA'), 'userA_userB');
    });

    test('is symmetric', () {
      expect(
        blockMakeMatchId('alice', 'bob'),
        blockMakeMatchId('bob', 'alice'),
      );
    });
  });

  group('BlockUserUseCase', () {
    test('rejects empty currentUserId', () async {
      final result = await useCase.execute(
        currentUserId: '',
        blockedUserId: 'user2',
      );
      expect(result, isA<BlockUserValidationError>());
      expect(blockRepo.lastCurrentUserId, isNull);
    });

    test('rejects whitespace-only currentUserId', () async {
      final result = await useCase.execute(
        currentUserId: '   ',
        blockedUserId: 'user2',
      );
      expect(result, isA<BlockUserValidationError>());
      expect(blockRepo.lastCurrentUserId, isNull);
    });

    test('rejects empty blockedUserId', () async {
      final result = await useCase.execute(
        currentUserId: 'user1',
        blockedUserId: '',
      );
      expect(result, isA<BlockUserValidationError>());
      expect(blockRepo.lastCurrentUserId, isNull);
    });

    test('rejects whitespace-only blockedUserId', () async {
      final result = await useCase.execute(
        currentUserId: 'user1',
        blockedUserId: '   ',
      );
      expect(result, isA<BlockUserValidationError>());
      expect(blockRepo.lastCurrentUserId, isNull);
    });

    test('rejects self-block', () async {
      final result = await useCase.execute(
        currentUserId: 'user1',
        blockedUserId: 'user1',
      );
      expect(result, isA<BlockUserValidationError>());
      expect(blockRepo.lastCurrentUserId, isNull);
    });

    test('calls block repository for valid input', () async {
      await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: 'userB',
      );
      expect(blockRepo.lastCurrentUserId, 'userA');
      expect(blockRepo.lastBlockedUserId, 'userB');
    });

    test('returns BlockUserSuccess for valid input', () async {
      final result = await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: 'userB',
      );
      expect(result, isA<BlockUserSuccess>());
    });

    test('deactivates match with deterministic ID after block', () async {
      await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: 'userB',
      );
      expect(matchRepo.lastMatchId, 'userA_userB');
    });

    test('still returns success when match deactivation throws', () async {
      matchRepo.shouldThrow = true;
      final result = await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: 'userB',
      );
      expect(result, isA<BlockUserSuccess>());
    });

    test('returns BlockUserFailure when block repository throws', () async {
      blockRepo.shouldThrow = true;
      final result = await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: 'userB',
      );
      expect(result, isA<BlockUserFailure>());
    });

    test('does not call match repo when block repository throws', () async {
      blockRepo.shouldThrow = true;
      await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: 'userB',
      );
      expect(matchRepo.lastMatchId, isNull);
    });

    test('does not throw even when both repos throw', () async {
      blockRepo.shouldThrow = true;
      matchRepo.shouldThrow = true;
      await expectLater(
        useCase.execute(currentUserId: 'userA', blockedUserId: 'userB'),
        completes,
      );
    });
  });
}
