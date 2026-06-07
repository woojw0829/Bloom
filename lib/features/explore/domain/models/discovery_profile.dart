import '../../../../shared/models/user_model.dart';

/// Public-facing profile model for discovery cards.
/// Contains only fields needed to render a candidate card.
/// Excludes email, fcmToken, notificationSettings, compatibilityPreferences,
/// and all private subcollection data.
class DiscoveryProfile {
  const DiscoveryProfile({
    required this.id,
    required this.nickname,
    required this.age,
    required this.identity,
    required this.relationshipGoal,
    required this.bio,
    required this.interests,
    required this.profileImages,
    required this.verificationLevel,
    required this.premium,
    required this.premiumBadgeVisible,
    required this.city,
    required this.geoHash,
    required this.updatedAt,
  });

  final String id;
  final String nickname;
  final int age;
  final String identity;
  final String relationshipGoal;
  final String bio;
  final List<String> interests;
  final List<String> profileImages;
  final String verificationLevel;
  final bool premium;
  final bool premiumBadgeVisible;
  final String city;
  final String geoHash;
  final DateTime updatedAt;

  factory DiscoveryProfile.fromUserModel(UserModel user) => DiscoveryProfile(
        id: user.id,
        nickname: user.nickname,
        age: user.age,
        identity: user.identity,
        relationshipGoal: user.relationshipGoal,
        bio: user.bio,
        interests: List.unmodifiable(user.interests),
        profileImages: List.unmodifiable(user.profileImages),
        verificationLevel: user.verificationLevel,
        premium: user.premium,
        premiumBadgeVisible: user.premiumBadgeVisible,
        city: user.city,
        geoHash: user.geoHash,
        updatedAt: user.updatedAt,
      );
}
