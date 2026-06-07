import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/models/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/mark_all_notifications_read_use_case.dart';
import '../../domain/usecases/mark_notification_read_use_case.dart';
import '../../domain/usecases/watch_notifications_use_case.dart';
import '../../domain/usecases/watch_unread_notification_count_use_case.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (_) => NotificationRepositoryImpl(),
);

final watchNotificationsUseCaseProvider = Provider<WatchNotificationsUseCase>(
  (ref) =>
      WatchNotificationsUseCase(ref.watch(notificationRepositoryProvider)),
);

final watchUnreadNotificationCountUseCaseProvider =
    Provider<WatchUnreadNotificationCountUseCase>(
  (ref) => WatchUnreadNotificationCountUseCase(
    ref.watch(notificationRepositoryProvider),
  ),
);

final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>(
  (ref) =>
      MarkNotificationReadUseCase(ref.watch(notificationRepositoryProvider)),
);

final markAllNotificationsReadUseCaseProvider =
    Provider<MarkAllNotificationsReadUseCase>(
  (ref) => MarkAllNotificationsReadUseCase(
    ref.watch(notificationRepositoryProvider),
  ),
);

/// Streams notifications for an explicit userId. Used by Task 10.4 UI.
final notificationsProvider =
    StreamProvider.autoDispose.family<List<AppNotification>, String>(
  (ref, userId) => ref
      .watch(watchNotificationsUseCaseProvider)
      .execute(userId: userId),
);

/// Streams unread notification count for an explicit userId.
final unreadNotificationCountProvider =
    StreamProvider.autoDispose.family<int, String>(
  (ref, userId) => ref
      .watch(watchUnreadNotificationCountUseCaseProvider)
      .execute(userId: userId),
);

/// Convenience provider — notifications for the currently authenticated user.
final currentUserNotificationsProvider =
    StreamProvider.autoDispose<List<AppNotification>>(
  (ref) {
    final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;
    if (uid == null) return Stream.value(const []);
    return ref.watch(watchNotificationsUseCaseProvider).execute(userId: uid);
  },
);

/// Convenience provider — unread count for the currently authenticated user.
final currentUserUnreadNotificationCountProvider =
    StreamProvider.autoDispose<int>(
  (ref) {
    final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid;
    if (uid == null) return Stream.value(0);
    return ref
        .watch(watchUnreadNotificationCountUseCaseProvider)
        .execute(userId: uid);
  },
);
