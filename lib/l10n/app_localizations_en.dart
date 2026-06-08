// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get continueAction => 'Continue';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get openAppSettings => 'Open App Settings';

  @override
  String get openLocationSettings => 'Open Location Settings';

  @override
  String get loginTagline => 'Be yourself. Find connection.';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginEmailHint => 'you@example.com';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSignIn => 'Sign In';

  @override
  String get loginOr => 'or';

  @override
  String get loginContinueWithGoogle => 'Continue with Google';

  @override
  String get loginContinueWithApple => 'Continue with Apple';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginSignUp => 'Sign up';

  @override
  String get loginEmailRequired => 'Please enter your email.';

  @override
  String get loginEmailInvalid => 'Please enter a valid email.';

  @override
  String get loginPasswordRequired => 'Please enter your password.';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Join Bloom today.';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerCreateAccount => 'Create Account';

  @override
  String get registerHaveAccount => 'Already have an account?';

  @override
  String get registerSignIn => 'Sign in';

  @override
  String get registerPasswordRequired => 'Please enter a password.';

  @override
  String get registerPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get registerPasswordMismatch => 'Passwords do not match.';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get forgotPasswordSendEmail => 'Send Reset Email';

  @override
  String get forgotPasswordCheckInbox => 'Check your inbox';

  @override
  String get forgotPasswordEmailSent =>
      'We\'ve sent a password reset link to your email address.';

  @override
  String get forgotPasswordBackToSignIn => 'Back to Sign In';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Bloom';

  @override
  String get onboardingWelcomeBody =>
      'A safe, inclusive space for the LGBTQ+ community to build real, meaningful connections.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingVerifiedProfiles => 'Verified profiles you can trust';

  @override
  String get onboardingPrivacyProtected => 'Your privacy, protected';

  @override
  String get onboardingRealConnections => 'Connections that actually matter';

  @override
  String get onboardingIdentityTitle => 'How do you identify?';

  @override
  String get onboardingIdentityBody =>
      'This helps us personalise your experience. You can update this anytime.';

  @override
  String get onboardingAgeTitle => 'Your birthdate';

  @override
  String get onboardingAgeBody =>
      'You must be 18 or older. Your age is shown on your profile, not your exact birthdate.';

  @override
  String get onboardingSelectBirthdate => 'Select your birthdate';

  @override
  String get onboardingSelectBirthdateHelp => 'Select your birthdate';

  @override
  String get onboardingAgeTooYoung => 'You must be 18 or older to join.';

  @override
  String get onboardingProfileTitle => 'Create your profile';

  @override
  String get onboardingProfileBody => 'Tell others a bit about yourself.';

  @override
  String get onboardingNickname => 'Nickname';

  @override
  String get onboardingNicknameHint => 'How should people know you?';

  @override
  String get onboardingNicknameRequired => 'Please enter a nickname.';

  @override
  String get onboardingNicknameTooLong => 'Maximum 30 characters.';

  @override
  String get onboardingBio => 'Bio';

  @override
  String get onboardingBioHint => 'Write a short bio (optional)…';

  @override
  String get onboardingBioTooLong => 'Maximum 500 characters.';

  @override
  String get onboardingRelationshipGoal => 'Relationship goal';

  @override
  String get onboardingInterests => 'Interests';

  @override
  String get onboardingInterestsHint => 'Select up to 10.';

  @override
  String get onboardingPhotosTitle => 'Add your photos';

  @override
  String onboardingPhotosBody(int maxPhotos) {
    return 'Add up to $maxPhotos photos. The first photo is your primary photo. Long-press to drag and reorder.';
  }

  @override
  String get onboardingTapToAddPhoto => 'Tap to add a photo';

  @override
  String get onboardingPhotoPrimary => 'Primary';

  @override
  String get onboardingDiscoveryTitle => 'Who are you looking for?';

  @override
  String get onboardingDiscoveryBody =>
      'Set your discovery preferences. You can change these anytime.';

  @override
  String get onboardingAgeRange => 'Age range';

  @override
  String onboardingAgeRangeValue(int minAge, int maxAge) {
    return '$minAge – $maxAge';
  }

  @override
  String get onboardingMaxDistance => 'Max distance';

  @override
  String onboardingMaxDistanceValue(int distance) {
    return '$distance km';
  }

  @override
  String get onboardingShowMe => 'Show me';

  @override
  String get onboardingShowMeHint => 'Leave blank to show everyone.';

  @override
  String get onboardingLookingFor => 'Looking for';

  @override
  String get onboardingLookingForHint => 'Leave blank to show all goals.';

  @override
  String get onboardingLetsBloom => 'Let\'s Bloom 🌸';

  @override
  String get onboardingCreatingProfile => 'Creating your profile…';

  @override
  String get onboardingError => 'Something went wrong. Please try again.';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileNickname => 'Nickname';

  @override
  String get editProfileNicknameHint => 'How should people know you?';

  @override
  String get editProfileNicknameRequired => 'Please enter a nickname.';

  @override
  String get editProfileNicknameTooLong => 'Must be 30 characters or fewer.';

  @override
  String get editProfileBio => 'Bio';

  @override
  String get editProfileBioHint => 'Write a short bio (optional)…';

  @override
  String get editProfileBioTooLong => 'Bio must be 500 characters or fewer.';

  @override
  String get editProfileRelationshipGoal => 'Relationship goal';

  @override
  String get editProfileInterests => 'Interests';

  @override
  String get editProfileInterestsHint => 'Select up to 10.';

  @override
  String get editProfileSelectGoal => 'Please select a relationship goal.';

  @override
  String get managePhotosTitle => 'Manage Photos';

  @override
  String get managePhotosHint =>
      'Drag ≡ to reorder. The first photo is your primary photo.';

  @override
  String managePhotosAddButton(int count, int max) {
    return 'Add photo ($count/$max)';
  }

  @override
  String get managePhotosEmpty => 'No photos yet';

  @override
  String get managePhotosSetAsPrimary => 'Set as primary';

  @override
  String get managePhotosDelete => 'Delete';

  @override
  String get managePhotosPrimary => 'Primary';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyProfileVisibility => 'Profile visibility';

  @override
  String get privacyPublic => 'Public';

  @override
  String get privacyHidden => 'Hidden';

  @override
  String get privacySelective => 'Selective';

  @override
  String get privacyPublicDesc => 'Your profile can appear to eligible users.';

  @override
  String get privacyHiddenDesc => 'Your profile will not appear in discovery.';

  @override
  String get privacySelectiveDesc =>
      'Your profile visibility is limited based on your preferences.';

  @override
  String get privacyWhoCanSeeYou => 'Who can see you';

  @override
  String get privacyOnlineStatus => 'Online status';

  @override
  String get privacyOnlineStatusDesc => 'Show when you are online.';

  @override
  String get privacyLastSeen => 'Last seen';

  @override
  String get privacyLastSeenDesc => 'Show your last active time.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsKeepUpdated => 'Keep me updated';

  @override
  String get notificationsMatch => 'Match notifications';

  @override
  String get notificationsMatchDesc =>
      'Get notified when a new connection blooms.';

  @override
  String get notificationsMessage => 'Message notifications';

  @override
  String get notificationsMessageDesc =>
      'Get notified when someone sends you a message.';

  @override
  String get notificationsLike => 'Like notifications';

  @override
  String get notificationsLikeDesc =>
      'Get notified when someone likes your profile.';

  @override
  String get notificationsVerification => 'Verification notifications';

  @override
  String get notificationsVerificationDesc =>
      'Get notified about verification updates.';

  @override
  String get locationPermissionTitle => 'Location permission';

  @override
  String get locationPermissionMainTitle =>
      'Help Bloom show nearby connections';

  @override
  String get locationPermissionBody =>
      'Bloom uses your location to calculate approximate distance later. Your exact location is never shown to other users.';

  @override
  String get locationPermissionGrantedStatus =>
      'Location permission is enabled.';

  @override
  String get locationPermissionServiceDisabled =>
      'Location services are turned off on this device.';

  @override
  String get locationPermissionDenied =>
      'Location permission is needed before nearby discovery can work.';

  @override
  String get locationPermissionDeniedForever =>
      'Location permission is blocked. You can enable it in app settings.';

  @override
  String get locationPermissionGrantedLabel => 'Permission granted';

  @override
  String get locationPermissionAllow => 'Allow Location';

  @override
  String get locationPermissionCheckFailed =>
      'Failed to check location permission. Please try again.';

  @override
  String get locationPermissionRequestFailed =>
      'Failed to request location permission. Please try again.';

  @override
  String get locationUpdateButton => 'Update location';

  @override
  String get locationUpdateSuccess => 'Location updated.';

  @override
  String get locationUpdateFailed =>
      'Failed to update location. Please try again.';

  @override
  String get locationPermissionRequiredForUpdate =>
      'Location permission is required to update your location.';

  @override
  String get locationServiceDisabledForUpdate =>
      'Please enable location services to update your location.';

  @override
  String get locationNotUpdatedYet => 'Location not updated yet';

  @override
  String locationLastUpdated(String timeAgo) {
    return 'Last updated $timeAgo';
  }

  @override
  String get profileAbout => 'About';

  @override
  String get profileLookingFor => 'Looking for';

  @override
  String get profileInterests => 'Interests';

  @override
  String get profileErrorLoad =>
      'Could not load your profile. Please try again.';

  @override
  String get profilePrivacyTile => 'Privacy settings';

  @override
  String get profileNotificationsTile => 'Notifications';

  @override
  String get profileNotificationsSubtitle =>
      'Manage match, message, like, and verification alerts';

  @override
  String get profileLocationTile => 'Location';

  @override
  String get profileLocationSubtitle =>
      'Manage location permission for nearby discovery';

  @override
  String get profileLanguageTile => 'Language';

  @override
  String get profileLanguageSubtitle => 'Choose your app language';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageErrorSave =>
      'Failed to save language preference. Please try again.';

  @override
  String get navExplore => 'Explore';

  @override
  String get navBrowse => 'Browse';

  @override
  String get navChat => 'Chat';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filtersApply => 'Apply';

  @override
  String get filtersReset => 'Reset';

  @override
  String get filtersAge => 'Age';

  @override
  String get filtersIdentity => 'Identity';

  @override
  String get filtersRelationshipGoal => 'Relationship Goal';

  @override
  String get filtersVerifiedOnly => 'Verified profiles only';

  @override
  String get filtersDistance => 'Distance';

  @override
  String get filtersAnyDistance => 'Any';

  @override
  String filtersWithinKm(int km) {
    return 'Within $km km';
  }

  @override
  String filtersActiveCount(int count) {
    return '$count filter(s) active';
  }

  @override
  String get browseTitle => 'Browse';

  @override
  String get browseEmptyTitle => 'No profiles yet';

  @override
  String get browseEmptyBody => 'Check back later for new connections.';

  @override
  String get browseErrorTitle => 'Something went wrong';

  @override
  String get browseErrorBody => 'Could not load profiles. Please try again.';

  @override
  String get browseRetry => 'Retry';

  @override
  String get browseNeedsLocationTitle => 'Update your location';

  @override
  String get browseNeedsLocationBody =>
      'Bloom needs your location to find nearby connections.';

  @override
  String get browseUpdateLocation => 'Update Location';

  @override
  String get browseRefresh => 'Refresh';

  @override
  String get browseVerified => 'Verified';

  @override
  String get browsePremium => 'Premium';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreEmptyTitle => 'No profiles yet';

  @override
  String get exploreEmptyBody => 'Check back later for new connections.';

  @override
  String get exploreErrorTitle => 'Something went wrong';

  @override
  String get exploreErrorBody => 'Could not load profiles. Please try again.';

  @override
  String get exploreRetry => 'Retry';

  @override
  String get exploreNeedsLocationTitle => 'Update your location';

  @override
  String get exploreNeedsLocationBody =>
      'Bloom needs your location to find nearby connections.';

  @override
  String get exploreUpdateLocation => 'Update Location';

  @override
  String get exploreRefresh => 'Refresh';

  @override
  String get exploreVerified => 'Verified';

  @override
  String get explorePremium => 'Premium';

  @override
  String get mapDiscoveryTitle => 'Map';

  @override
  String get mapDiscoveryEmptyTitle => 'No profiles on the map yet';

  @override
  String get mapDiscoveryEmptyBody => 'Check back later for new connections.';

  @override
  String get mapDiscoveryErrorTitle => 'Something went wrong';

  @override
  String get mapDiscoveryErrorBody =>
      'Could not load profiles. Please try again.';

  @override
  String get mapDiscoveryRetry => 'Retry';

  @override
  String get mapDiscoveryNeedsLocationTitle => 'Update your location';

  @override
  String get mapDiscoveryNeedsLocationBody =>
      'Update your location to discover nearby connections on the map.';

  @override
  String get mapDiscoveryUpdateLocation => 'Update Location';

  @override
  String get mapDiscoveryApproximateArea => 'Approximate area';

  @override
  String get mapDiscoveryOpenMap => 'Map';

  @override
  String get swipePass => 'Pass';

  @override
  String get swipeLike => 'Like';

  @override
  String get swipeSuperLike => 'Super Like';

  @override
  String get swipePassedFeedback => 'Passed';

  @override
  String get swipeLikedFeedback => 'Liked';

  @override
  String get swipeSuperLikedFeedback => 'Super liked';

  @override
  String compatibilityMatchPercent(int percentage) {
    return '$percentage% match';
  }

  @override
  String get compatibilityNewProfile => 'New profile';

  @override
  String get compatibilityAboutTitle => 'Compatibility';

  @override
  String get compatibilityApproxNote => 'Based on approximate location data';

  @override
  String get compatibilityReasonSharedInterests => 'Similar interests';

  @override
  String get compatibilityReasonRelationshipGoal =>
      'Looking for similar relationship';

  @override
  String get compatibilityReasonIdentityFit => 'Identity is a great match';

  @override
  String get compatibilityReasonAgeRange => 'Age is within your preference';

  @override
  String get compatibilityReasonNearbyArea => 'May be in a nearby area';

  @override
  String get compatibilityReasonVerified => 'Verified profile';

  @override
  String get matchCelebrationTitle => 'It\'s a match!';

  @override
  String matchCelebrationSubtitle(String name) {
    return 'You and $name liked each other.';
  }

  @override
  String get matchCelebrationKeepExploring => 'Keep exploring';

  @override
  String get matchCelebrationFallbackName => 'Someone';

  @override
  String get mapNearbyTitle => 'Nearby users';

  @override
  String mapNearbyRadiusLabel(int radiusKm) {
    return 'Within $radiusKm km';
  }

  @override
  String get mapNearbyNoUsers => 'No nearby users yet.';

  @override
  String get mapNearbyFewerThanFive => 'Fewer than 5 nearby users';

  @override
  String mapNearbyCountPlus(int count) {
    return '$count+ nearby users';
  }

  @override
  String get mapNearbyPrivacyNotice =>
      'For safety, individual user locations are not shown.';

  @override
  String get mapNearbyLoadFailed =>
      'Couldn\'t load nearby user count. Please try again.';

  @override
  String get mapMyLocation => 'My location';

  @override
  String get mapApproximatePrivacyNote => 'Profiles shown by approximate area.';

  @override
  String get mapMyLocationPermissionTitle => 'Location permission needed';

  @override
  String get mapMyLocationPermissionBody =>
      'Allow location access to see your position on the map.';

  @override
  String get mapMyLocationPermissionAction => 'Allow location';

  @override
  String get mapMyLocationUnavailable =>
      'Location unavailable. Please try again.';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get conversationListEmptyTitle => 'No conversations yet';

  @override
  String get conversationListEmptyBody =>
      'When you match with someone, you\'ll see them here.';

  @override
  String get conversationListErrorTitle => 'Couldn\'t load conversations';

  @override
  String get conversationListErrorBody => 'Please try again in a moment.';

  @override
  String get conversationListRetry => 'Retry';

  @override
  String get conversationNoMessagesYet => 'You matched. Say hello soon.';

  @override
  String get conversationChatComingSoon => 'Chat is coming soon.';

  @override
  String get conversationUnknownUser => 'Unknown';

  @override
  String get chatStartConversation => 'Start the conversation.';

  @override
  String get chatMessageHint => 'Type a message';

  @override
  String get chatSend => 'Send';

  @override
  String get chatSending => 'Sending';

  @override
  String get chatLoadErrorTitle => 'Couldn\'t load messages';

  @override
  String get chatLoadErrorBody => 'Please try again in a moment.';

  @override
  String get chatRetry => 'Retry';

  @override
  String get chatSendFailed => 'Couldn\'t send message. Please try again.';

  @override
  String get chatUnknownUser => 'Unknown';

  @override
  String get chatAttachImage => 'Attach image';

  @override
  String get chatImageSendFailed => 'Couldn\'t send image. Please try again.';

  @override
  String get chatImageMessageFallback => 'Image unavailable';

  @override
  String get conversationPhotoMessage => 'Photo';

  @override
  String chatTypingIndicator(String name) {
    return '$name is typing...';
  }

  @override
  String get chatTypingFallbackName => 'Someone';

  @override
  String get chatMessageSent => 'Sent';

  @override
  String get chatMessageRead => 'Read';

  @override
  String get chatUnmatch => 'Unmatch';

  @override
  String get chatUnmatchTitle => 'Unmatch?';

  @override
  String chatUnmatchBody(String name) {
    return 'You and $name will no longer be able to message each other.';
  }

  @override
  String get chatUnmatchConfirm => 'Unmatch';

  @override
  String get chatUnmatchCancel => 'Cancel';

  @override
  String get chatUnmatchSuccess => 'Match removed.';

  @override
  String get chatUnmatchFailed => 'Couldn\'t unmatch. Please try again.';

  @override
  String get notificationCenterTitle => 'Notifications';

  @override
  String get notificationCenterEmpty => 'No notifications yet.';

  @override
  String get notificationCenterLoadError => 'Couldn\'t load notifications.';

  @override
  String get notificationCenterMarkAllRead => 'Mark all read';

  @override
  String get notificationCenterMarkedAllRead =>
      'All notifications marked as read.';

  @override
  String get safetyBlockUser => 'Block user';

  @override
  String get safetyBlockTitle => 'Block this user?';

  @override
  String get safetyBlockBody =>
      'You won\'t see each other, match, or message anymore.';

  @override
  String get safetyBlockConfirm => 'Block';

  @override
  String get safetyBlockCancel => 'Cancel';

  @override
  String get safetyBlockSuccess => 'User blocked.';

  @override
  String get safetyBlockFailed => 'Couldn\'t block user. Please try again.';

  @override
  String get safetyCannotBlockSelf => 'You can\'t block yourself.';

  @override
  String get safetyReportUser => 'Report user';

  @override
  String get safetyReportTitle => 'Report this user?';

  @override
  String get safetyReportReasonSpam => 'Spam';

  @override
  String get safetyReportReasonFakeProfile => 'Fake profile';

  @override
  String get safetyReportReasonHarassment => 'Harassment';

  @override
  String get safetyReportReasonHateSpeech => 'Hate speech';

  @override
  String get safetyReportReasonInappropriateContent => 'Inappropriate content';

  @override
  String get safetyReportDescriptionHint => 'Add details, if you\'d like.';

  @override
  String get safetyReportSubmit => 'Submit report';

  @override
  String get safetyReportCancel => 'Cancel';

  @override
  String get safetyReportSuccess => 'Report submitted.';

  @override
  String get safetyReportFailed => 'Couldn\'t submit report. Please try again.';

  @override
  String get safetyCenterTitle => 'Safety Center';

  @override
  String get safetyCenterDescription =>
      'Control who can interact with you and review safety options.';

  @override
  String get safetyBlockedUsersTitle => 'Blocked users';

  @override
  String get safetyBlockedUsersEmpty => 'You haven\'t blocked anyone.';

  @override
  String get safetyBlockedUserFallback => 'Blocked user';

  @override
  String get safetyUnblock => 'Unblock';

  @override
  String get safetyUnblockTitle => 'Unblock this user?';

  @override
  String get safetyUnblockBody =>
      'They may be able to find or interact with you again.';

  @override
  String get safetyUnblockConfirm => 'Unblock';

  @override
  String get safetyUnblockCancel => 'Cancel';

  @override
  String get safetyUnblockSuccess => 'User unblocked.';

  @override
  String get safetyUnblockFailed => 'Couldn\'t unblock user. Please try again.';

  @override
  String get safetyTipsTitle => 'Safety tips';

  @override
  String get safetyTipFinancialInfo =>
      'Don\'t share financial or personal information.';

  @override
  String get safetyTipPublicPlace =>
      'Choose a public place for your first meeting.';

  @override
  String get safetyTipReportSuspicious => 'Report any suspicious behavior.';

  @override
  String get safetyTipBlockUncomfortable =>
      'Block anyone who makes you feel uncomfortable.';

  @override
  String get safetyTipTrustInstincts => 'Trust your instincts.';

  @override
  String get safetyReportInfoTitle => 'About reports';

  @override
  String get safetyReportInfoBody =>
      'Reports are reviewed by the team. The reported user won\'t be notified.';

  @override
  String get safetyBlockInfoTitle => 'About blocking';

  @override
  String get safetyBlockInfoBody =>
      'Blocking prevents discovery, matching, and messaging.';

  @override
  String get profileSafetyTile => 'Safety Center';

  @override
  String get profileSafetySubtitle => 'Manage blocked users and safety options';

  @override
  String get verificationTitle => 'Verification';

  @override
  String get verificationProfileTile => 'Verification';

  @override
  String get verificationProfileSubtitle => 'Verify your profile photo';

  @override
  String get photoVerificationTitle => 'Photo Verification';

  @override
  String get photoVerificationDescription =>
      'Photo verification helps build trust in the Bloom community.';

  @override
  String get photoVerificationPrivacyNote =>
      'Your verification photo is used only for review and is not shown on your profile.';

  @override
  String get photoVerificationPickPhoto => 'Select Photo';

  @override
  String get photoVerificationChangePhoto => 'Change Photo';

  @override
  String get photoVerificationSubmit => 'Submit Verification Request';

  @override
  String get photoVerificationSubmitting => 'Submitting…';

  @override
  String get photoVerificationSubmitted => 'Verification request submitted.';

  @override
  String get photoVerificationPendingTitle => 'Under Review';

  @override
  String get photoVerificationPendingBody =>
      'Your verification request is under review.';

  @override
  String get photoVerificationApprovedTitle => 'Verified';

  @override
  String get photoVerificationApprovedBody =>
      'Your photo verification is complete.';

  @override
  String get photoVerificationRejectedTitle => 'Verification Declined';

  @override
  String get photoVerificationRejectedBody =>
      'Please review the feedback and resubmit.';

  @override
  String get photoVerificationFailed =>
      'Couldn\'t submit verification request. Please try again.';

  @override
  String get photoVerificationImageRequired =>
      'Please select a photo for verification.';

  @override
  String get photoVerificationAlreadyPending =>
      'You already have a pending verification request.';

  @override
  String get verificationBadgePhoto => 'Photo Verified';

  @override
  String get verificationBadgeVerified => 'Verified';

  @override
  String get verificationBadgePhotoSemantic => 'Photo verified';

  @override
  String get verificationBadgeVerifiedSemantic => 'Identity verified';

  @override
  String get verificationManagementTitle => 'Verification Requests';

  @override
  String get verificationManagementAccessDenied => 'Admin access required.';

  @override
  String get verificationManagementLoadFailed =>
      'Couldn\'t load verification requests. Please try again.';

  @override
  String get verificationManagementEmpty => 'No pending verification requests.';

  @override
  String get verificationManagementPhotoOnlyNotice =>
      'Showing photo verification requests only.';

  @override
  String get verificationManagementApproved => 'Approved.';

  @override
  String get verificationManagementRejected => 'Rejected.';

  @override
  String get verificationManagementActionFailed =>
      'Action failed. Please try again.';

  @override
  String get verificationManagementApproveTitle => 'Approve verification?';

  @override
  String get verificationManagementApproveBody =>
      'This will approve the photo verification request.';

  @override
  String get verificationManagementApprove => 'Approve';

  @override
  String get verificationManagementImageLoadFailed => 'Image unavailable';

  @override
  String get verificationManagementReject => 'Reject';

  @override
  String get verificationManagementRejectTitle => 'Reject verification?';

  @override
  String get verificationManagementRejectReasonHint =>
      'Enter rejection reason…';

  @override
  String get verificationManagementRejectReasonRequired =>
      'Please enter a rejection reason.';
}
