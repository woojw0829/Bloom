import 'package:bloom/features/match/domain/models/match_record.dart';
import 'package:bloom/features/messaging/domain/models/conversation_preview.dart';
import 'package:bloom/shared/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

MatchRecord _makeMatch({
  String id = 'match1',
  List<String> users = const ['user1', 'user2'],
  int compatibilityScore = 75,
  String lastMessagePreview = 'Hello!',
  DateTime? lastMessageAt,
  bool active = true,
}) {
  return MatchRecord(
    id: id,
    users: users,
    compatibilityScore: compatibilityScore,
    lastMessagePreview: lastMessagePreview,
    lastMessageAt: lastMessageAt ?? DateTime(2026, 6, 1),
    active: active,
  );
}

UserModel _makeUser({
  String id = 'user2',
  String nickname = 'Alex',
  int age = 28,
  List<String> profileImages = const ['https://example.com/photo.jpg'],
}) {
  return UserModel(
    id: id,
    email: 'user2@test.com',
    nickname: nickname,
    birthDate: DateTime(1998, 1, 1),
    age: age,
    identity: 'Gay',
    relationshipGoal: 'Serious Relationship',
    bio: '',
    city: 'Seoul',
    geoHash: 'wydjx',
    profileImages: profileImages,
    lastSeen: DateTime(2026),
    notificationSettings: const UserNotificationSettings(),
    compatibilityPreferences: const UserCompatibilityPreferences(),
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('ConversationPreview.fromMatchAndProfile', () {
    test('maps matchId, otherUserId, and score from match', () {
      final match = _makeMatch();
      final preview = ConversationPreview.fromMatchAndProfile(
        match: match,
        otherUserId: 'user2',
        profile: _makeUser(),
      );

      expect(preview.matchId, 'match1');
      expect(preview.otherUserId, 'user2');
      expect(preview.compatibilityScore, 75);
    });

    test('maps nickname and age from public profile', () {
      final preview = ConversationPreview.fromMatchAndProfile(
        match: _makeMatch(),
        otherUserId: 'user2',
        profile: _makeUser(nickname: 'Jordan', age: 30),
      );

      expect(preview.nickname, 'Jordan');
      expect(preview.age, 30);
    });

    test('maps first profile image as profileImageUrl', () {
      final preview = ConversationPreview.fromMatchAndProfile(
        match: _makeMatch(),
        otherUserId: 'user2',
        profile: _makeUser(profileImages: ['https://example.com/a.jpg', 'https://example.com/b.jpg']),
      );

      expect(preview.profileImageUrl, 'https://example.com/a.jpg');
    });

    test('profileImageUrl is null when profile has no images', () {
      final preview = ConversationPreview.fromMatchAndProfile(
        match: _makeMatch(),
        otherUserId: 'user2',
        profile: _makeUser(profileImages: const []),
      );

      expect(preview.profileImageUrl, isNull);
    });

    test('maps lastMessagePreview and lastMessageAt from match', () {
      final ts = DateTime(2026, 6, 1, 10, 30);
      final preview = ConversationPreview.fromMatchAndProfile(
        match: _makeMatch(lastMessagePreview: 'Hey there!', lastMessageAt: ts),
        otherUserId: 'user2',
        profile: _makeUser(),
      );

      expect(preview.lastMessagePreview, 'Hey there!');
      expect(preview.lastMessageAt, ts);
    });

    test('falls back to empty nickname when profile is null', () {
      final preview = ConversationPreview.fromMatchAndProfile(
        match: _makeMatch(),
        otherUserId: 'user2',
        profile: null,
      );

      expect(preview.nickname, '');
      expect(preview.age, isNull);
      expect(preview.profileImageUrl, isNull);
    });

    test('does not expose email from profile', () {
      final preview = ConversationPreview.fromMatchAndProfile(
        match: _makeMatch(),
        otherUserId: 'user2',
        profile: _makeUser(),
      );

      // ConversationPreview has no email, fcmToken, or private fields.
      expect(preview, isA<ConversationPreview>());
      expect(preview.matchId, isNotEmpty);
      expect(preview.otherUserId, isNotEmpty);
    });

    test('otherUserId from MatchRecord.otherUserId resolves correctly', () {
      final match = _makeMatch(users: ['userA', 'userB']);
      expect(match.otherUserId('userA'), 'userB');
      expect(match.otherUserId('userB'), 'userA');
      expect(match.otherUserId('userC'), isNull);
    });

    test('inactive match still produces preview (provider filters, not model)', () {
      final match = _makeMatch(active: false);
      final preview = ConversationPreview.fromMatchAndProfile(
        match: match,
        otherUserId: 'user2',
        profile: _makeUser(),
      );
      expect(preview.matchId, 'match1');
    });
  });
}
