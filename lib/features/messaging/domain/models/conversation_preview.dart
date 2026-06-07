import '../../../../shared/models/user_model.dart';
import '../../../match/domain/models/match_record.dart';

/// Read-only view model for a single row in the conversation list.
///
/// Exposes only publicly-safe profile information — no email, fcmToken,
/// notificationSettings, compatibilityPreferences, or exact location.
class ConversationPreview {
  const ConversationPreview({
    required this.matchId,
    required this.otherUserId,
    required this.nickname,
    this.age,
    this.profileImageUrl,
    required this.lastMessagePreview,
    this.lastMessageAt,
    required this.compatibilityScore,
  });

  final String matchId;
  final String otherUserId;
  final String nickname;
  final int? age;
  final String? profileImageUrl;
  final String lastMessagePreview;
  final DateTime? lastMessageAt;
  final int compatibilityScore;

  factory ConversationPreview.fromMatchAndProfile({
    required MatchRecord match,
    required String otherUserId,
    UserModel? profile,
  }) {
    return ConversationPreview(
      matchId: match.id,
      otherUserId: otherUserId,
      nickname: profile?.nickname ?? '',
      age: profile?.age,
      profileImageUrl: profile?.profileImages.firstOrNull,
      lastMessagePreview: match.lastMessagePreview,
      lastMessageAt: match.lastMessageAt,
      compatibilityScore: match.compatibilityScore,
    );
  }
}
