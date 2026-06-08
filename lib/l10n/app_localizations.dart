import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @openAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open App Settings'**
  String get openAppSettings;

  /// No description provided for @openLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Location Settings'**
  String get openLocationSettings;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Be yourself. Find connection.'**
  String get loginTagline;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get loginEmailHint;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignIn;

  /// No description provided for @loginOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get loginOr;

  /// No description provided for @loginContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginContinueWithGoogle;

  /// No description provided for @loginContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginContinueWithApple;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUp;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get loginPasswordRequired;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Bloom today.'**
  String get registerSubtitle;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerCreateAccount;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerHaveAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerSignIn;

  /// No description provided for @registerPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password.'**
  String get registerPasswordRequired;

  /// No description provided for @registerPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get registerPasswordTooShort;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get registerPasswordMismatch;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get forgotPasswordSendEmail;

  /// No description provided for @forgotPasswordCheckInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get forgotPasswordCheckInbox;

  /// No description provided for @forgotPasswordEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset link to your email address.'**
  String get forgotPasswordEmailSent;

  /// No description provided for @forgotPasswordBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get forgotPasswordBackToSignIn;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Bloom'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A safe, inclusive space for the LGBTQ+ community to build real, meaningful connections.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingVerifiedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Verified profiles you can trust'**
  String get onboardingVerifiedProfiles;

  /// No description provided for @onboardingPrivacyProtected.
  ///
  /// In en, this message translates to:
  /// **'Your privacy, protected'**
  String get onboardingPrivacyProtected;

  /// No description provided for @onboardingRealConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections that actually matter'**
  String get onboardingRealConnections;

  /// No description provided for @onboardingIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you identify?'**
  String get onboardingIdentityTitle;

  /// No description provided for @onboardingIdentityBody.
  ///
  /// In en, this message translates to:
  /// **'This helps us personalise your experience. You can update this anytime.'**
  String get onboardingIdentityBody;

  /// No description provided for @onboardingAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your birthdate'**
  String get onboardingAgeTitle;

  /// No description provided for @onboardingAgeBody.
  ///
  /// In en, this message translates to:
  /// **'You must be 18 or older. Your age is shown on your profile, not your exact birthdate.'**
  String get onboardingAgeBody;

  /// No description provided for @onboardingSelectBirthdate.
  ///
  /// In en, this message translates to:
  /// **'Select your birthdate'**
  String get onboardingSelectBirthdate;

  /// No description provided for @onboardingSelectBirthdateHelp.
  ///
  /// In en, this message translates to:
  /// **'Select your birthdate'**
  String get onboardingSelectBirthdateHelp;

  /// No description provided for @onboardingAgeTooYoung.
  ///
  /// In en, this message translates to:
  /// **'You must be 18 or older to join.'**
  String get onboardingAgeTooYoung;

  /// No description provided for @onboardingProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get onboardingProfileTitle;

  /// No description provided for @onboardingProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Tell others a bit about yourself.'**
  String get onboardingProfileBody;

  /// No description provided for @onboardingNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get onboardingNickname;

  /// No description provided for @onboardingNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'How should people know you?'**
  String get onboardingNicknameHint;

  /// No description provided for @onboardingNicknameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a nickname.'**
  String get onboardingNicknameRequired;

  /// No description provided for @onboardingNicknameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Maximum 30 characters.'**
  String get onboardingNicknameTooLong;

  /// No description provided for @onboardingBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get onboardingBio;

  /// No description provided for @onboardingBioHint.
  ///
  /// In en, this message translates to:
  /// **'Write a short bio (optional)…'**
  String get onboardingBioHint;

  /// No description provided for @onboardingBioTooLong.
  ///
  /// In en, this message translates to:
  /// **'Maximum 500 characters.'**
  String get onboardingBioTooLong;

  /// No description provided for @onboardingRelationshipGoal.
  ///
  /// In en, this message translates to:
  /// **'Relationship goal'**
  String get onboardingRelationshipGoal;

  /// No description provided for @onboardingInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get onboardingInterests;

  /// No description provided for @onboardingInterestsHint.
  ///
  /// In en, this message translates to:
  /// **'Select up to 10.'**
  String get onboardingInterestsHint;

  /// No description provided for @onboardingPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your photos'**
  String get onboardingPhotosTitle;

  /// No description provided for @onboardingPhotosBody.
  ///
  /// In en, this message translates to:
  /// **'Add up to {maxPhotos} photos. The first photo is your primary photo. Long-press to drag and reorder.'**
  String onboardingPhotosBody(int maxPhotos);

  /// No description provided for @onboardingTapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a photo'**
  String get onboardingTapToAddPhoto;

  /// No description provided for @onboardingPhotoPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get onboardingPhotoPrimary;

  /// No description provided for @onboardingDiscoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you looking for?'**
  String get onboardingDiscoveryTitle;

  /// No description provided for @onboardingDiscoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Set your discovery preferences. You can change these anytime.'**
  String get onboardingDiscoveryBody;

  /// No description provided for @onboardingAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get onboardingAgeRange;

  /// No description provided for @onboardingAgeRangeValue.
  ///
  /// In en, this message translates to:
  /// **'{minAge} – {maxAge}'**
  String onboardingAgeRangeValue(int minAge, int maxAge);

  /// No description provided for @onboardingMaxDistance.
  ///
  /// In en, this message translates to:
  /// **'Max distance'**
  String get onboardingMaxDistance;

  /// No description provided for @onboardingMaxDistanceValue.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String onboardingMaxDistanceValue(int distance);

  /// No description provided for @onboardingShowMe.
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get onboardingShowMe;

  /// No description provided for @onboardingShowMeHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to show everyone.'**
  String get onboardingShowMeHint;

  /// No description provided for @onboardingLookingFor.
  ///
  /// In en, this message translates to:
  /// **'Looking for'**
  String get onboardingLookingFor;

  /// No description provided for @onboardingLookingForHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to show all goals.'**
  String get onboardingLookingForHint;

  /// No description provided for @onboardingLetsBloom.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Bloom 🌸'**
  String get onboardingLetsBloom;

  /// No description provided for @onboardingCreatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Creating your profile…'**
  String get onboardingCreatingProfile;

  /// No description provided for @onboardingError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get onboardingError;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get editProfileNickname;

  /// No description provided for @editProfileNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'How should people know you?'**
  String get editProfileNicknameHint;

  /// No description provided for @editProfileNicknameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a nickname.'**
  String get editProfileNicknameRequired;

  /// No description provided for @editProfileNicknameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Must be 30 characters or fewer.'**
  String get editProfileNicknameTooLong;

  /// No description provided for @editProfileBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get editProfileBio;

  /// No description provided for @editProfileBioHint.
  ///
  /// In en, this message translates to:
  /// **'Write a short bio (optional)…'**
  String get editProfileBioHint;

  /// No description provided for @editProfileBioTooLong.
  ///
  /// In en, this message translates to:
  /// **'Bio must be 500 characters or fewer.'**
  String get editProfileBioTooLong;

  /// No description provided for @editProfileRelationshipGoal.
  ///
  /// In en, this message translates to:
  /// **'Relationship goal'**
  String get editProfileRelationshipGoal;

  /// No description provided for @editProfileInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get editProfileInterests;

  /// No description provided for @editProfileInterestsHint.
  ///
  /// In en, this message translates to:
  /// **'Select up to 10.'**
  String get editProfileInterestsHint;

  /// No description provided for @editProfileSelectGoal.
  ///
  /// In en, this message translates to:
  /// **'Please select a relationship goal.'**
  String get editProfileSelectGoal;

  /// No description provided for @managePhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Photos'**
  String get managePhotosTitle;

  /// No description provided for @managePhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Drag ≡ to reorder. The first photo is your primary photo.'**
  String get managePhotosHint;

  /// No description provided for @managePhotosAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add photo ({count}/{max})'**
  String managePhotosAddButton(int count, int max);

  /// No description provided for @managePhotosEmpty.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get managePhotosEmpty;

  /// No description provided for @managePhotosSetAsPrimary.
  ///
  /// In en, this message translates to:
  /// **'Set as primary'**
  String get managePhotosSetAsPrimary;

  /// No description provided for @managePhotosDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get managePhotosDelete;

  /// No description provided for @managePhotosPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get managePhotosPrimary;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyProfileVisibility.
  ///
  /// In en, this message translates to:
  /// **'Profile visibility'**
  String get privacyProfileVisibility;

  /// No description provided for @privacyPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get privacyPublic;

  /// No description provided for @privacyHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get privacyHidden;

  /// No description provided for @privacySelective.
  ///
  /// In en, this message translates to:
  /// **'Selective'**
  String get privacySelective;

  /// No description provided for @privacyPublicDesc.
  ///
  /// In en, this message translates to:
  /// **'Your profile can appear to eligible users.'**
  String get privacyPublicDesc;

  /// No description provided for @privacyHiddenDesc.
  ///
  /// In en, this message translates to:
  /// **'Your profile will not appear in discovery.'**
  String get privacyHiddenDesc;

  /// No description provided for @privacySelectiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Your profile visibility is limited based on your preferences.'**
  String get privacySelectiveDesc;

  /// No description provided for @privacyWhoCanSeeYou.
  ///
  /// In en, this message translates to:
  /// **'Who can see you'**
  String get privacyWhoCanSeeYou;

  /// No description provided for @privacyOnlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Online status'**
  String get privacyOnlineStatus;

  /// No description provided for @privacyOnlineStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Show when you are online.'**
  String get privacyOnlineStatusDesc;

  /// No description provided for @privacyLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get privacyLastSeen;

  /// No description provided for @privacyLastSeenDesc.
  ///
  /// In en, this message translates to:
  /// **'Show your last active time.'**
  String get privacyLastSeenDesc;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsKeepUpdated.
  ///
  /// In en, this message translates to:
  /// **'Keep me updated'**
  String get notificationsKeepUpdated;

  /// No description provided for @notificationsMatch.
  ///
  /// In en, this message translates to:
  /// **'Match notifications'**
  String get notificationsMatch;

  /// No description provided for @notificationsMatchDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a new connection blooms.'**
  String get notificationsMatchDesc;

  /// No description provided for @notificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Message notifications'**
  String get notificationsMessage;

  /// No description provided for @notificationsMessageDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone sends you a message.'**
  String get notificationsMessageDesc;

  /// No description provided for @notificationsLike.
  ///
  /// In en, this message translates to:
  /// **'Like notifications'**
  String get notificationsLike;

  /// No description provided for @notificationsLikeDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when someone likes your profile.'**
  String get notificationsLikeDesc;

  /// No description provided for @notificationsVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification notifications'**
  String get notificationsVerification;

  /// No description provided for @notificationsVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified about verification updates.'**
  String get notificationsVerificationDesc;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionMainTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Bloom show nearby connections'**
  String get locationPermissionMainTitle;

  /// No description provided for @locationPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Bloom uses your location to calculate approximate distance later. Your exact location is never shown to other users.'**
  String get locationPermissionBody;

  /// No description provided for @locationPermissionGrantedStatus.
  ///
  /// In en, this message translates to:
  /// **'Location permission is enabled.'**
  String get locationPermissionGrantedStatus;

  /// No description provided for @locationPermissionServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off on this device.'**
  String get locationPermissionServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed before nearby discovery can work.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. You can enable it in app settings.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @locationPermissionGrantedLabel.
  ///
  /// In en, this message translates to:
  /// **'Permission granted'**
  String get locationPermissionGrantedLabel;

  /// No description provided for @locationPermissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get locationPermissionAllow;

  /// No description provided for @locationPermissionCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to check location permission. Please try again.'**
  String get locationPermissionCheckFailed;

  /// No description provided for @locationPermissionRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to request location permission. Please try again.'**
  String get locationPermissionRequestFailed;

  /// No description provided for @locationUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update location'**
  String get locationUpdateButton;

  /// No description provided for @locationUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location updated.'**
  String get locationUpdateSuccess;

  /// No description provided for @locationUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update location. Please try again.'**
  String get locationUpdateFailed;

  /// No description provided for @locationPermissionRequiredForUpdate.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to update your location.'**
  String get locationPermissionRequiredForUpdate;

  /// No description provided for @locationServiceDisabledForUpdate.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services to update your location.'**
  String get locationServiceDisabledForUpdate;

  /// No description provided for @locationNotUpdatedYet.
  ///
  /// In en, this message translates to:
  /// **'Location not updated yet'**
  String get locationNotUpdatedYet;

  /// No description provided for @locationLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {timeAgo}'**
  String locationLastUpdated(String timeAgo);

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// No description provided for @profileLookingFor.
  ///
  /// In en, this message translates to:
  /// **'Looking for'**
  String get profileLookingFor;

  /// No description provided for @profileInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get profileInterests;

  /// No description provided for @profileErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile. Please try again.'**
  String get profileErrorLoad;

  /// No description provided for @profilePrivacyTile.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings'**
  String get profilePrivacyTile;

  /// No description provided for @profileNotificationsTile.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotificationsTile;

  /// No description provided for @profileNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage match, message, like, and verification alerts'**
  String get profileNotificationsSubtitle;

  /// No description provided for @profileLocationTile.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get profileLocationTile;

  /// No description provided for @profileLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage location permission for nearby discovery'**
  String get profileLocationSubtitle;

  /// No description provided for @profileLanguageTile.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageTile;

  /// No description provided for @profileLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your app language'**
  String get profileLanguageSubtitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @languageErrorSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save language preference. Please try again.'**
  String get languageErrorSave;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get navBrowse;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filtersApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filtersApply;

  /// No description provided for @filtersReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filtersReset;

  /// No description provided for @filtersAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get filtersAge;

  /// No description provided for @filtersIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get filtersIdentity;

  /// No description provided for @filtersRelationshipGoal.
  ///
  /// In en, this message translates to:
  /// **'Relationship Goal'**
  String get filtersRelationshipGoal;

  /// No description provided for @filtersVerifiedOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified profiles only'**
  String get filtersVerifiedOnly;

  /// No description provided for @filtersDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get filtersDistance;

  /// No description provided for @filtersAnyDistance.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get filtersAnyDistance;

  /// No description provided for @filtersWithinKm.
  ///
  /// In en, this message translates to:
  /// **'Within {km} km'**
  String filtersWithinKm(int km);

  /// No description provided for @filtersActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} filter(s) active'**
  String filtersActiveCount(int count);

  /// No description provided for @browseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browseTitle;

  /// No description provided for @browseEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No profiles yet'**
  String get browseEmptyTitle;

  /// No description provided for @browseEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new connections.'**
  String get browseEmptyBody;

  /// No description provided for @browseErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get browseErrorTitle;

  /// No description provided for @browseErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Could not load profiles. Please try again.'**
  String get browseErrorBody;

  /// No description provided for @browseRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get browseRetry;

  /// No description provided for @browseNeedsLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Update your location'**
  String get browseNeedsLocationTitle;

  /// No description provided for @browseNeedsLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Bloom needs your location to find nearby connections.'**
  String get browseNeedsLocationBody;

  /// No description provided for @browseUpdateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get browseUpdateLocation;

  /// No description provided for @browseRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get browseRefresh;

  /// No description provided for @browseVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get browseVerified;

  /// No description provided for @browsePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get browsePremium;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No profiles yet'**
  String get exploreEmptyTitle;

  /// No description provided for @exploreEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new connections.'**
  String get exploreEmptyBody;

  /// No description provided for @exploreErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get exploreErrorTitle;

  /// No description provided for @exploreErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Could not load profiles. Please try again.'**
  String get exploreErrorBody;

  /// No description provided for @exploreRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get exploreRetry;

  /// No description provided for @exploreNeedsLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Update your location'**
  String get exploreNeedsLocationTitle;

  /// No description provided for @exploreNeedsLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Bloom needs your location to find nearby connections.'**
  String get exploreNeedsLocationBody;

  /// No description provided for @exploreUpdateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get exploreUpdateLocation;

  /// No description provided for @exploreRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get exploreRefresh;

  /// No description provided for @exploreVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get exploreVerified;

  /// No description provided for @explorePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get explorePremium;

  /// No description provided for @mapDiscoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapDiscoveryTitle;

  /// No description provided for @mapDiscoveryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No profiles on the map yet'**
  String get mapDiscoveryEmptyTitle;

  /// No description provided for @mapDiscoveryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new connections.'**
  String get mapDiscoveryEmptyBody;

  /// No description provided for @mapDiscoveryErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get mapDiscoveryErrorTitle;

  /// No description provided for @mapDiscoveryErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Could not load profiles. Please try again.'**
  String get mapDiscoveryErrorBody;

  /// No description provided for @mapDiscoveryRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get mapDiscoveryRetry;

  /// No description provided for @mapDiscoveryNeedsLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Update your location'**
  String get mapDiscoveryNeedsLocationTitle;

  /// No description provided for @mapDiscoveryNeedsLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Update your location to discover nearby connections on the map.'**
  String get mapDiscoveryNeedsLocationBody;

  /// No description provided for @mapDiscoveryUpdateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get mapDiscoveryUpdateLocation;

  /// No description provided for @mapDiscoveryApproximateArea.
  ///
  /// In en, this message translates to:
  /// **'Approximate area'**
  String get mapDiscoveryApproximateArea;

  /// No description provided for @mapDiscoveryOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapDiscoveryOpenMap;

  /// No description provided for @swipePass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get swipePass;

  /// No description provided for @swipeLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get swipeLike;

  /// No description provided for @swipeSuperLike.
  ///
  /// In en, this message translates to:
  /// **'Super Like'**
  String get swipeSuperLike;

  /// No description provided for @swipePassedFeedback.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get swipePassedFeedback;

  /// No description provided for @swipeLikedFeedback.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get swipeLikedFeedback;

  /// No description provided for @swipeSuperLikedFeedback.
  ///
  /// In en, this message translates to:
  /// **'Super liked'**
  String get swipeSuperLikedFeedback;

  /// No description provided for @compatibilityMatchPercent.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% match'**
  String compatibilityMatchPercent(int percentage);

  /// No description provided for @compatibilityNewProfile.
  ///
  /// In en, this message translates to:
  /// **'New profile'**
  String get compatibilityNewProfile;

  /// No description provided for @compatibilityAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get compatibilityAboutTitle;

  /// No description provided for @compatibilityApproxNote.
  ///
  /// In en, this message translates to:
  /// **'Based on approximate location data'**
  String get compatibilityApproxNote;

  /// No description provided for @compatibilityReasonSharedInterests.
  ///
  /// In en, this message translates to:
  /// **'Similar interests'**
  String get compatibilityReasonSharedInterests;

  /// No description provided for @compatibilityReasonRelationshipGoal.
  ///
  /// In en, this message translates to:
  /// **'Looking for similar relationship'**
  String get compatibilityReasonRelationshipGoal;

  /// No description provided for @compatibilityReasonIdentityFit.
  ///
  /// In en, this message translates to:
  /// **'Identity is a great match'**
  String get compatibilityReasonIdentityFit;

  /// No description provided for @compatibilityReasonAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Age is within your preference'**
  String get compatibilityReasonAgeRange;

  /// No description provided for @compatibilityReasonNearbyArea.
  ///
  /// In en, this message translates to:
  /// **'May be in a nearby area'**
  String get compatibilityReasonNearbyArea;

  /// No description provided for @compatibilityReasonVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified profile'**
  String get compatibilityReasonVerified;

  /// No description provided for @matchCelebrationTitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s a match!'**
  String get matchCelebrationTitle;

  /// No description provided for @matchCelebrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You and {name} liked each other.'**
  String matchCelebrationSubtitle(String name);

  /// No description provided for @matchCelebrationKeepExploring.
  ///
  /// In en, this message translates to:
  /// **'Keep exploring'**
  String get matchCelebrationKeepExploring;

  /// No description provided for @matchCelebrationFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get matchCelebrationFallbackName;

  /// No description provided for @mapNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby users'**
  String get mapNearbyTitle;

  /// No description provided for @mapNearbyRadiusLabel.
  ///
  /// In en, this message translates to:
  /// **'Within {radiusKm} km'**
  String mapNearbyRadiusLabel(int radiusKm);

  /// No description provided for @mapNearbyNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No nearby users yet.'**
  String get mapNearbyNoUsers;

  /// No description provided for @mapNearbyFewerThanFive.
  ///
  /// In en, this message translates to:
  /// **'Fewer than 5 nearby users'**
  String get mapNearbyFewerThanFive;

  /// No description provided for @mapNearbyCountPlus.
  ///
  /// In en, this message translates to:
  /// **'{count}+ nearby users'**
  String mapNearbyCountPlus(int count);

  /// No description provided for @mapNearbyPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'For safety, individual user locations are not shown.'**
  String get mapNearbyPrivacyNotice;

  /// No description provided for @mapNearbyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load nearby user count. Please try again.'**
  String get mapNearbyLoadFailed;

  /// No description provided for @mapMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapMyLocation;

  /// No description provided for @mapApproximatePrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Profiles shown by approximate area.'**
  String get mapApproximatePrivacyNote;

  /// No description provided for @mapMyLocationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission needed'**
  String get mapMyLocationPermissionTitle;

  /// No description provided for @mapMyLocationPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to see your position on the map.'**
  String get mapMyLocationPermissionBody;

  /// No description provided for @mapMyLocationPermissionAction.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get mapMyLocationPermissionAction;

  /// No description provided for @mapMyLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable. Please try again.'**
  String get mapMyLocationUnavailable;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @conversationListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get conversationListEmptyTitle;

  /// No description provided for @conversationListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When you match with someone, you\'ll see them here.'**
  String get conversationListEmptyBody;

  /// No description provided for @conversationListErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load conversations'**
  String get conversationListErrorTitle;

  /// No description provided for @conversationListErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get conversationListErrorBody;

  /// No description provided for @conversationListRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get conversationListRetry;

  /// No description provided for @conversationNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'You matched. Say hello soon.'**
  String get conversationNoMessagesYet;

  /// No description provided for @conversationChatComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Chat is coming soon.'**
  String get conversationChatComingSoon;

  /// No description provided for @conversationUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get conversationUnknownUser;

  /// No description provided for @chatStartConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation.'**
  String get chatStartConversation;

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get chatMessageHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get chatSending;

  /// No description provided for @chatLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load messages'**
  String get chatLoadErrorTitle;

  /// No description provided for @chatLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get chatLoadErrorBody;

  /// No description provided for @chatRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get chatRetry;

  /// No description provided for @chatSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send message. Please try again.'**
  String get chatSendFailed;

  /// No description provided for @chatUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get chatUnknownUser;

  /// No description provided for @chatAttachImage.
  ///
  /// In en, this message translates to:
  /// **'Attach image'**
  String get chatAttachImage;

  /// No description provided for @chatImageSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send image. Please try again.'**
  String get chatImageSendFailed;

  /// No description provided for @chatImageMessageFallback.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get chatImageMessageFallback;

  /// No description provided for @conversationPhotoMessage.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get conversationPhotoMessage;

  /// No description provided for @chatTypingIndicator.
  ///
  /// In en, this message translates to:
  /// **'{name} is typing...'**
  String chatTypingIndicator(String name);

  /// No description provided for @chatTypingFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get chatTypingFallbackName;

  /// No description provided for @chatMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get chatMessageSent;

  /// No description provided for @chatMessageRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get chatMessageRead;

  /// No description provided for @chatUnmatch.
  ///
  /// In en, this message translates to:
  /// **'Unmatch'**
  String get chatUnmatch;

  /// No description provided for @chatUnmatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Unmatch?'**
  String get chatUnmatchTitle;

  /// No description provided for @chatUnmatchBody.
  ///
  /// In en, this message translates to:
  /// **'You and {name} will no longer be able to message each other.'**
  String chatUnmatchBody(String name);

  /// No description provided for @chatUnmatchConfirm.
  ///
  /// In en, this message translates to:
  /// **'Unmatch'**
  String get chatUnmatchConfirm;

  /// No description provided for @chatUnmatchCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatUnmatchCancel;

  /// No description provided for @chatUnmatchSuccess.
  ///
  /// In en, this message translates to:
  /// **'Match removed.'**
  String get chatUnmatchSuccess;

  /// No description provided for @chatUnmatchFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t unmatch. Please try again.'**
  String get chatUnmatchFailed;

  /// No description provided for @notificationCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationCenterTitle;

  /// No description provided for @notificationCenterEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationCenterEmpty;

  /// No description provided for @notificationCenterLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load notifications.'**
  String get notificationCenterLoadError;

  /// No description provided for @notificationCenterMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationCenterMarkAllRead;

  /// No description provided for @notificationCenterMarkedAllRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read.'**
  String get notificationCenterMarkedAllRead;

  /// No description provided for @safetyBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get safetyBlockUser;

  /// No description provided for @safetyBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block this user?'**
  String get safetyBlockTitle;

  /// No description provided for @safetyBlockBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see each other, match, or message anymore.'**
  String get safetyBlockBody;

  /// No description provided for @safetyBlockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get safetyBlockConfirm;

  /// No description provided for @safetyBlockCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get safetyBlockCancel;

  /// No description provided for @safetyBlockSuccess.
  ///
  /// In en, this message translates to:
  /// **'User blocked.'**
  String get safetyBlockSuccess;

  /// No description provided for @safetyBlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t block user. Please try again.'**
  String get safetyBlockFailed;

  /// No description provided for @safetyCannotBlockSelf.
  ///
  /// In en, this message translates to:
  /// **'You can\'t block yourself.'**
  String get safetyCannotBlockSelf;

  /// No description provided for @safetyReportUser.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get safetyReportUser;

  /// No description provided for @safetyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this user?'**
  String get safetyReportTitle;

  /// No description provided for @safetyReportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get safetyReportReasonSpam;

  /// No description provided for @safetyReportReasonFakeProfile.
  ///
  /// In en, this message translates to:
  /// **'Fake profile'**
  String get safetyReportReasonFakeProfile;

  /// No description provided for @safetyReportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get safetyReportReasonHarassment;

  /// No description provided for @safetyReportReasonHateSpeech.
  ///
  /// In en, this message translates to:
  /// **'Hate speech'**
  String get safetyReportReasonHateSpeech;

  /// No description provided for @safetyReportReasonInappropriateContent.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get safetyReportReasonInappropriateContent;

  /// No description provided for @safetyReportDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add details, if you\'d like.'**
  String get safetyReportDescriptionHint;

  /// No description provided for @safetyReportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get safetyReportSubmit;

  /// No description provided for @safetyReportCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get safetyReportCancel;

  /// No description provided for @safetyReportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted.'**
  String get safetyReportSuccess;

  /// No description provided for @safetyReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t submit report. Please try again.'**
  String get safetyReportFailed;

  /// No description provided for @safetyCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Center'**
  String get safetyCenterTitle;

  /// No description provided for @safetyCenterDescription.
  ///
  /// In en, this message translates to:
  /// **'Control who can interact with you and review safety options.'**
  String get safetyCenterDescription;

  /// No description provided for @safetyBlockedUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get safetyBlockedUsersTitle;

  /// No description provided for @safetyBlockedUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t blocked anyone.'**
  String get safetyBlockedUsersEmpty;

  /// No description provided for @safetyBlockedUserFallback.
  ///
  /// In en, this message translates to:
  /// **'Blocked user'**
  String get safetyBlockedUserFallback;

  /// No description provided for @safetyUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get safetyUnblock;

  /// No description provided for @safetyUnblockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock this user?'**
  String get safetyUnblockTitle;

  /// No description provided for @safetyUnblockBody.
  ///
  /// In en, this message translates to:
  /// **'They may be able to find or interact with you again.'**
  String get safetyUnblockBody;

  /// No description provided for @safetyUnblockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get safetyUnblockConfirm;

  /// No description provided for @safetyUnblockCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get safetyUnblockCancel;

  /// No description provided for @safetyUnblockSuccess.
  ///
  /// In en, this message translates to:
  /// **'User unblocked.'**
  String get safetyUnblockSuccess;

  /// No description provided for @safetyUnblockFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t unblock user. Please try again.'**
  String get safetyUnblockFailed;

  /// No description provided for @safetyTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety tips'**
  String get safetyTipsTitle;

  /// No description provided for @safetyTipFinancialInfo.
  ///
  /// In en, this message translates to:
  /// **'Don\'t share financial or personal information.'**
  String get safetyTipFinancialInfo;

  /// No description provided for @safetyTipPublicPlace.
  ///
  /// In en, this message translates to:
  /// **'Choose a public place for your first meeting.'**
  String get safetyTipPublicPlace;

  /// No description provided for @safetyTipReportSuspicious.
  ///
  /// In en, this message translates to:
  /// **'Report any suspicious behavior.'**
  String get safetyTipReportSuspicious;

  /// No description provided for @safetyTipBlockUncomfortable.
  ///
  /// In en, this message translates to:
  /// **'Block anyone who makes you feel uncomfortable.'**
  String get safetyTipBlockUncomfortable;

  /// No description provided for @safetyTipTrustInstincts.
  ///
  /// In en, this message translates to:
  /// **'Trust your instincts.'**
  String get safetyTipTrustInstincts;

  /// No description provided for @safetyReportInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About reports'**
  String get safetyReportInfoTitle;

  /// No description provided for @safetyReportInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Reports are reviewed by the team. The reported user won\'t be notified.'**
  String get safetyReportInfoBody;

  /// No description provided for @safetyBlockInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About blocking'**
  String get safetyBlockInfoTitle;

  /// No description provided for @safetyBlockInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Blocking prevents discovery, matching, and messaging.'**
  String get safetyBlockInfoBody;

  /// No description provided for @profileSafetyTile.
  ///
  /// In en, this message translates to:
  /// **'Safety Center'**
  String get profileSafetyTile;

  /// No description provided for @profileSafetySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage blocked users and safety options'**
  String get profileSafetySubtitle;

  /// No description provided for @verificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationTitle;

  /// No description provided for @verificationProfileTile.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationProfileTile;

  /// No description provided for @verificationProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your profile photo'**
  String get verificationProfileSubtitle;

  /// No description provided for @photoVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Verification'**
  String get photoVerificationTitle;

  /// No description provided for @photoVerificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Photo verification helps build trust in the Bloom community.'**
  String get photoVerificationDescription;

  /// No description provided for @photoVerificationPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your verification photo is used only for review and is not shown on your profile.'**
  String get photoVerificationPrivacyNote;

  /// No description provided for @photoVerificationPickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get photoVerificationPickPhoto;

  /// No description provided for @photoVerificationChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get photoVerificationChangePhoto;

  /// No description provided for @photoVerificationSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Verification Request'**
  String get photoVerificationSubmit;

  /// No description provided for @photoVerificationSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get photoVerificationSubmitting;

  /// No description provided for @photoVerificationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Verification request submitted.'**
  String get photoVerificationSubmitted;

  /// No description provided for @photoVerificationPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get photoVerificationPendingTitle;

  /// No description provided for @photoVerificationPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your verification request is under review.'**
  String get photoVerificationPendingBody;

  /// No description provided for @photoVerificationApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get photoVerificationApprovedTitle;

  /// No description provided for @photoVerificationApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your photo verification is complete.'**
  String get photoVerificationApprovedBody;

  /// No description provided for @photoVerificationRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Declined'**
  String get photoVerificationRejectedTitle;

  /// No description provided for @photoVerificationRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Please review the feedback and resubmit.'**
  String get photoVerificationRejectedBody;

  /// No description provided for @photoVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t submit verification request. Please try again.'**
  String get photoVerificationFailed;

  /// No description provided for @photoVerificationImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a photo for verification.'**
  String get photoVerificationImageRequired;

  /// No description provided for @photoVerificationAlreadyPending.
  ///
  /// In en, this message translates to:
  /// **'You already have a pending verification request.'**
  String get photoVerificationAlreadyPending;

  /// No description provided for @verificationBadgePhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo Verified'**
  String get verificationBadgePhoto;

  /// No description provided for @verificationBadgeVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verificationBadgeVerified;

  /// No description provided for @verificationBadgePhotoSemantic.
  ///
  /// In en, this message translates to:
  /// **'Photo verified'**
  String get verificationBadgePhotoSemantic;

  /// No description provided for @verificationBadgeVerifiedSemantic.
  ///
  /// In en, this message translates to:
  /// **'Identity verified'**
  String get verificationBadgeVerifiedSemantic;

  /// No description provided for @verificationManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Requests'**
  String get verificationManagementTitle;

  /// No description provided for @verificationManagementAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Admin access required.'**
  String get verificationManagementAccessDenied;

  /// No description provided for @verificationManagementLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load verification requests. Please try again.'**
  String get verificationManagementLoadFailed;

  /// No description provided for @verificationManagementEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending verification requests.'**
  String get verificationManagementEmpty;

  /// No description provided for @verificationManagementPhotoOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing photo verification requests only.'**
  String get verificationManagementPhotoOnlyNotice;

  /// No description provided for @verificationManagementApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved.'**
  String get verificationManagementApproved;

  /// No description provided for @verificationManagementRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected.'**
  String get verificationManagementRejected;

  /// No description provided for @verificationManagementActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed. Please try again.'**
  String get verificationManagementActionFailed;

  /// No description provided for @verificationManagementApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve verification?'**
  String get verificationManagementApproveTitle;

  /// No description provided for @verificationManagementApproveBody.
  ///
  /// In en, this message translates to:
  /// **'This will approve the photo verification request.'**
  String get verificationManagementApproveBody;

  /// No description provided for @verificationManagementApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get verificationManagementApprove;

  /// No description provided for @verificationManagementImageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get verificationManagementImageLoadFailed;

  /// No description provided for @verificationManagementReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get verificationManagementReject;

  /// No description provided for @verificationManagementRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject verification?'**
  String get verificationManagementRejectTitle;

  /// No description provided for @verificationManagementRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter rejection reason…'**
  String get verificationManagementRejectReasonHint;

  /// No description provided for @verificationManagementRejectReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a rejection reason.'**
  String get verificationManagementRejectReasonRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
