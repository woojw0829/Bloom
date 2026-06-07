import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/message_repository_impl.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/usecases/mark_messages_read_use_case.dart';
import '../../domain/usecases/send_image_message_use_case.dart';
import '../../domain/usecases/send_text_message_use_case.dart';

final messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepositoryImpl(),
);

final chatMessagesProvider =
    StreamProvider.autoDispose.family<List<ChatMessage>, String>(
  (ref, matchId) {
    if (matchId.isEmpty) return Stream.value(const []);
    return ref.watch(messageRepositoryProvider).watchMessages(matchId: matchId);
  },
);

final sendTextMessageUseCaseProvider = Provider<SendTextMessageUseCase>(
  (ref) => SendTextMessageUseCase(ref.watch(messageRepositoryProvider)),
);

final sendImageMessageUseCaseProvider = Provider<SendImageMessageUseCase>(
  (ref) => SendImageMessageUseCase(ref.watch(messageRepositoryProvider)),
);

final markMessagesReadUseCaseProvider = Provider<MarkMessagesReadUseCase>(
  (ref) => MarkMessagesReadUseCase(ref.watch(messageRepositoryProvider)),
);
