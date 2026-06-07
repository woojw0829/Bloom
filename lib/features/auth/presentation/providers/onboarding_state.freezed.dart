// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OnboardingState {
  int get currentStep =>
      throw _privateConstructorUsedError; // Step 1 — Identity
  String? get identity =>
      throw _privateConstructorUsedError; // Step 2 — Age verification
  DateTime? get birthDate =>
      throw _privateConstructorUsedError; // Step 3 — Profile creation
  String get nickname => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  String get relationshipGoal => throw _privateConstructorUsedError;
  List<String> get interests =>
      throw _privateConstructorUsedError; // Step 4 — Photo upload (local file paths)
  List<String> get photoPaths =>
      throw _privateConstructorUsedError; // Step 5 — Discovery preferences
  int get minAge => throw _privateConstructorUsedError;
  int get maxAge => throw _privateConstructorUsedError;
  int get maxDistanceKm => throw _privateConstructorUsedError;
  List<String> get preferredIdentities => throw _privateConstructorUsedError;
  List<String> get preferredGoals => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingStateCopyWith<OnboardingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
    OnboardingState value,
    $Res Function(OnboardingState) then,
  ) = _$OnboardingStateCopyWithImpl<$Res, OnboardingState>;
  @useResult
  $Res call({
    int currentStep,
    String? identity,
    DateTime? birthDate,
    String nickname,
    String bio,
    String relationshipGoal,
    List<String> interests,
    List<String> photoPaths,
    int minAge,
    int maxAge,
    int maxDistanceKm,
    List<String> preferredIdentities,
    List<String> preferredGoals,
  });
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res, $Val extends OnboardingState>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? identity = freezed,
    Object? birthDate = freezed,
    Object? nickname = null,
    Object? bio = null,
    Object? relationshipGoal = null,
    Object? interests = null,
    Object? photoPaths = null,
    Object? minAge = null,
    Object? maxAge = null,
    Object? maxDistanceKm = null,
    Object? preferredIdentities = null,
    Object? preferredGoals = null,
  }) {
    return _then(
      _value.copyWith(
            currentStep: null == currentStep
                ? _value.currentStep
                : currentStep // ignore: cast_nullable_to_non_nullable
                      as int,
            identity: freezed == identity
                ? _value.identity
                : identity // ignore: cast_nullable_to_non_nullable
                      as String?,
            birthDate: freezed == birthDate
                ? _value.birthDate
                : birthDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            bio: null == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String,
            relationshipGoal: null == relationshipGoal
                ? _value.relationshipGoal
                : relationshipGoal // ignore: cast_nullable_to_non_nullable
                      as String,
            interests: null == interests
                ? _value.interests
                : interests // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            photoPaths: null == photoPaths
                ? _value.photoPaths
                : photoPaths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
            preferredIdentities: null == preferredIdentities
                ? _value.preferredIdentities
                : preferredIdentities // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            preferredGoals: null == preferredGoals
                ? _value.preferredGoals
                : preferredGoals // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnboardingStateImplCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory _$$OnboardingStateImplCopyWith(
    _$OnboardingStateImpl value,
    $Res Function(_$OnboardingStateImpl) then,
  ) = __$$OnboardingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int currentStep,
    String? identity,
    DateTime? birthDate,
    String nickname,
    String bio,
    String relationshipGoal,
    List<String> interests,
    List<String> photoPaths,
    int minAge,
    int maxAge,
    int maxDistanceKm,
    List<String> preferredIdentities,
    List<String> preferredGoals,
  });
}

/// @nodoc
class __$$OnboardingStateImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$OnboardingStateImpl>
    implements _$$OnboardingStateImplCopyWith<$Res> {
  __$$OnboardingStateImplCopyWithImpl(
    _$OnboardingStateImpl _value,
    $Res Function(_$OnboardingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? identity = freezed,
    Object? birthDate = freezed,
    Object? nickname = null,
    Object? bio = null,
    Object? relationshipGoal = null,
    Object? interests = null,
    Object? photoPaths = null,
    Object? minAge = null,
    Object? maxAge = null,
    Object? maxDistanceKm = null,
    Object? preferredIdentities = null,
    Object? preferredGoals = null,
  }) {
    return _then(
      _$OnboardingStateImpl(
        currentStep: null == currentStep
            ? _value.currentStep
            : currentStep // ignore: cast_nullable_to_non_nullable
                  as int,
        identity: freezed == identity
            ? _value.identity
            : identity // ignore: cast_nullable_to_non_nullable
                  as String?,
        birthDate: freezed == birthDate
            ? _value.birthDate
            : birthDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        bio: null == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String,
        relationshipGoal: null == relationshipGoal
            ? _value.relationshipGoal
            : relationshipGoal // ignore: cast_nullable_to_non_nullable
                  as String,
        interests: null == interests
            ? _value._interests
            : interests // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        photoPaths: null == photoPaths
            ? _value._photoPaths
            : photoPaths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
        preferredIdentities: null == preferredIdentities
            ? _value._preferredIdentities
            : preferredIdentities // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        preferredGoals: null == preferredGoals
            ? _value._preferredGoals
            : preferredGoals // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$OnboardingStateImpl implements _OnboardingState {
  const _$OnboardingStateImpl({
    this.currentStep = 0,
    this.identity,
    this.birthDate,
    this.nickname = '',
    this.bio = '',
    this.relationshipGoal = '',
    final List<String> interests = const <String>[],
    final List<String> photoPaths = const <String>[],
    this.minAge = 18,
    this.maxAge = 45,
    this.maxDistanceKm = 50,
    final List<String> preferredIdentities = const <String>[],
    final List<String> preferredGoals = const <String>[],
  }) : _interests = interests,
       _photoPaths = photoPaths,
       _preferredIdentities = preferredIdentities,
       _preferredGoals = preferredGoals;

  @override
  @JsonKey()
  final int currentStep;
  // Step 1 — Identity
  @override
  final String? identity;
  // Step 2 — Age verification
  @override
  final DateTime? birthDate;
  // Step 3 — Profile creation
  @override
  @JsonKey()
  final String nickname;
  @override
  @JsonKey()
  final String bio;
  @override
  @JsonKey()
  final String relationshipGoal;
  final List<String> _interests;
  @override
  @JsonKey()
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  // Step 4 — Photo upload (local file paths)
  final List<String> _photoPaths;
  // Step 4 — Photo upload (local file paths)
  @override
  @JsonKey()
  List<String> get photoPaths {
    if (_photoPaths is EqualUnmodifiableListView) return _photoPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoPaths);
  }

  // Step 5 — Discovery preferences
  @override
  @JsonKey()
  final int minAge;
  @override
  @JsonKey()
  final int maxAge;
  @override
  @JsonKey()
  final int maxDistanceKm;
  final List<String> _preferredIdentities;
  @override
  @JsonKey()
  List<String> get preferredIdentities {
    if (_preferredIdentities is EqualUnmodifiableListView)
      return _preferredIdentities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredIdentities);
  }

  final List<String> _preferredGoals;
  @override
  @JsonKey()
  List<String> get preferredGoals {
    if (_preferredGoals is EqualUnmodifiableListView) return _preferredGoals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredGoals);
  }

  @override
  String toString() {
    return 'OnboardingState(currentStep: $currentStep, identity: $identity, birthDate: $birthDate, nickname: $nickname, bio: $bio, relationshipGoal: $relationshipGoal, interests: $interests, photoPaths: $photoPaths, minAge: $minAge, maxAge: $maxAge, maxDistanceKm: $maxDistanceKm, preferredIdentities: $preferredIdentities, preferredGoals: $preferredGoals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.identity, identity) ||
                other.identity == identity) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.relationshipGoal, relationshipGoal) ||
                other.relationshipGoal == relationshipGoal) &&
            const DeepCollectionEquality().equals(
              other._interests,
              _interests,
            ) &&
            const DeepCollectionEquality().equals(
              other._photoPaths,
              _photoPaths,
            ) &&
            (identical(other.minAge, minAge) || other.minAge == minAge) &&
            (identical(other.maxAge, maxAge) || other.maxAge == maxAge) &&
            (identical(other.maxDistanceKm, maxDistanceKm) ||
                other.maxDistanceKm == maxDistanceKm) &&
            const DeepCollectionEquality().equals(
              other._preferredIdentities,
              _preferredIdentities,
            ) &&
            const DeepCollectionEquality().equals(
              other._preferredGoals,
              _preferredGoals,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentStep,
    identity,
    birthDate,
    nickname,
    bio,
    relationshipGoal,
    const DeepCollectionEquality().hash(_interests),
    const DeepCollectionEquality().hash(_photoPaths),
    minAge,
    maxAge,
    maxDistanceKm,
    const DeepCollectionEquality().hash(_preferredIdentities),
    const DeepCollectionEquality().hash(_preferredGoals),
  );

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      __$$OnboardingStateImplCopyWithImpl<_$OnboardingStateImpl>(
        this,
        _$identity,
      );
}

abstract class _OnboardingState implements OnboardingState {
  const factory _OnboardingState({
    final int currentStep,
    final String? identity,
    final DateTime? birthDate,
    final String nickname,
    final String bio,
    final String relationshipGoal,
    final List<String> interests,
    final List<String> photoPaths,
    final int minAge,
    final int maxAge,
    final int maxDistanceKm,
    final List<String> preferredIdentities,
    final List<String> preferredGoals,
  }) = _$OnboardingStateImpl;

  @override
  int get currentStep; // Step 1 — Identity
  @override
  String? get identity; // Step 2 — Age verification
  @override
  DateTime? get birthDate; // Step 3 — Profile creation
  @override
  String get nickname;
  @override
  String get bio;
  @override
  String get relationshipGoal;
  @override
  List<String> get interests; // Step 4 — Photo upload (local file paths)
  @override
  List<String> get photoPaths; // Step 5 — Discovery preferences
  @override
  int get minAge;
  @override
  int get maxAge;
  @override
  int get maxDistanceKm;
  @override
  List<String> get preferredIdentities;
  @override
  List<String> get preferredGoals;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
