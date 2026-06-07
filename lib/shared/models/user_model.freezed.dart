// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get birthDate => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String get identity => throw _privateConstructorUsedError;
  String get relationshipGoal => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  List<String> get interests => throw _privateConstructorUsedError;
  String? get occupation => throw _privateConstructorUsedError;
  String? get education => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  UserSocialLinks? get socialLinks => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get geoHash => throw _privateConstructorUsedError;
  List<String> get profileImages => throw _privateConstructorUsedError;
  String get profileVisibility => throw _privateConstructorUsedError;
  String get accountStatus => throw _privateConstructorUsedError;
  String get verificationLevel => throw _privateConstructorUsedError;
  bool get premium => throw _privateConstructorUsedError;
  bool get premiumBadgeVisible => throw _privateConstructorUsedError;
  String get fcmToken => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get lastSeen => throw _privateConstructorUsedError;
  bool get onlineStatusVisible => throw _privateConstructorUsedError;
  bool get lastSeenVisible => throw _privateConstructorUsedError;
  UserNotificationSettings get notificationSettings =>
      throw _privateConstructorUsedError;
  UserCompatibilityPreferences get compatibilityPreferences =>
      throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String id,
    String email,
    String nickname,
    @TimestampConverter() DateTime birthDate,
    int age,
    String identity,
    String relationshipGoal,
    String bio,
    List<String> interests,
    String? occupation,
    String? education,
    int? height,
    UserSocialLinks? socialLinks,
    String city,
    String geoHash,
    List<String> profileImages,
    String profileVisibility,
    String accountStatus,
    String verificationLevel,
    bool premium,
    bool premiumBadgeVisible,
    String fcmToken,
    bool isOnline,
    @TimestampConverter() DateTime lastSeen,
    bool onlineStatusVisible,
    bool lastSeenVisible,
    UserNotificationSettings notificationSettings,
    UserCompatibilityPreferences compatibilityPreferences,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });

  $UserSocialLinksCopyWith<$Res>? get socialLinks;
  $UserNotificationSettingsCopyWith<$Res> get notificationSettings;
  $UserCompatibilityPreferencesCopyWith<$Res> get compatibilityPreferences;
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? nickname = null,
    Object? birthDate = null,
    Object? age = null,
    Object? identity = null,
    Object? relationshipGoal = null,
    Object? bio = null,
    Object? interests = null,
    Object? occupation = freezed,
    Object? education = freezed,
    Object? height = freezed,
    Object? socialLinks = freezed,
    Object? city = null,
    Object? geoHash = null,
    Object? profileImages = null,
    Object? profileVisibility = null,
    Object? accountStatus = null,
    Object? verificationLevel = null,
    Object? premium = null,
    Object? premiumBadgeVisible = null,
    Object? fcmToken = null,
    Object? isOnline = null,
    Object? lastSeen = null,
    Object? onlineStatusVisible = null,
    Object? lastSeenVisible = null,
    Object? notificationSettings = null,
    Object? compatibilityPreferences = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            birthDate: null == birthDate
                ? _value.birthDate
                : birthDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            age: null == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                      as int,
            identity: null == identity
                ? _value.identity
                : identity // ignore: cast_nullable_to_non_nullable
                      as String,
            relationshipGoal: null == relationshipGoal
                ? _value.relationshipGoal
                : relationshipGoal // ignore: cast_nullable_to_non_nullable
                      as String,
            bio: null == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String,
            interests: null == interests
                ? _value.interests
                : interests // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            occupation: freezed == occupation
                ? _value.occupation
                : occupation // ignore: cast_nullable_to_non_nullable
                      as String?,
            education: freezed == education
                ? _value.education
                : education // ignore: cast_nullable_to_non_nullable
                      as String?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int?,
            socialLinks: freezed == socialLinks
                ? _value.socialLinks
                : socialLinks // ignore: cast_nullable_to_non_nullable
                      as UserSocialLinks?,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            geoHash: null == geoHash
                ? _value.geoHash
                : geoHash // ignore: cast_nullable_to_non_nullable
                      as String,
            profileImages: null == profileImages
                ? _value.profileImages
                : profileImages // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            profileVisibility: null == profileVisibility
                ? _value.profileVisibility
                : profileVisibility // ignore: cast_nullable_to_non_nullable
                      as String,
            accountStatus: null == accountStatus
                ? _value.accountStatus
                : accountStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            verificationLevel: null == verificationLevel
                ? _value.verificationLevel
                : verificationLevel // ignore: cast_nullable_to_non_nullable
                      as String,
            premium: null == premium
                ? _value.premium
                : premium // ignore: cast_nullable_to_non_nullable
                      as bool,
            premiumBadgeVisible: null == premiumBadgeVisible
                ? _value.premiumBadgeVisible
                : premiumBadgeVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
            fcmToken: null == fcmToken
                ? _value.fcmToken
                : fcmToken // ignore: cast_nullable_to_non_nullable
                      as String,
            isOnline: null == isOnline
                ? _value.isOnline
                : isOnline // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastSeen: null == lastSeen
                ? _value.lastSeen
                : lastSeen // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            onlineStatusVisible: null == onlineStatusVisible
                ? _value.onlineStatusVisible
                : onlineStatusVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastSeenVisible: null == lastSeenVisible
                ? _value.lastSeenVisible
                : lastSeenVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
            notificationSettings: null == notificationSettings
                ? _value.notificationSettings
                : notificationSettings // ignore: cast_nullable_to_non_nullable
                      as UserNotificationSettings,
            compatibilityPreferences: null == compatibilityPreferences
                ? _value.compatibilityPreferences
                : compatibilityPreferences // ignore: cast_nullable_to_non_nullable
                      as UserCompatibilityPreferences,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSocialLinksCopyWith<$Res>? get socialLinks {
    if (_value.socialLinks == null) {
      return null;
    }

    return $UserSocialLinksCopyWith<$Res>(_value.socialLinks!, (value) {
      return _then(_value.copyWith(socialLinks: value) as $Val);
    });
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserNotificationSettingsCopyWith<$Res> get notificationSettings {
    return $UserNotificationSettingsCopyWith<$Res>(
      _value.notificationSettings,
      (value) {
        return _then(_value.copyWith(notificationSettings: value) as $Val);
      },
    );
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCompatibilityPreferencesCopyWith<$Res> get compatibilityPreferences {
    return $UserCompatibilityPreferencesCopyWith<$Res>(
      _value.compatibilityPreferences,
      (value) {
        return _then(_value.copyWith(compatibilityPreferences: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String nickname,
    @TimestampConverter() DateTime birthDate,
    int age,
    String identity,
    String relationshipGoal,
    String bio,
    List<String> interests,
    String? occupation,
    String? education,
    int? height,
    UserSocialLinks? socialLinks,
    String city,
    String geoHash,
    List<String> profileImages,
    String profileVisibility,
    String accountStatus,
    String verificationLevel,
    bool premium,
    bool premiumBadgeVisible,
    String fcmToken,
    bool isOnline,
    @TimestampConverter() DateTime lastSeen,
    bool onlineStatusVisible,
    bool lastSeenVisible,
    UserNotificationSettings notificationSettings,
    UserCompatibilityPreferences compatibilityPreferences,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime updatedAt,
  });

  @override
  $UserSocialLinksCopyWith<$Res>? get socialLinks;
  @override
  $UserNotificationSettingsCopyWith<$Res> get notificationSettings;
  @override
  $UserCompatibilityPreferencesCopyWith<$Res> get compatibilityPreferences;
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? nickname = null,
    Object? birthDate = null,
    Object? age = null,
    Object? identity = null,
    Object? relationshipGoal = null,
    Object? bio = null,
    Object? interests = null,
    Object? occupation = freezed,
    Object? education = freezed,
    Object? height = freezed,
    Object? socialLinks = freezed,
    Object? city = null,
    Object? geoHash = null,
    Object? profileImages = null,
    Object? profileVisibility = null,
    Object? accountStatus = null,
    Object? verificationLevel = null,
    Object? premium = null,
    Object? premiumBadgeVisible = null,
    Object? fcmToken = null,
    Object? isOnline = null,
    Object? lastSeen = null,
    Object? onlineStatusVisible = null,
    Object? lastSeenVisible = null,
    Object? notificationSettings = null,
    Object? compatibilityPreferences = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$UserModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        birthDate: null == birthDate
            ? _value.birthDate
            : birthDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        age: null == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int,
        identity: null == identity
            ? _value.identity
            : identity // ignore: cast_nullable_to_non_nullable
                  as String,
        relationshipGoal: null == relationshipGoal
            ? _value.relationshipGoal
            : relationshipGoal // ignore: cast_nullable_to_non_nullable
                  as String,
        bio: null == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String,
        interests: null == interests
            ? _value._interests
            : interests // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        occupation: freezed == occupation
            ? _value.occupation
            : occupation // ignore: cast_nullable_to_non_nullable
                  as String?,
        education: freezed == education
            ? _value.education
            : education // ignore: cast_nullable_to_non_nullable
                  as String?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        socialLinks: freezed == socialLinks
            ? _value.socialLinks
            : socialLinks // ignore: cast_nullable_to_non_nullable
                  as UserSocialLinks?,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        geoHash: null == geoHash
            ? _value.geoHash
            : geoHash // ignore: cast_nullable_to_non_nullable
                  as String,
        profileImages: null == profileImages
            ? _value._profileImages
            : profileImages // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        profileVisibility: null == profileVisibility
            ? _value.profileVisibility
            : profileVisibility // ignore: cast_nullable_to_non_nullable
                  as String,
        accountStatus: null == accountStatus
            ? _value.accountStatus
            : accountStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        verificationLevel: null == verificationLevel
            ? _value.verificationLevel
            : verificationLevel // ignore: cast_nullable_to_non_nullable
                  as String,
        premium: null == premium
            ? _value.premium
            : premium // ignore: cast_nullable_to_non_nullable
                  as bool,
        premiumBadgeVisible: null == premiumBadgeVisible
            ? _value.premiumBadgeVisible
            : premiumBadgeVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
        fcmToken: null == fcmToken
            ? _value.fcmToken
            : fcmToken // ignore: cast_nullable_to_non_nullable
                  as String,
        isOnline: null == isOnline
            ? _value.isOnline
            : isOnline // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastSeen: null == lastSeen
            ? _value.lastSeen
            : lastSeen // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        onlineStatusVisible: null == onlineStatusVisible
            ? _value.onlineStatusVisible
            : onlineStatusVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastSeenVisible: null == lastSeenVisible
            ? _value.lastSeenVisible
            : lastSeenVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
        notificationSettings: null == notificationSettings
            ? _value.notificationSettings
            : notificationSettings // ignore: cast_nullable_to_non_nullable
                  as UserNotificationSettings,
        compatibilityPreferences: null == compatibilityPreferences
            ? _value.compatibilityPreferences
            : compatibilityPreferences // ignore: cast_nullable_to_non_nullable
                  as UserCompatibilityPreferences,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.id,
    required this.email,
    required this.nickname,
    @TimestampConverter() required this.birthDate,
    required this.age,
    required this.identity,
    required this.relationshipGoal,
    required this.bio,
    final List<String> interests = const <String>[],
    this.occupation,
    this.education,
    this.height,
    this.socialLinks,
    required this.city,
    required this.geoHash,
    final List<String> profileImages = const <String>[],
    this.profileVisibility = 'public',
    this.accountStatus = 'active',
    this.verificationLevel = 'none',
    this.premium = false,
    this.premiumBadgeVisible = false,
    this.fcmToken = '',
    this.isOnline = false,
    @TimestampConverter() required this.lastSeen,
    this.onlineStatusVisible = true,
    this.lastSeenVisible = true,
    required this.notificationSettings,
    required this.compatibilityPreferences,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() required this.updatedAt,
  }) : _interests = interests,
       _profileImages = profileImages;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String nickname;
  @override
  @TimestampConverter()
  final DateTime birthDate;
  @override
  final int age;
  @override
  final String identity;
  @override
  final String relationshipGoal;
  @override
  final String bio;
  final List<String> _interests;
  @override
  @JsonKey()
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  @override
  final String? occupation;
  @override
  final String? education;
  @override
  final int? height;
  @override
  final UserSocialLinks? socialLinks;
  @override
  final String city;
  @override
  final String geoHash;
  final List<String> _profileImages;
  @override
  @JsonKey()
  List<String> get profileImages {
    if (_profileImages is EqualUnmodifiableListView) return _profileImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_profileImages);
  }

  @override
  @JsonKey()
  final String profileVisibility;
  @override
  @JsonKey()
  final String accountStatus;
  @override
  @JsonKey()
  final String verificationLevel;
  @override
  @JsonKey()
  final bool premium;
  @override
  @JsonKey()
  final bool premiumBadgeVisible;
  @override
  @JsonKey()
  final String fcmToken;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  @TimestampConverter()
  final DateTime lastSeen;
  @override
  @JsonKey()
  final bool onlineStatusVisible;
  @override
  @JsonKey()
  final bool lastSeenVisible;
  @override
  final UserNotificationSettings notificationSettings;
  @override
  final UserCompatibilityPreferences compatibilityPreferences;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, nickname: $nickname, birthDate: $birthDate, age: $age, identity: $identity, relationshipGoal: $relationshipGoal, bio: $bio, interests: $interests, occupation: $occupation, education: $education, height: $height, socialLinks: $socialLinks, city: $city, geoHash: $geoHash, profileImages: $profileImages, profileVisibility: $profileVisibility, accountStatus: $accountStatus, verificationLevel: $verificationLevel, premium: $premium, premiumBadgeVisible: $premiumBadgeVisible, fcmToken: $fcmToken, isOnline: $isOnline, lastSeen: $lastSeen, onlineStatusVisible: $onlineStatusVisible, lastSeenVisible: $lastSeenVisible, notificationSettings: $notificationSettings, compatibilityPreferences: $compatibilityPreferences, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.identity, identity) ||
                other.identity == identity) &&
            (identical(other.relationshipGoal, relationshipGoal) ||
                other.relationshipGoal == relationshipGoal) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality().equals(
              other._interests,
              _interests,
            ) &&
            (identical(other.occupation, occupation) ||
                other.occupation == occupation) &&
            (identical(other.education, education) ||
                other.education == education) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.socialLinks, socialLinks) ||
                other.socialLinks == socialLinks) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.geoHash, geoHash) || other.geoHash == geoHash) &&
            const DeepCollectionEquality().equals(
              other._profileImages,
              _profileImages,
            ) &&
            (identical(other.profileVisibility, profileVisibility) ||
                other.profileVisibility == profileVisibility) &&
            (identical(other.accountStatus, accountStatus) ||
                other.accountStatus == accountStatus) &&
            (identical(other.verificationLevel, verificationLevel) ||
                other.verificationLevel == verificationLevel) &&
            (identical(other.premium, premium) || other.premium == premium) &&
            (identical(other.premiumBadgeVisible, premiumBadgeVisible) ||
                other.premiumBadgeVisible == premiumBadgeVisible) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.onlineStatusVisible, onlineStatusVisible) ||
                other.onlineStatusVisible == onlineStatusVisible) &&
            (identical(other.lastSeenVisible, lastSeenVisible) ||
                other.lastSeenVisible == lastSeenVisible) &&
            (identical(other.notificationSettings, notificationSettings) ||
                other.notificationSettings == notificationSettings) &&
            (identical(
                  other.compatibilityPreferences,
                  compatibilityPreferences,
                ) ||
                other.compatibilityPreferences == compatibilityPreferences) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    email,
    nickname,
    birthDate,
    age,
    identity,
    relationshipGoal,
    bio,
    const DeepCollectionEquality().hash(_interests),
    occupation,
    education,
    height,
    socialLinks,
    city,
    geoHash,
    const DeepCollectionEquality().hash(_profileImages),
    profileVisibility,
    accountStatus,
    verificationLevel,
    premium,
    premiumBadgeVisible,
    fcmToken,
    isOnline,
    lastSeen,
    onlineStatusVisible,
    lastSeenVisible,
    notificationSettings,
    compatibilityPreferences,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final String id,
    required final String email,
    required final String nickname,
    @TimestampConverter() required final DateTime birthDate,
    required final int age,
    required final String identity,
    required final String relationshipGoal,
    required final String bio,
    final List<String> interests,
    final String? occupation,
    final String? education,
    final int? height,
    final UserSocialLinks? socialLinks,
    required final String city,
    required final String geoHash,
    final List<String> profileImages,
    final String profileVisibility,
    final String accountStatus,
    final String verificationLevel,
    final bool premium,
    final bool premiumBadgeVisible,
    final String fcmToken,
    final bool isOnline,
    @TimestampConverter() required final DateTime lastSeen,
    final bool onlineStatusVisible,
    final bool lastSeenVisible,
    required final UserNotificationSettings notificationSettings,
    required final UserCompatibilityPreferences compatibilityPreferences,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() required final DateTime updatedAt,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get nickname;
  @override
  @TimestampConverter()
  DateTime get birthDate;
  @override
  int get age;
  @override
  String get identity;
  @override
  String get relationshipGoal;
  @override
  String get bio;
  @override
  List<String> get interests;
  @override
  String? get occupation;
  @override
  String? get education;
  @override
  int? get height;
  @override
  UserSocialLinks? get socialLinks;
  @override
  String get city;
  @override
  String get geoHash;
  @override
  List<String> get profileImages;
  @override
  String get profileVisibility;
  @override
  String get accountStatus;
  @override
  String get verificationLevel;
  @override
  bool get premium;
  @override
  bool get premiumBadgeVisible;
  @override
  String get fcmToken;
  @override
  bool get isOnline;
  @override
  @TimestampConverter()
  DateTime get lastSeen;
  @override
  bool get onlineStatusVisible;
  @override
  bool get lastSeenVisible;
  @override
  UserNotificationSettings get notificationSettings;
  @override
  UserCompatibilityPreferences get compatibilityPreferences;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserNotificationSettings _$UserNotificationSettingsFromJson(
  Map<String, dynamic> json,
) {
  return _UserNotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$UserNotificationSettings {
  bool get match => throw _privateConstructorUsedError;
  bool get message => throw _privateConstructorUsedError;
  bool get like => throw _privateConstructorUsedError;
  bool get verification => throw _privateConstructorUsedError;

  /// Serializes this UserNotificationSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserNotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserNotificationSettingsCopyWith<UserNotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserNotificationSettingsCopyWith<$Res> {
  factory $UserNotificationSettingsCopyWith(
    UserNotificationSettings value,
    $Res Function(UserNotificationSettings) then,
  ) = _$UserNotificationSettingsCopyWithImpl<$Res, UserNotificationSettings>;
  @useResult
  $Res call({bool match, bool message, bool like, bool verification});
}

/// @nodoc
class _$UserNotificationSettingsCopyWithImpl<
  $Res,
  $Val extends UserNotificationSettings
>
    implements $UserNotificationSettingsCopyWith<$Res> {
  _$UserNotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserNotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? match = null,
    Object? message = null,
    Object? like = null,
    Object? verification = null,
  }) {
    return _then(
      _value.copyWith(
            match: null == match
                ? _value.match
                : match // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as bool,
            like: null == like
                ? _value.like
                : like // ignore: cast_nullable_to_non_nullable
                      as bool,
            verification: null == verification
                ? _value.verification
                : verification // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserNotificationSettingsImplCopyWith<$Res>
    implements $UserNotificationSettingsCopyWith<$Res> {
  factory _$$UserNotificationSettingsImplCopyWith(
    _$UserNotificationSettingsImpl value,
    $Res Function(_$UserNotificationSettingsImpl) then,
  ) = __$$UserNotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool match, bool message, bool like, bool verification});
}

/// @nodoc
class __$$UserNotificationSettingsImplCopyWithImpl<$Res>
    extends
        _$UserNotificationSettingsCopyWithImpl<
          $Res,
          _$UserNotificationSettingsImpl
        >
    implements _$$UserNotificationSettingsImplCopyWith<$Res> {
  __$$UserNotificationSettingsImplCopyWithImpl(
    _$UserNotificationSettingsImpl _value,
    $Res Function(_$UserNotificationSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserNotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? match = null,
    Object? message = null,
    Object? like = null,
    Object? verification = null,
  }) {
    return _then(
      _$UserNotificationSettingsImpl(
        match: null == match
            ? _value.match
            : match // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as bool,
        like: null == like
            ? _value.like
            : like // ignore: cast_nullable_to_non_nullable
                  as bool,
        verification: null == verification
            ? _value.verification
            : verification // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserNotificationSettingsImpl implements _UserNotificationSettings {
  const _$UserNotificationSettingsImpl({
    this.match = true,
    this.message = true,
    this.like = true,
    this.verification = true,
  });

  factory _$UserNotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserNotificationSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool match;
  @override
  @JsonKey()
  final bool message;
  @override
  @JsonKey()
  final bool like;
  @override
  @JsonKey()
  final bool verification;

  @override
  String toString() {
    return 'UserNotificationSettings(match: $match, message: $message, like: $like, verification: $verification)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserNotificationSettingsImpl &&
            (identical(other.match, match) || other.match == match) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.like, like) || other.like == like) &&
            (identical(other.verification, verification) ||
                other.verification == verification));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, match, message, like, verification);

  /// Create a copy of UserNotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserNotificationSettingsImplCopyWith<_$UserNotificationSettingsImpl>
  get copyWith =>
      __$$UserNotificationSettingsImplCopyWithImpl<
        _$UserNotificationSettingsImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserNotificationSettingsImplToJson(this);
  }
}

abstract class _UserNotificationSettings implements UserNotificationSettings {
  const factory _UserNotificationSettings({
    final bool match,
    final bool message,
    final bool like,
    final bool verification,
  }) = _$UserNotificationSettingsImpl;

  factory _UserNotificationSettings.fromJson(Map<String, dynamic> json) =
      _$UserNotificationSettingsImpl.fromJson;

  @override
  bool get match;
  @override
  bool get message;
  @override
  bool get like;
  @override
  bool get verification;

  /// Create a copy of UserNotificationSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserNotificationSettingsImplCopyWith<_$UserNotificationSettingsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

UserCompatibilityPreferences _$UserCompatibilityPreferencesFromJson(
  Map<String, dynamic> json,
) {
  return _UserCompatibilityPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserCompatibilityPreferences {
  int get minAge => throw _privateConstructorUsedError;
  int get maxAge => throw _privateConstructorUsedError;
  int get maxDistanceKm => throw _privateConstructorUsedError;
  List<String> get identities => throw _privateConstructorUsedError;
  List<String> get relationshipGoals => throw _privateConstructorUsedError;

  /// Serializes this UserCompatibilityPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserCompatibilityPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCompatibilityPreferencesCopyWith<UserCompatibilityPreferences>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCompatibilityPreferencesCopyWith<$Res> {
  factory $UserCompatibilityPreferencesCopyWith(
    UserCompatibilityPreferences value,
    $Res Function(UserCompatibilityPreferences) then,
  ) =
      _$UserCompatibilityPreferencesCopyWithImpl<
        $Res,
        UserCompatibilityPreferences
      >;
  @useResult
  $Res call({
    int minAge,
    int maxAge,
    int maxDistanceKm,
    List<String> identities,
    List<String> relationshipGoals,
  });
}

/// @nodoc
class _$UserCompatibilityPreferencesCopyWithImpl<
  $Res,
  $Val extends UserCompatibilityPreferences
>
    implements $UserCompatibilityPreferencesCopyWith<$Res> {
  _$UserCompatibilityPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserCompatibilityPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minAge = null,
    Object? maxAge = null,
    Object? maxDistanceKm = null,
    Object? identities = null,
    Object? relationshipGoals = null,
  }) {
    return _then(
      _value.copyWith(
            minAge: null == minAge
                ? _value.minAge
                : minAge // ignore: cast_nullable_to_non_nullable
                      as int,
            maxAge: null == maxAge
                ? _value.maxAge
                : maxAge // ignore: cast_nullable_to_non_nullable
                      as int,
            maxDistanceKm: null == maxDistanceKm
                ? _value.maxDistanceKm
                : maxDistanceKm // ignore: cast_nullable_to_non_nullable
                      as int,
            identities: null == identities
                ? _value.identities
                : identities // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            relationshipGoals: null == relationshipGoals
                ? _value.relationshipGoals
                : relationshipGoals // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserCompatibilityPreferencesImplCopyWith<$Res>
    implements $UserCompatibilityPreferencesCopyWith<$Res> {
  factory _$$UserCompatibilityPreferencesImplCopyWith(
    _$UserCompatibilityPreferencesImpl value,
    $Res Function(_$UserCompatibilityPreferencesImpl) then,
  ) = __$$UserCompatibilityPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int minAge,
    int maxAge,
    int maxDistanceKm,
    List<String> identities,
    List<String> relationshipGoals,
  });
}

/// @nodoc
class __$$UserCompatibilityPreferencesImplCopyWithImpl<$Res>
    extends
        _$UserCompatibilityPreferencesCopyWithImpl<
          $Res,
          _$UserCompatibilityPreferencesImpl
        >
    implements _$$UserCompatibilityPreferencesImplCopyWith<$Res> {
  __$$UserCompatibilityPreferencesImplCopyWithImpl(
    _$UserCompatibilityPreferencesImpl _value,
    $Res Function(_$UserCompatibilityPreferencesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserCompatibilityPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minAge = null,
    Object? maxAge = null,
    Object? maxDistanceKm = null,
    Object? identities = null,
    Object? relationshipGoals = null,
  }) {
    return _then(
      _$UserCompatibilityPreferencesImpl(
        minAge: null == minAge
            ? _value.minAge
            : minAge // ignore: cast_nullable_to_non_nullable
                  as int,
        maxAge: null == maxAge
            ? _value.maxAge
            : maxAge // ignore: cast_nullable_to_non_nullable
                  as int,
        maxDistanceKm: null == maxDistanceKm
            ? _value.maxDistanceKm
            : maxDistanceKm // ignore: cast_nullable_to_non_nullable
                  as int,
        identities: null == identities
            ? _value._identities
            : identities // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        relationshipGoals: null == relationshipGoals
            ? _value._relationshipGoals
            : relationshipGoals // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserCompatibilityPreferencesImpl
    implements _UserCompatibilityPreferences {
  const _$UserCompatibilityPreferencesImpl({
    this.minAge = 18,
    this.maxAge = 45,
    this.maxDistanceKm = 50,
    final List<String> identities = const <String>[],
    final List<String> relationshipGoals = const <String>[],
  }) : _identities = identities,
       _relationshipGoals = relationshipGoals;

  factory _$UserCompatibilityPreferencesImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$UserCompatibilityPreferencesImplFromJson(json);

  @override
  @JsonKey()
  final int minAge;
  @override
  @JsonKey()
  final int maxAge;
  @override
  @JsonKey()
  final int maxDistanceKm;
  final List<String> _identities;
  @override
  @JsonKey()
  List<String> get identities {
    if (_identities is EqualUnmodifiableListView) return _identities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_identities);
  }

  final List<String> _relationshipGoals;
  @override
  @JsonKey()
  List<String> get relationshipGoals {
    if (_relationshipGoals is EqualUnmodifiableListView)
      return _relationshipGoals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relationshipGoals);
  }

  @override
  String toString() {
    return 'UserCompatibilityPreferences(minAge: $minAge, maxAge: $maxAge, maxDistanceKm: $maxDistanceKm, identities: $identities, relationshipGoals: $relationshipGoals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserCompatibilityPreferencesImpl &&
            (identical(other.minAge, minAge) || other.minAge == minAge) &&
            (identical(other.maxAge, maxAge) || other.maxAge == maxAge) &&
            (identical(other.maxDistanceKm, maxDistanceKm) ||
                other.maxDistanceKm == maxDistanceKm) &&
            const DeepCollectionEquality().equals(
              other._identities,
              _identities,
            ) &&
            const DeepCollectionEquality().equals(
              other._relationshipGoals,
              _relationshipGoals,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    minAge,
    maxAge,
    maxDistanceKm,
    const DeepCollectionEquality().hash(_identities),
    const DeepCollectionEquality().hash(_relationshipGoals),
  );

  /// Create a copy of UserCompatibilityPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserCompatibilityPreferencesImplCopyWith<
    _$UserCompatibilityPreferencesImpl
  >
  get copyWith =>
      __$$UserCompatibilityPreferencesImplCopyWithImpl<
        _$UserCompatibilityPreferencesImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserCompatibilityPreferencesImplToJson(this);
  }
}

abstract class _UserCompatibilityPreferences
    implements UserCompatibilityPreferences {
  const factory _UserCompatibilityPreferences({
    final int minAge,
    final int maxAge,
    final int maxDistanceKm,
    final List<String> identities,
    final List<String> relationshipGoals,
  }) = _$UserCompatibilityPreferencesImpl;

  factory _UserCompatibilityPreferences.fromJson(Map<String, dynamic> json) =
      _$UserCompatibilityPreferencesImpl.fromJson;

  @override
  int get minAge;
  @override
  int get maxAge;
  @override
  int get maxDistanceKm;
  @override
  List<String> get identities;
  @override
  List<String> get relationshipGoals;

  /// Create a copy of UserCompatibilityPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserCompatibilityPreferencesImplCopyWith<
    _$UserCompatibilityPreferencesImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

UserSocialLinks _$UserSocialLinksFromJson(Map<String, dynamic> json) {
  return _UserSocialLinks.fromJson(json);
}

/// @nodoc
mixin _$UserSocialLinks {
  String? get instagram => throw _privateConstructorUsedError;
  String? get twitter => throw _privateConstructorUsedError;
  String? get tiktok => throw _privateConstructorUsedError;

  /// Serializes this UserSocialLinks to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSocialLinks
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSocialLinksCopyWith<UserSocialLinks> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSocialLinksCopyWith<$Res> {
  factory $UserSocialLinksCopyWith(
    UserSocialLinks value,
    $Res Function(UserSocialLinks) then,
  ) = _$UserSocialLinksCopyWithImpl<$Res, UserSocialLinks>;
  @useResult
  $Res call({String? instagram, String? twitter, String? tiktok});
}

/// @nodoc
class _$UserSocialLinksCopyWithImpl<$Res, $Val extends UserSocialLinks>
    implements $UserSocialLinksCopyWith<$Res> {
  _$UserSocialLinksCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSocialLinks
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instagram = freezed,
    Object? twitter = freezed,
    Object? tiktok = freezed,
  }) {
    return _then(
      _value.copyWith(
            instagram: freezed == instagram
                ? _value.instagram
                : instagram // ignore: cast_nullable_to_non_nullable
                      as String?,
            twitter: freezed == twitter
                ? _value.twitter
                : twitter // ignore: cast_nullable_to_non_nullable
                      as String?,
            tiktok: freezed == tiktok
                ? _value.tiktok
                : tiktok // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserSocialLinksImplCopyWith<$Res>
    implements $UserSocialLinksCopyWith<$Res> {
  factory _$$UserSocialLinksImplCopyWith(
    _$UserSocialLinksImpl value,
    $Res Function(_$UserSocialLinksImpl) then,
  ) = __$$UserSocialLinksImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? instagram, String? twitter, String? tiktok});
}

/// @nodoc
class __$$UserSocialLinksImplCopyWithImpl<$Res>
    extends _$UserSocialLinksCopyWithImpl<$Res, _$UserSocialLinksImpl>
    implements _$$UserSocialLinksImplCopyWith<$Res> {
  __$$UserSocialLinksImplCopyWithImpl(
    _$UserSocialLinksImpl _value,
    $Res Function(_$UserSocialLinksImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSocialLinks
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? instagram = freezed,
    Object? twitter = freezed,
    Object? tiktok = freezed,
  }) {
    return _then(
      _$UserSocialLinksImpl(
        instagram: freezed == instagram
            ? _value.instagram
            : instagram // ignore: cast_nullable_to_non_nullable
                  as String?,
        twitter: freezed == twitter
            ? _value.twitter
            : twitter // ignore: cast_nullable_to_non_nullable
                  as String?,
        tiktok: freezed == tiktok
            ? _value.tiktok
            : tiktok // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSocialLinksImpl implements _UserSocialLinks {
  const _$UserSocialLinksImpl({this.instagram, this.twitter, this.tiktok});

  factory _$UserSocialLinksImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSocialLinksImplFromJson(json);

  @override
  final String? instagram;
  @override
  final String? twitter;
  @override
  final String? tiktok;

  @override
  String toString() {
    return 'UserSocialLinks(instagram: $instagram, twitter: $twitter, tiktok: $tiktok)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSocialLinksImpl &&
            (identical(other.instagram, instagram) ||
                other.instagram == instagram) &&
            (identical(other.twitter, twitter) || other.twitter == twitter) &&
            (identical(other.tiktok, tiktok) || other.tiktok == tiktok));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, instagram, twitter, tiktok);

  /// Create a copy of UserSocialLinks
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSocialLinksImplCopyWith<_$UserSocialLinksImpl> get copyWith =>
      __$$UserSocialLinksImplCopyWithImpl<_$UserSocialLinksImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSocialLinksImplToJson(this);
  }
}

abstract class _UserSocialLinks implements UserSocialLinks {
  const factory _UserSocialLinks({
    final String? instagram,
    final String? twitter,
    final String? tiktok,
  }) = _$UserSocialLinksImpl;

  factory _UserSocialLinks.fromJson(Map<String, dynamic> json) =
      _$UserSocialLinksImpl.fromJson;

  @override
  String? get instagram;
  @override
  String? get twitter;
  @override
  String? get tiktok;

  /// Create a copy of UserSocialLinks
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSocialLinksImplCopyWith<_$UserSocialLinksImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
