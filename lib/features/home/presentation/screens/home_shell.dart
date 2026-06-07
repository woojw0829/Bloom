import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';

/// Returns the badge label for a given unread notification count.
/// Returns empty string when count is zero (badge hidden).
/// [badgeLabelForCount] is package-visible for testing.
String badgeLabelForCount(int count) {
  if (count <= 0) return '';
  return count > 99 ? '99+' : '$count';
}

/// Persistent shell that owns the bottom navigation bar.
/// Each tab is a [StatefulShellBranch] in GoRouter; navigation state is
/// preserved across tab switches via [StatefulShellRoute.indexedStack].
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount =
        ref.watch(currentUserUnreadNotificationCountProvider).valueOrNull ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BloomBottomNav(
        currentIndex: navigationShell.currentIndex,
        unreadNotificationCount: unreadCount,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Tapping the active tab re-navigates to its initial route,
          // which allows nested navigators to pop back to root.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _BloomBottomNav extends StatelessWidget {
  const _BloomBottomNav({
    required this.currentIndex,
    required this.unreadNotificationCount,
    required this.onTap,
  });

  final int currentIndex;
  final int unreadNotificationCount;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final showBadge = unreadNotificationCount > 0;
    final badgeLabel = badgeLabelForCount(unreadNotificationCount);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.bottomNav,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.navActive,
        unselectedItemColor: AppColors.navInactive,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Browse',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: showBadge,
              label: Text(badgeLabel),
              backgroundColor: AppColors.primary,
              textColor: AppColors.textOnPrimary,
              child: const Icon(Icons.notifications_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: showBadge,
              label: Text(badgeLabel),
              backgroundColor: AppColors.primary,
              textColor: AppColors.textOnPrimary,
              child: const Icon(Icons.notifications_rounded),
            ),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
