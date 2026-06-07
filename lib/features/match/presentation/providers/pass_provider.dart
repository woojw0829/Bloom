import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/profile_providers.dart';
import '../../data/repositories/pass_repository_impl.dart';
import '../../domain/repositories/pass_repository.dart';
import '../../domain/usecases/load_passed_user_ids_use_case.dart';

final passRepositoryProvider = Provider<PassRepository>(
  (_) => PassRepositoryImpl(),
);

/// Tracks the set of user IDs that the current user has passed on.
///
/// Loaded from Firestore on build and updated in-memory immediately on each
/// pass action, so new passes are excluded from subsequent discovery loads
/// in the same session without requiring a full reload.
final passedUserIdsNotifierProvider =
    NotifierProvider<PassedUserIdsNotifier, Set<String>>(
  PassedUserIdsNotifier.new,
);

class PassedUserIdsNotifier extends Notifier<Set<String>> {
  var _disposed = false;

  @override
  Set<String> build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    // Rebuild (and reload from Firestore) when the authenticated user changes.
    ref.watch(currentUserProvider.select((a) => a.valueOrNull?.id));

    Future.microtask(_load);
    return const {};
  }

  Future<void> _load() async {
    final userId = ref.read(currentUserProvider).valueOrNull?.id;
    if (userId == null || userId.isEmpty || _disposed) return;

    final ids = await LoadPassedUserIdsUseCase(
      repository: ref.read(passRepositoryProvider),
    ).call(userId);

    if (_disposed) return;
    state = ids;
  }

  /// Adds [id] to the in-memory set immediately.
  /// Called synchronously before the Firestore write so the profile is
  /// excluded from the next discovery load in the same session.
  void addId(String id) {
    if (id.isEmpty) return;
    state = {...state, id};
  }
}
