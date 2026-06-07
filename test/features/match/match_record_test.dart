import 'package:bloom/features/match/domain/models/match_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── MatchRecord.includesUser ────────────────────────────────────────────────

  group('MatchRecord.includesUser', () {
    const match = MatchRecord(
      id: 'userA_userB',
      users: ['userA', 'userB'],
      compatibilityScore: 0,
      lastMessagePreview: '',
      active: true,
    );

    test('returns true for a user in the match', () {
      expect(match.includesUser('userA'), isTrue);
      expect(match.includesUser('userB'), isTrue);
    });

    test('returns false for a user not in the match', () {
      expect(match.includesUser('userC'), isFalse);
      expect(match.includesUser(''), isFalse);
    });
  });

  // ── MatchRecord.otherUserId ─────────────────────────────────────────────────

  group('MatchRecord.otherUserId', () {
    const match = MatchRecord(
      id: 'userA_userB',
      users: ['userA', 'userB'],
      compatibilityScore: 0,
      lastMessagePreview: '',
      active: true,
    );

    test('returns the other user when current user is first', () {
      expect(match.otherUserId('userA'), equals('userB'));
    });

    test('returns the other user when current user is second', () {
      expect(match.otherUserId('userB'), equals('userA'));
    });

    test('returns null when current user is not in the match', () {
      expect(match.otherUserId('userC'), isNull);
    });

    test('returns null for empty users list', () {
      const empty = MatchRecord(
        id: '',
        users: [],
        compatibilityScore: 0,
        lastMessagePreview: '',
        active: false,
      );
      expect(empty.otherUserId('userA'), isNull);
    });
  });

  // ── MatchRecord.fromFirestore ───────────────────────────────────────────────

  group('MatchRecord.fromFirestore', () {
    test('parses all valid fields', () {
      final data = <String, dynamic>{
        'id': 'userA_userB',
        'users': ['userA', 'userB'],
        'compatibilityScore': 42,
        'lastMessagePreview': 'Hello',
        'active': true,
      };
      final record = MatchRecord.fromFirestore(data);
      expect(record.id, equals('userA_userB'));
      expect(record.users, containsAll(['userA', 'userB']));
      expect(record.compatibilityScore, equals(42));
      expect(record.lastMessagePreview, equals('Hello'));
      expect(record.active, isTrue);
      expect(record.createdAt, isNull);
      expect(record.lastMessageAt, isNull);
    });

    test('uses defaults for missing fields', () {
      final record = MatchRecord.fromFirestore(const {});
      expect(record.id, equals(''));
      expect(record.users, isEmpty);
      expect(record.compatibilityScore, equals(0));
      expect(record.lastMessagePreview, equals(''));
      expect(record.active, isFalse);
    });

    test('ignores non-string entries in users list', () {
      final data = <String, dynamic>{
        'users': ['userA', 123, null, 'userB'],
      };
      final record = MatchRecord.fromFirestore(data);
      expect(record.users, containsAll(['userA', 'userB']));
      expect(record.users, hasLength(2));
    });

    test('handles null users field gracefully', () {
      final data = <String, dynamic>{'users': null};
      final record = MatchRecord.fromFirestore(data);
      expect(record.users, isEmpty);
    });
  });
}
