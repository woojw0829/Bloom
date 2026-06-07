import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/typing_repository_impl.dart';
import '../../domain/repositories/typing_repository.dart';
import '../../domain/usecases/set_typing_use_case.dart';
import '../../domain/usecases/watch_typing_use_case.dart';

final typingRepositoryProvider = Provider<TypingRepository>(
  (ref) => TypingRepositoryImpl(),
);

final setTypingUseCaseProvider = Provider<SetTypingUseCase>(
  (ref) => SetTypingUseCase(ref.watch(typingRepositoryProvider)),
);

final watchTypingUseCaseProvider = Provider<WatchTypingUseCase>(
  (ref) => WatchTypingUseCase(ref.watch(typingRepositoryProvider)),
);

/// Emits true when a user other than [currentUserId] is typing in [matchId].
final otherUserTypingProvider = StreamProvider.autoDispose
    .family<bool, ({String matchId, String currentUserId})>(
  (ref, args) {
    if (args.matchId.isEmpty || args.currentUserId.isEmpty) {
      return Stream.value(false);
    }
    return ref.watch(watchTypingUseCaseProvider).execute(
          matchId: args.matchId,
          currentUserId: args.currentUserId,
        );
  },
);
