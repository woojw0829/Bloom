import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/app_notification.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_tile.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;
    final notificationsAsync = ref.watch(currentUserNotificationsProvider);
    final unreadCount =
        ref.watch(currentUserUnreadNotificationCountProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          l10n.notificationCenterTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        actions: [
          if (unreadCount > 0 && uid != null)
            TextButton(
              onPressed: () {
                ref
                    .read(markAllNotificationsReadUseCaseProvider)
                    .execute(userId: uid)
                    .ignore();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.notificationCenterMarkedAllRead),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                l10n.notificationCenterMarkAllRead,
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => _ErrorView(message: l10n.notificationCenterLoadError),
        data: (notifications) => notifications.isEmpty
            ? _EmptyView(message: l10n.notificationCenterEmpty)
            : _NotificationList(
                notifications: notifications,
                onTap: (notification) =>
                    _onTap(context, ref, notification, uid),
              ),
      ),
    );
  }

  void _onTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
    String? uid,
  ) {
    if (!notification.read && uid != null) {
      ref
          .read(markNotificationReadUseCaseProvider)
          .execute(userId: uid, notificationId: notification.id)
          .ignore();
    }
    _navigate(context, notification);
  }

  void _navigate(BuildContext context, AppNotification notification) {
    final refId = notification.referenceId;
    final refType = notification.referenceType;
    if (refId == null || refType == null) return;

    switch (refType) {
      case NotificationReferenceType.match:
      case NotificationReferenceType.message:
        context.push('/chat/$refId');
      case NotificationReferenceType.like:
      case NotificationReferenceType.verificationRequest:
        // No dedicated screen; notification is marked read above.
        break;
    }
  }
}

// ── Notification list ─────────────────────────────────────────────────────────

class _NotificationList extends StatelessWidget {
  const _NotificationList({
    required this.notifications,
    required this.onTap,
  });

  final List<AppNotification> notifications;
  final void Function(AppNotification) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: notifications.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        indent: AppSpacing.lg + 44 + AppSpacing.md,
        color: AppColors.divider,
      ),
      itemBuilder: (context, index) => NotificationTile(
        notification: notifications[index],
        onTap: () => onTap(notifications[index]),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
