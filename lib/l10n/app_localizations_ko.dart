// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get saveChanges => '변경사항 저장';

  @override
  String get continueAction => '계속하기';

  @override
  String get addPhoto => '사진 추가';

  @override
  String get openAppSettings => '앱 설정 열기';

  @override
  String get openLocationSettings => '위치 설정 열기';

  @override
  String get loginTagline => '있는 그대로의 나로, 진짜 인연을 찾아요.';

  @override
  String get loginEmail => '이메일';

  @override
  String get loginEmailHint => 'you@example.com';

  @override
  String get loginPassword => '비밀번호';

  @override
  String get loginForgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get loginSignIn => '로그인';

  @override
  String get loginOr => '또는';

  @override
  String get loginContinueWithGoogle => 'Google로 계속하기';

  @override
  String get loginContinueWithApple => 'Apple로 계속하기';

  @override
  String get loginNoAccount => '계정이 없으신가요?';

  @override
  String get loginSignUp => '회원가입';

  @override
  String get loginEmailRequired => '이메일을 입력해 주세요.';

  @override
  String get loginEmailInvalid => '올바른 이메일 주소를 입력해 주세요.';

  @override
  String get loginPasswordRequired => '비밀번호를 입력해 주세요.';

  @override
  String get registerTitle => '계정 만들기';

  @override
  String get registerSubtitle => 'Bloom에 오신 것을 환영해요.';

  @override
  String get registerPassword => '비밀번호';

  @override
  String get registerConfirmPassword => '비밀번호 확인';

  @override
  String get registerCreateAccount => '계정 만들기';

  @override
  String get registerHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get registerSignIn => '로그인';

  @override
  String get registerPasswordRequired => '비밀번호를 입력해 주세요.';

  @override
  String get registerPasswordTooShort => '비밀번호는 6자 이상이어야 해요.';

  @override
  String get registerPasswordMismatch => '비밀번호가 일치하지 않아요.';

  @override
  String get forgotPasswordTitle => '비밀번호 재설정';

  @override
  String get forgotPasswordSubtitle => '이메일을 입력하시면 비밀번호 재설정 링크를 보내드려요.';

  @override
  String get forgotPasswordSendEmail => '재설정 이메일 보내기';

  @override
  String get forgotPasswordCheckInbox => '이메일을 확인해 주세요';

  @override
  String get forgotPasswordEmailSent => '비밀번호 재설정 링크를 입력하신 이메일로 보냈어요.';

  @override
  String get forgotPasswordBackToSignIn => '로그인으로 돌아가기';

  @override
  String get onboardingWelcomeTitle => 'Bloom에 오신 것을 환영해요';

  @override
  String get onboardingWelcomeBody =>
      'LGBTQ+ 커뮤니티를 위한 안전하고 포용적인 공간에서 진정한 인연을 만나 보세요.';

  @override
  String get onboardingGetStarted => '시작하기';

  @override
  String get onboardingVerifiedProfiles => '믿을 수 있는 인증된 프로필';

  @override
  String get onboardingPrivacyProtected => '당신의 프라이버시, 안전하게 보호돼요';

  @override
  String get onboardingRealConnections => '진정으로 의미 있는 만남';

  @override
  String get onboardingIdentityTitle => '어떻게 소개하시겠어요?';

  @override
  String get onboardingIdentityBody => '더 맞춤화된 경험을 위해 필요해요. 언제든지 변경할 수 있어요.';

  @override
  String get onboardingAgeTitle => '생년월일';

  @override
  String get onboardingAgeBody =>
      '만 18세 이상이어야 해요. 프로필에는 나이만 표시되며, 생년월일은 공개되지 않아요.';

  @override
  String get onboardingSelectBirthdate => '생년월일을 선택해 주세요';

  @override
  String get onboardingSelectBirthdateHelp => '생년월일 선택';

  @override
  String get onboardingAgeTooYoung => 'Bloom은 만 18세 이상만 가입할 수 있어요.';

  @override
  String get onboardingProfileTitle => '프로필을 만들어 보세요';

  @override
  String get onboardingProfileBody => '나에 대해 간단히 소개해 주세요.';

  @override
  String get onboardingNickname => '닉네임';

  @override
  String get onboardingNicknameHint => '어떻게 불리고 싶으신가요?';

  @override
  String get onboardingNicknameRequired => '닉네임을 입력해 주세요.';

  @override
  String get onboardingNicknameTooLong => '최대 30자까지 입력할 수 있어요.';

  @override
  String get onboardingBio => '자기소개';

  @override
  String get onboardingBioHint => '짧은 자기소개를 남겨 보세요 (선택사항)…';

  @override
  String get onboardingBioTooLong => '최대 500자까지 입력할 수 있어요.';

  @override
  String get onboardingRelationshipGoal => '원하는 관계';

  @override
  String get onboardingInterests => '관심사';

  @override
  String get onboardingInterestsHint => '최대 10개까지 선택할 수 있어요.';

  @override
  String get onboardingPhotosTitle => '사진을 추가해 주세요';

  @override
  String onboardingPhotosBody(int maxPhotos) {
    return '최대 $maxPhotos장의 사진을 추가할 수 있어요. 첫 번째 사진이 대표 사진이에요. 길게 눌러서 순서를 바꿀 수 있어요.';
  }

  @override
  String get onboardingTapToAddPhoto => '탭해서 사진 추가하기';

  @override
  String get onboardingPhotoPrimary => '대표';

  @override
  String get onboardingDiscoveryTitle => '어떤 분을 만나고 싶으신가요?';

  @override
  String get onboardingDiscoveryBody => '탐색 설정을 해보세요. 언제든지 변경할 수 있어요.';

  @override
  String get onboardingAgeRange => '나이 범위';

  @override
  String onboardingAgeRangeValue(int minAge, int maxAge) {
    return '$minAge – $maxAge';
  }

  @override
  String get onboardingMaxDistance => '최대 거리';

  @override
  String onboardingMaxDistanceValue(int distance) {
    return '$distance km';
  }

  @override
  String get onboardingShowMe => '보고 싶은 상대';

  @override
  String get onboardingShowMeHint => '비워두면 모든 사람이 보여요.';

  @override
  String get onboardingLookingFor => '원하는 관계';

  @override
  String get onboardingLookingForHint => '비워두면 모든 목표가 표시돼요.';

  @override
  String get onboardingLetsBloom => 'Bloom 시작하기 🌸';

  @override
  String get onboardingCreatingProfile => '프로필을 만들고 있어요…';

  @override
  String get onboardingError => '오류가 발생했어요. 다시 시도해 주세요.';

  @override
  String get editProfileTitle => '프로필 수정';

  @override
  String get editProfileNickname => '닉네임';

  @override
  String get editProfileNicknameHint => '어떻게 불리고 싶으신가요?';

  @override
  String get editProfileNicknameRequired => '닉네임을 입력해 주세요.';

  @override
  String get editProfileNicknameTooLong => '30자 이하로 입력해 주세요.';

  @override
  String get editProfileBio => '자기소개';

  @override
  String get editProfileBioHint => '짧은 자기소개를 남겨 보세요 (선택사항)…';

  @override
  String get editProfileBioTooLong => '자기소개는 500자 이하로 입력해 주세요.';

  @override
  String get editProfileRelationshipGoal => '원하는 관계';

  @override
  String get editProfileInterests => '관심사';

  @override
  String get editProfileInterestsHint => '최대 10개까지 선택할 수 있어요.';

  @override
  String get editProfileSelectGoal => '원하는 관계를 선택해 주세요.';

  @override
  String get managePhotosTitle => '사진 관리';

  @override
  String get managePhotosHint => '≡을 드래그해서 순서를 바꾸세요. 첫 번째 사진이 대표 사진이에요.';

  @override
  String managePhotosAddButton(int count, int max) {
    return '사진 추가 ($count/$max)';
  }

  @override
  String get managePhotosEmpty => '사진이 없어요';

  @override
  String get managePhotosSetAsPrimary => '대표 사진으로 설정';

  @override
  String get managePhotosDelete => '삭제';

  @override
  String get managePhotosPrimary => '대표';

  @override
  String get privacyTitle => '개인정보 설정';

  @override
  String get privacyProfileVisibility => '프로필 공개 범위';

  @override
  String get privacyPublic => '공개';

  @override
  String get privacyHidden => '숨김';

  @override
  String get privacySelective => '선택 공개';

  @override
  String get privacyPublicDesc => '조건에 맞는 사용자에게 프로필이 표시돼요.';

  @override
  String get privacyHiddenDesc => '탐색 화면에 프로필이 표시되지 않아요.';

  @override
  String get privacySelectiveDesc => '설정한 조건에 따라 프로필 공개 여부가 결정돼요.';

  @override
  String get privacyWhoCanSeeYou => '나를 볼 수 있는 사람';

  @override
  String get privacyOnlineStatus => '온라인 상태';

  @override
  String get privacyOnlineStatusDesc => '온라인 상태를 표시해요.';

  @override
  String get privacyLastSeen => '마지막 접속';

  @override
  String get privacyLastSeenDesc => '마지막 접속 시간을 표시해요.';

  @override
  String get notificationsTitle => '알림 설정';

  @override
  String get notificationsKeepUpdated => '알림 받기';

  @override
  String get notificationsMatch => '매치 알림';

  @override
  String get notificationsMatchDesc => '새로운 연결이 생기면 알림을 받아요.';

  @override
  String get notificationsMessage => '메시지 알림';

  @override
  String get notificationsMessageDesc => '메시지를 받으면 알림을 받아요.';

  @override
  String get notificationsLike => '좋아요 알림';

  @override
  String get notificationsLikeDesc => '누군가 내 프로필을 좋아하면 알림을 받아요.';

  @override
  String get notificationsVerification => '인증 알림';

  @override
  String get notificationsVerificationDesc => '인증 관련 업데이트 알림을 받아요.';

  @override
  String get locationPermissionTitle => '위치 권한';

  @override
  String get locationPermissionMainTitle => '가까운 인연을 찾기 위해 위치 권한이 필요해요';

  @override
  String get locationPermissionBody =>
      'Bloom은 근처의 인연을 찾기 위해 위치를 사용해요. 정확한 위치는 다른 사용자에게 절대 공개되지 않아요.';

  @override
  String get locationPermissionGrantedStatus => '위치 권한이 허용됐어요.';

  @override
  String get locationPermissionServiceDisabled => '기기의 위치 서비스가 꺼져 있어요.';

  @override
  String get locationPermissionDenied => '가까운 탐색 기능을 사용하려면 위치 권한이 필요해요.';

  @override
  String get locationPermissionDeniedForever =>
      '위치 권한이 차단됐어요. 앱 설정에서 허용할 수 있어요.';

  @override
  String get locationPermissionGrantedLabel => '위치 권한 허용됨';

  @override
  String get locationPermissionAllow => '위치 허용하기';

  @override
  String get locationPermissionCheckFailed => '위치 권한 확인에 실패했어요. 다시 시도해 주세요.';

  @override
  String get locationPermissionRequestFailed => '위치 권한 요청에 실패했어요. 다시 시도해 주세요.';

  @override
  String get locationUpdateButton => '위치 업데이트';

  @override
  String get locationUpdateSuccess => '위치 정보가 업데이트되었어요.';

  @override
  String get locationUpdateFailed => '위치 업데이트에 실패했어요. 다시 시도해 주세요.';

  @override
  String get locationPermissionRequiredForUpdate => '위치 업데이트를 위해 위치 권한이 필요해요.';

  @override
  String get locationServiceDisabledForUpdate => '위치 업데이트를 위해 위치 서비스를 켜주세요.';

  @override
  String get locationNotUpdatedYet => '아직 위치가 업데이트되지 않았어요';

  @override
  String locationLastUpdated(String timeAgo) {
    return '마지막 업데이트 $timeAgo';
  }

  @override
  String get profileAbout => '소개';

  @override
  String get profileLookingFor => '원하는 관계';

  @override
  String get profileInterests => '관심사';

  @override
  String get profileErrorLoad => '프로필을 불러올 수 없어요. 다시 시도해 주세요.';

  @override
  String get profilePrivacyTile => '개인정보 설정';

  @override
  String get profileNotificationsTile => '알림 설정';

  @override
  String get profileNotificationsSubtitle => '매치, 메시지, 좋아요, 인증 알림을 관리해요';

  @override
  String get profileLocationTile => '위치';

  @override
  String get profileLocationSubtitle => '가까운 탐색을 위한 위치 권한을 관리해요';

  @override
  String get profileLanguageTile => '언어 설정';

  @override
  String get profileLanguageSubtitle => '앱 언어를 선택해요';

  @override
  String get languageTitle => '언어 설정';

  @override
  String get languageSystemDefault => '기기 언어 설정';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageErrorSave => '언어 설정 저장에 실패했어요. 다시 시도해 주세요.';

  @override
  String get navExplore => '탐색';

  @override
  String get navBrowse => '둘러보기';

  @override
  String get navChat => '채팅';

  @override
  String get navAlerts => '알림';

  @override
  String get navProfile => '프로필';

  @override
  String get filtersTitle => '필터';

  @override
  String get filtersApply => '적용하기';

  @override
  String get filtersReset => '초기화';

  @override
  String get filtersAge => '나이';

  @override
  String get filtersIdentity => '정체성';

  @override
  String get filtersRelationshipGoal => '원하는 관계';

  @override
  String get filtersVerifiedOnly => '인증된 프로필만';

  @override
  String get filtersDistance => '거리';

  @override
  String get filtersAnyDistance => '제한 없음';

  @override
  String filtersWithinKm(int km) {
    return '${km}km 이내';
  }

  @override
  String filtersActiveCount(int count) {
    return '필터 $count개 적용 중';
  }

  @override
  String get browseTitle => '둘러보기';

  @override
  String get browseEmptyTitle => '아직 보여드릴 프로필이 없어요';

  @override
  String get browseEmptyBody => '나중에 다시 확인해 주세요.';

  @override
  String get browseErrorTitle => '오류가 발생했어요';

  @override
  String get browseErrorBody => '프로필을 불러오지 못했어요. 다시 시도해 주세요.';

  @override
  String get browseRetry => '다시 시도';

  @override
  String get browseNeedsLocationTitle => '위치를 업데이트해 주세요';

  @override
  String get browseNeedsLocationBody => '가까운 인연을 찾으려면 위치 업데이트가 필요해요.';

  @override
  String get browseUpdateLocation => '위치 업데이트하기';

  @override
  String get browseRefresh => '새로 고침';

  @override
  String get browseVerified => '인증됨';

  @override
  String get browsePremium => '프리미엄';

  @override
  String get exploreTitle => '탐색';

  @override
  String get exploreEmptyTitle => '아직 프로필이 없어요';

  @override
  String get exploreEmptyBody => '새로운 인연이 나타나면 알려드릴게요.';

  @override
  String get exploreErrorTitle => '오류가 발생했어요';

  @override
  String get exploreErrorBody => '프로필을 불러오지 못했어요. 다시 시도해 주세요.';

  @override
  String get exploreRetry => '다시 시도';

  @override
  String get exploreNeedsLocationTitle => '위치를 업데이트해 주세요';

  @override
  String get exploreNeedsLocationBody => '가까운 인연을 찾으려면 위치 업데이트가 필요해요.';

  @override
  String get exploreUpdateLocation => '위치 업데이트하기';

  @override
  String get exploreRefresh => '새로 고침';

  @override
  String get exploreVerified => '인증됨';

  @override
  String get explorePremium => '프리미엄';

  @override
  String get mapDiscoveryTitle => '지도';

  @override
  String get mapDiscoveryEmptyTitle => '지도에 표시할 프로필이 없어요';

  @override
  String get mapDiscoveryEmptyBody => '나중에 다시 확인해 주세요.';

  @override
  String get mapDiscoveryErrorTitle => '오류가 발생했어요';

  @override
  String get mapDiscoveryErrorBody => '프로필을 불러오지 못했어요. 다시 시도해 주세요.';

  @override
  String get mapDiscoveryRetry => '다시 시도';

  @override
  String get mapDiscoveryNeedsLocationTitle => '위치를 업데이트해 주세요';

  @override
  String get mapDiscoveryNeedsLocationBody => '지도에서 가까운 인연을 보려면 위치 업데이트가 필요해요.';

  @override
  String get mapDiscoveryUpdateLocation => '위치 업데이트하기';

  @override
  String get mapDiscoveryApproximateArea => '근사 위치';

  @override
  String get mapDiscoveryOpenMap => '지도 보기';

  @override
  String get swipePass => '패스';

  @override
  String get swipeLike => '좋아요';

  @override
  String get swipeSuperLike => '슈퍼 좋아요';

  @override
  String get swipePassedFeedback => '패스했어요';

  @override
  String get swipeLikedFeedback => '좋아요를 보냈어요';

  @override
  String get swipeSuperLikedFeedback => '슈퍼 좋아요를 보냈어요';

  @override
  String compatibilityMatchPercent(int percentage) {
    return '$percentage% 잘 맞아요';
  }

  @override
  String get compatibilityNewProfile => '새로운 프로필';

  @override
  String get compatibilityAboutTitle => '호환도';

  @override
  String get compatibilityApproxNote => '근사 위치 기준이에요';

  @override
  String get compatibilityReasonSharedInterests => '관심사가 비슷해요';

  @override
  String get compatibilityReasonRelationshipGoal => '원하는 관계가 비슷해요';

  @override
  String get compatibilityReasonIdentityFit => '정체성 조건이 잘 맞아요';

  @override
  String get compatibilityReasonAgeRange => '나이 조건이 잘 맞아요';

  @override
  String get compatibilityReasonNearbyArea => '가까운 지역일 수 있어요';

  @override
  String get compatibilityReasonVerified => '인증된 프로필이에요';

  @override
  String get matchCelebrationTitle => '매치됐어요!';

  @override
  String matchCelebrationSubtitle(String name) {
    return '$name님과 서로 좋아요를 보냈어요.';
  }

  @override
  String get matchCelebrationKeepExploring => '계속 둘러보기';

  @override
  String get matchCelebrationFallbackName => '상대방';

  @override
  String get mapNearbyTitle => '주변 사용자';

  @override
  String mapNearbyRadiusLabel(int radiusKm) {
    return '내 주변 ${radiusKm}km';
  }

  @override
  String get mapNearbyNoUsers => '아직 주변 사용자가 없어요.';

  @override
  String get mapNearbyFewerThanFive => '주변에 5명 미만의 사용자가 있어요.';

  @override
  String mapNearbyCountPlus(int count) {
    return '주변에 $count명 이상의 사용자가 있어요.';
  }

  @override
  String get mapNearbyPrivacyNotice => '안전을 위해 개별 사용자의 위치는 표시하지 않아요.';

  @override
  String get mapNearbyLoadFailed => '주변 사용자 수를 불러오지 못했어요. 다시 시도해 주세요.';

  @override
  String get mapMyLocation => '내 위치';

  @override
  String get mapApproximatePrivacyNote => '프로필 위치는 근사 위치로 표시돼요.';

  @override
  String get mapMyLocationPermissionTitle => '위치 권한이 필요해요';

  @override
  String get mapMyLocationPermissionBody => '지도에서 내 위치를 보려면 위치 권한을 허용해 주세요.';

  @override
  String get mapMyLocationPermissionAction => '위치 권한 허용하기';

  @override
  String get mapMyLocationUnavailable => '현재 위치를 확인할 수 없어요.';

  @override
  String get messagesTitle => '메시지';

  @override
  String get conversationListEmptyTitle => '아직 대화가 없어요';

  @override
  String get conversationListEmptyBody => '매치가 생기면 이곳에서 대화를 확인할 수 있어요.';

  @override
  String get conversationListErrorTitle => '대화를 불러오지 못했어요';

  @override
  String get conversationListErrorBody => '잠시 후 다시 시도해 주세요.';

  @override
  String get conversationListRetry => '다시 시도';

  @override
  String get conversationNoMessagesYet => '매치됐어요. 곧 인사를 나눠보세요.';

  @override
  String get conversationChatComingSoon => '채팅 기능은 곧 추가될 예정이에요.';

  @override
  String get conversationUnknownUser => '상대방';

  @override
  String get chatStartConversation => '대화를 시작해 보세요.';

  @override
  String get chatMessageHint => '메시지를 입력하세요';

  @override
  String get chatSend => '보내기';

  @override
  String get chatSending => '보내는 중';

  @override
  String get chatLoadErrorTitle => '메시지를 불러오지 못했어요';

  @override
  String get chatLoadErrorBody => '잠시 후 다시 시도해 주세요.';

  @override
  String get chatRetry => '다시 시도';

  @override
  String get chatSendFailed => '메시지를 보내지 못했어요. 다시 시도해 주세요.';

  @override
  String get chatUnknownUser => '상대방';

  @override
  String get chatAttachImage => '이미지 첨부';

  @override
  String get chatImageSendFailed => '이미지를 보내지 못했어요. 다시 시도해 주세요.';

  @override
  String get chatImageMessageFallback => '이미지를 불러올 수 없어요.';

  @override
  String get conversationPhotoMessage => '사진';

  @override
  String chatTypingIndicator(String name) {
    return '$name님이 입력 중이에요...';
  }

  @override
  String get chatTypingFallbackName => '상대방';

  @override
  String get chatMessageSent => '전송됨';

  @override
  String get chatMessageRead => '읽음';

  @override
  String get chatUnmatch => '매치 해제';

  @override
  String get chatUnmatchTitle => '매치를 해제할까요?';

  @override
  String chatUnmatchBody(String name) {
    return '$name님과 더 이상 메시지를 주고받을 수 없어요.';
  }

  @override
  String get chatUnmatchConfirm => '매치 해제';

  @override
  String get chatUnmatchCancel => '취소';

  @override
  String get chatUnmatchSuccess => '매치가 해제됐어요.';

  @override
  String get chatUnmatchFailed => '매치를 해제하지 못했어요. 다시 시도해 주세요.';

  @override
  String get notificationCenterTitle => '알림';

  @override
  String get notificationCenterEmpty => '아직 알림이 없어요.';

  @override
  String get notificationCenterLoadError => '알림을 불러오지 못했어요.';

  @override
  String get notificationCenterMarkAllRead => '모두 읽음';

  @override
  String get notificationCenterMarkedAllRead => '모든 알림을 읽음 처리했어요.';

  @override
  String get safetyBlockUser => '사용자 차단';

  @override
  String get safetyBlockTitle => '이 사용자를 차단할까요?';

  @override
  String get safetyBlockBody => '서로를 발견하거나 매치하고 메시지를 보낼 수 없어요.';

  @override
  String get safetyBlockConfirm => '차단';

  @override
  String get safetyBlockCancel => '취소';

  @override
  String get safetyBlockSuccess => '사용자를 차단했어요.';

  @override
  String get safetyBlockFailed => '사용자를 차단하지 못했어요. 다시 시도해 주세요.';

  @override
  String get safetyCannotBlockSelf => '자기 자신은 차단할 수 없어요.';

  @override
  String get safetyReportUser => '사용자 신고';

  @override
  String get safetyReportTitle => '이 사용자를 신고할까요?';

  @override
  String get safetyReportReasonSpam => '스팸';

  @override
  String get safetyReportReasonFakeProfile => '가짜 프로필';

  @override
  String get safetyReportReasonHarassment => '괴롭힘';

  @override
  String get safetyReportReasonHateSpeech => '혐오 발언';

  @override
  String get safetyReportReasonInappropriateContent => '부적절한 콘텐츠';

  @override
  String get safetyReportDescriptionHint => '필요하다면 자세한 내용을 적어주세요.';

  @override
  String get safetyReportSubmit => '신고하기';

  @override
  String get safetyReportCancel => '취소';

  @override
  String get safetyReportSuccess => '신고가 접수됐어요.';

  @override
  String get safetyReportFailed => '신고를 접수하지 못했어요. 다시 시도해 주세요.';

  @override
  String get safetyCenterTitle => '안전 센터';

  @override
  String get safetyCenterDescription => '나와 상호작용할 수 있는 사람을 관리하고 안전 옵션을 확인해요.';

  @override
  String get safetyBlockedUsersTitle => '차단한 사용자';

  @override
  String get safetyBlockedUsersEmpty => '차단한 사용자가 없어요.';

  @override
  String get safetyBlockedUserFallback => '차단한 사용자';

  @override
  String get safetyUnblock => '차단 해제';

  @override
  String get safetyUnblockTitle => '차단을 해제할까요?';

  @override
  String get safetyUnblockBody => '상대방이 다시 나를 발견하거나 상호작용할 수 있어요.';

  @override
  String get safetyUnblockConfirm => '차단 해제';

  @override
  String get safetyUnblockCancel => '취소';

  @override
  String get safetyUnblockSuccess => '차단을 해제했어요.';

  @override
  String get safetyUnblockFailed => '차단을 해제하지 못했어요. 다시 시도해 주세요.';

  @override
  String get safetyTipsTitle => '안전 수칙';

  @override
  String get safetyTipFinancialInfo => '금융 정보나 민감한 개인정보를 공유하지 마세요.';

  @override
  String get safetyTipPublicPlace => '처음 만날 때는 사람이 많은 공개된 장소를 선택하세요.';

  @override
  String get safetyTipReportSuspicious => '의심스러운 행동은 신고해 주세요.';

  @override
  String get safetyTipBlockUncomfortable => '불편함을 느끼면 언제든 차단할 수 있어요.';

  @override
  String get safetyTipTrustInstincts => '직감을 믿으세요.';

  @override
  String get safetyReportInfoTitle => '신고 안내';

  @override
  String get safetyReportInfoBody => '신고 내용은 운영팀이 검토하며, 신고 대상에게 알림이 가지 않아요.';

  @override
  String get safetyBlockInfoTitle => '차단 안내';

  @override
  String get safetyBlockInfoBody => '차단하면 서로를 발견하거나 매치하고 메시지를 보낼 수 없어요.';

  @override
  String get profileSafetyTile => '안전 센터';

  @override
  String get profileSafetySubtitle => '차단 사용자 관리 및 안전 설정';

  @override
  String get verificationTitle => '인증';

  @override
  String get verificationProfileTile => '인증';

  @override
  String get verificationProfileSubtitle => '프로필 사진 인증하기';

  @override
  String get photoVerificationTitle => '사진 인증';

  @override
  String get photoVerificationDescription =>
      '사진 인증은 Bloom 커뮤니티의 신뢰를 높이는 데 도움이 돼요.';

  @override
  String get photoVerificationPrivacyNote =>
      '인증 사진은 검토 목적으로만 사용되며 프로필에 표시되지 않아요.';

  @override
  String get photoVerificationPickPhoto => '사진 선택';

  @override
  String get photoVerificationChangePhoto => '사진 변경';

  @override
  String get photoVerificationSubmit => '인증 요청하기';

  @override
  String get photoVerificationSubmitting => '제출 중…';

  @override
  String get photoVerificationSubmitted => '인증 요청이 접수됐어요.';

  @override
  String get photoVerificationPendingTitle => '검토 중이에요';

  @override
  String get photoVerificationPendingBody => '인증 요청을 검토하고 있어요.';

  @override
  String get photoVerificationApprovedTitle => '인증 완료';

  @override
  String get photoVerificationApprovedBody => '사진 인증이 완료됐어요.';

  @override
  String get photoVerificationRejectedTitle => '인증이 거절됐어요';

  @override
  String get photoVerificationRejectedBody => '안내 내용을 확인하고 다시 제출해 주세요.';

  @override
  String get photoVerificationFailed => '인증 요청을 제출하지 못했어요. 다시 시도해 주세요.';

  @override
  String get photoVerificationImageRequired => '인증에 사용할 사진을 선택해 주세요.';

  @override
  String get photoVerificationAlreadyPending => '이미 검토 중인 인증 요청이 있어요.';
}
