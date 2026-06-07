// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserModelImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  nickname: json['nickname'] as String,
  birthDate: const TimestampConverter().fromJson(json['birthDate']),
  age: (json['age'] as num).toInt(),
  identity: json['identity'] as String,
  relationshipGoal: json['relationshipGoal'] as String,
  bio: json['bio'] as String,
  interests:
      (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  occupation: json['occupation'] as String?,
  education: json['education'] as String?,
  height: (json['height'] as num?)?.toInt(),
  socialLinks: json['socialLinks'] == null
      ? null
      : UserSocialLinks.fromJson(json['socialLinks'] as Map<String, dynamic>),
  city: json['city'] as String,
  geoHash: json['geoHash'] as String,
  profileImages:
      (json['profileImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  profileVisibility: json['profileVisibility'] as String? ?? 'public',
  accountStatus: json['accountStatus'] as String? ?? 'active',
  verificationLevel: json['verificationLevel'] as String? ?? 'none',
  premium: json['premium'] as bool? ?? false,
  premiumBadgeVisible: json['premiumBadgeVisible'] as bool? ?? false,
  fcmToken: json['fcmToken'] as String? ?? '',
  isOnline: json['isOnline'] as bool? ?? false,
  lastSeen: const TimestampConverter().fromJson(json['lastSeen']),
  onlineStatusVisible: json['onlineStatusVisible'] as bool? ?? true,
  lastSeenVisible: json['lastSeenVisible'] as bool? ?? true,
  notificationSettings: UserNotificationSettings.fromJson(
    json['notificationSettings'] as Map<String, dynamic>,
  ),
  compatibilityPreferences: UserCompatibilityPreferences.fromJson(
    json['compatibilityPreferences'] as Map<String, dynamic>,
  ),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$$UserModelImplToJson(
  _$UserModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'nickname': instance.nickname,
  if (const TimestampConverter().toJson(instance.birthDate) case final value?)
    'birthDate': value,
  'age': instance.age,
  'identity': instance.identity,
  'relationshipGoal': instance.relationshipGoal,
  'bio': instance.bio,
  'interests': instance.interests,
  if (instance.occupation case final value?) 'occupation': value,
  if (instance.education case final value?) 'education': value,
  if (instance.height case final value?) 'height': value,
  if (instance.socialLinks?.toJson() case final value?) 'socialLinks': value,
  'city': instance.city,
  'geoHash': instance.geoHash,
  'profileImages': instance.profileImages,
  'profileVisibility': instance.profileVisibility,
  'accountStatus': instance.accountStatus,
  'verificationLevel': instance.verificationLevel,
  'premium': instance.premium,
  'premiumBadgeVisible': instance.premiumBadgeVisible,
  'fcmToken': instance.fcmToken,
  'isOnline': instance.isOnline,
  if (const TimestampConverter().toJson(instance.lastSeen) case final value?)
    'lastSeen': value,
  'onlineStatusVisible': instance.onlineStatusVisible,
  'lastSeenVisible': instance.lastSeenVisible,
  'notificationSettings': instance.notificationSettings.toJson(),
  'compatibilityPreferences': instance.compatibilityPreferences.toJson(),
  if (const TimestampConverter().toJson(instance.createdAt) case final value?)
    'createdAt': value,
  if (const TimestampConverter().toJson(instance.updatedAt) case final value?)
    'updatedAt': value,
};

_$UserNotificationSettingsImpl _$$UserNotificationSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$UserNotificationSettingsImpl(
  match: json['match'] as bool? ?? true,
  message: json['message'] as bool? ?? true,
  like: json['like'] as bool? ?? true,
  verification: json['verification'] as bool? ?? true,
);

Map<String, dynamic> _$$UserNotificationSettingsImplToJson(
  _$UserNotificationSettingsImpl instance,
) => <String, dynamic>{
  'match': instance.match,
  'message': instance.message,
  'like': instance.like,
  'verification': instance.verification,
};

_$UserCompatibilityPreferencesImpl _$$UserCompatibilityPreferencesImplFromJson(
  Map<String, dynamic> json,
) => _$UserCompatibilityPreferencesImpl(
  minAge: (json['minAge'] as num?)?.toInt() ?? 18,
  maxAge: (json['maxAge'] as num?)?.toInt() ?? 45,
  maxDistanceKm: (json['maxDistanceKm'] as num?)?.toInt() ?? 50,
  identities:
      (json['identities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  relationshipGoals:
      (json['relationshipGoals'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$$UserCompatibilityPreferencesImplToJson(
  _$UserCompatibilityPreferencesImpl instance,
) => <String, dynamic>{
  'minAge': instance.minAge,
  'maxAge': instance.maxAge,
  'maxDistanceKm': instance.maxDistanceKm,
  'identities': instance.identities,
  'relationshipGoals': instance.relationshipGoals,
};

_$UserSocialLinksImpl _$$UserSocialLinksImplFromJson(
  Map<String, dynamic> json,
) => _$UserSocialLinksImpl(
  instagram: json['instagram'] as String?,
  twitter: json['twitter'] as String?,
  tiktok: json['tiktok'] as String?,
);

Map<String, dynamic> _$$UserSocialLinksImplToJson(
  _$UserSocialLinksImpl instance,
) => <String, dynamic>{
  if (instance.instagram case final value?) 'instagram': value,
  if (instance.twitter case final value?) 'twitter': value,
  if (instance.tiktok case final value?) 'tiktok': value,
};
