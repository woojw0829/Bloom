import 'package:bloom/features/safety/domain/models/blocked_user.dart';
import 'package:bloom/features/safety/domain/repositories/block_repository.dart';
import 'package:bloom/features/safety/domain/usecases/unblock_user_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake ──────────────────────────────────────────────────────────────────────

class _FakeBlockRepo implements BlockRepository {
  String? lastCurrentUserId;
  String? lastBlockedUserId;
  bool shouldThrow = false;

  @override
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {}

  @override
  Future<bool> isBlocked({
    required String currentUserId,
    required String targetUserId,
  }) async => false;

  @override
  Stream<Set<String>> watchBlockedUserIds({required String currentUserId}) =>
      Stream.value({});

  @override
  Future<List<BlockedUser>> fetchBlockedUsers({
    required String currentUserId,
  }) async => [];

  @override
  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    lastCurrentUserId = currentUserId;
    lastBlockedUserId = blockedUserId;
    if (shouldThrow) throw Exception('Firestore error');
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeBlockRepo repo;
  late UnblockUserUseCase useCase;

  setUp(() {
    repo = _FakeBlockRepo();
    useCase = UnblockUserUseCase(blockRepository: repo);
  });

  // ── Validation ─────────────────────────────────────────────────────────────

  group('UnblockUserUseCase validation', () {
    test('rejects empty currentUserId', () async {
      final result = await useCase.execute(
        currentUserId: '',
        blockedUserId: 'userB',
      );
      expect(result, isA<UnblockUserValidationError>());
      expect(repo.lastCurrentUserId, isNull);
    });

    test('rejects whitespace-only currentUserId', () async {
      final result = await useCase.execute(
        currentUserId: '   ',
        blockedUserId: 'userB',
      );
      expect(result, isA<UnblockUserValidationError>());
    });

    test('rejects empty blockedUserId', () async {
      final result = await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: '',
      );
      expect(result, isA<UnblockUserValidationError>());
      expect(repo.lastCurrentUserId, isNull);
    });

    test('rejects whitespace-only blockedUserId', () async {
      final result = await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: '   ',
      );
      expect(result, isA<UnblockUserValidationError>());
    });

    test('rejects self-unblock', () async {
      final result = await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: 'userA',
      );
      expect(result, isA<UnblockUserValidationError>());
      expect(repo.lastCurrentUserId, isNull);
    });
  });

  // ── Behavior ───────────────────────────────────────────────────────────────

  group('UnblockUserUseCase behavior', () {
    test('calls repository with correct args for valid input', () async {
      await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: 'userB',
      );
      expect(repo.lastCurrentUserId, 'userA');
      expect(repo.lastBlockedUserId, 'userB');
    });

    test('returns UnblockUserSuccess for valid input', () async {
      final result = await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: 'userB',
      );
      expect(result, isA<UnblockUserSuccess>());
    });

    test('returns UnblockUserFailure when repository throws', () async {
      repo.shouldThrow = true;
      final result = await useCase.execute(
        currentUserId: 'userA',
        blockedUserId: 'userB',
      );
      expect(result, isA<UnblockUserFailure>());
    });

    test('does not throw even when repository throws', () async {
      repo.shouldThrow = true;
      await expectLater(
        useCase.execute(currentUserId: 'userA', blockedUserId: 'userB'),
        completes,
      );
    });

    test('ValidationError carries a reason string', () async {
      final result = await useCase.execute(
        currentUserId: '',
        blockedUserId: 'userB',
      ) as UnblockUserValidationError;
      expect(result.reason, isNotEmpty);
    });
  });
}
