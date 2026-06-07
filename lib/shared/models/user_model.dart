import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/utils/timestamp_converter.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String nickname,
    @TimestampConverter() required DateTime birthDate,
    required int age,
    required String identity,
    required String relationshipGoal,
    required String bio,
    @Default(<String>[]) List<String> interests,
    String? occupation,
    String? education,
    int? height,
    UserSocialLinks? socialLinks,
    required String city,
    required String geoHash,
    @Default(<String>[]) List<String> profileImages,
    @Default('public') String profileVisibility,
    @Default('active') String accountStatus,
    @Default('none') String verificationLevel,
    @Default(false) bool premium,
    @Default(false) bool premiumBadgeVisible,
    @Default('') String fcmToken,
    @Default(false) bool isOnline,
    @TimestampConverter() required DateTime lastSeen,
    @Default(true) bool onlineStatusVisible,
    @Default(true) bool lastSeenVisible,
    required UserNotificationSettings notificationSettings,
    required UserCompatibilityPreferences compatibilityPreferences,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

@freezed
class UserNotificationSettings with _$UserNotificationSettings {
  const factory UserNotificationSettings({
    @Default(true) bool match,
    @Default(true) bool message,
    @Default(true) bool like,
    @Default(true) bool verification,
  }) = _UserNotificationSettings;

  factory UserNotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$UserNotificationSettingsFromJson(json);
}

@freezed
class UserCompatibilityPreferences with _$UserCompatibilityPreferences {
  const factory UserCompatibilityPreferences({
    @Default(18) int minAge,
    @Default(45) int maxAge,
    @Default(50) int maxDistanceKm,
    @Default(<String>[]) List<String> identities,
    @Default(<String>[]) List<String> relationshipGoals,
  }) = _UserCompatibilityPreferences;

  factory UserCompatibilityPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserCompatibilityPreferencesFromJson(json);
}

@freezed
class UserSocialLinks with _$UserSocialLinks {
  const factory UserSocialLinks({
    String? instagram,
    String? twitter,
    String? tiktok,
  }) = _UserSocialLinks;

  factory UserSocialLinks.fromJson(Map<String, dynamic> json) =>
      _$UserSocialLinksFromJson(json);
}
