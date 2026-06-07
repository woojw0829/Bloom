import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/router_notifier.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/explore/presentation/screens/browse_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/explore/presentation/screens/map_discovery_screen.dart';
import '../../features/home/presentation/screens/home_shell.dart';
import '../../features/location/presentation/screens/location_permission_screen.dart';
import '../../features/messaging/domain/models/conversation_preview.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';
import '../../features/messaging/presentation/screens/conversation_list_screen.dart';
import '../../features/notifications/presentation/screens/notification_center_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/language_settings_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/profile/presentation/screens/privacy_settings_screen.dart';
import '../../features/profile/presentation/screens/profile_photo_management_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/safety/presentation/screens/safety_center_screen.dart';

// ── Route path constants ──────────────────────────────────────────────────────

abstract final class AppRoutes {
  static const String splash         = '/';
  static const String login          = '/login';
  static const String register       = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding     = '/onboarding';
  // Main app shell branches (each is the root of a StatefulShellBranch)
  static const String explore        = '/explore';
  static const String browse         = '/browse';
  static const String chat           = '/chat';
  static const String notifications  = '/notifications';
  static const String profile        = '/profile';
  static const String profileEdit    = '/profile/edit';
  static const String profilePhotos   = '/profile/photos';
  static const String profilePrivacy               = '/profile/privacy';
  static const String profileNotificationSettings  = '/profile/notification-settings';
  static const String profileLocation              = '/profile/location';
  static const String profileLanguage              = '/profile/language';
  static const String profileSafety               = '/profile/safety';
  static const String exploreMap                   = '/explore/map';
  static const String chatDetail                   = '/chat/:matchId';
}

// ── Router provider ───────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      // Full-screen map — pushed on top of the shell, no bottom nav shown.
      GoRoute(
        path: AppRoutes.exploreMap,
        builder: (_, _) => const MapDiscoveryScreen(),
      ),
      // Full-screen chat detail — pushed on top of the shell, no bottom nav shown.
      GoRoute(
        path: AppRoutes.chatDetail,
        builder: (context, state) {
          final matchId = state.pathParameters['matchId']!;
          final preview = state.extra as ConversationPreview?;
          return ChatScreen(matchId: matchId, preview: preview);
        },
      ),

      // ── Authenticated shell ─────────────────────────────────────────────────
      // StatefulShellRoute preserves each branch's navigation stack across
      // tab switches. HomeShell owns the BottomNavigationBar.
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (_, _) => const ExploreScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.browse,
              builder: (_, _) => const BrowseScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.chat,
              builder: (_, _) => const ConversationListScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.notifications,
              builder: (_, _) => const NotificationCenterScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, _) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, _) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'photos',
                  builder: (_, _) => const ProfilePhotoManagementScreen(),
                ),
                GoRoute(
                  path: 'privacy',
                  builder: (_, _) => const PrivacySettingsScreen(),
                ),
                GoRoute(
                  path: 'notification-settings',
                  builder: (_, _) => const NotificationSettingsScreen(),
                ),
                GoRoute(
                  path: 'location',
                  builder: (_, _) => const LocationPermissionScreen(),
                ),
                GoRoute(
                  path: 'language',
                  builder: (_, _) => const LanguageSettingsScreen(),
                ),
                GoRoute(
                  path: 'safety',
                  builder: (_, _) => const SafetyCenterScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
