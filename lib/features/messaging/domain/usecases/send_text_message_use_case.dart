import '../repositories/message_repository.dart';

const int kMaxMessageLength = 1000;

sealed class SendTextMessageResult {
  const SendTextMessageResult();
}

final class SendTextMessageSuccess extends SendTextMessageResult {
  const SendTextMessageSuccess();
}

final class SendTextMessageValidationError extends SendTextMessageResult {
  const SendTextMessageValidationError(this.message);
  final String message;
}

final class SendTextMessageFailure extends SendTextMessageResult {
  const SendTextMessageFailure(this.error);
  final Object error;
}

class SendTextMessageUseCase {
  const SendTextMessageUseCase(this._repository);

  final MessageRepository _repository;

  Future<SendTextMessageResult> execute({
    required String matchId,
    required String senderId,
    required String content,
  }) async {
    if (matchId.trim().isEmpty) {
      return const SendTextMessageValidationError('Match ID is required.');
    }
    if (senderId.trim().isEmpty) {
      return const SendTextMessageValidationError('Sender ID is required.');
    }
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return const SendTextMessageValidationError('Message cannot be empty.');
    }
    if (trimmed.length > kMaxMessageLength) {
      return const SendTextMessageValidationError('Message is too long.');
    }
    try {
      await _repository.sendTextMessage(
        matchId: matchId,
        senderId: senderId,
        content: trimmed,
      );
      return const SendTextMessageSuccess();
    } catch (e) {
      return SendTextMessageFailure(e);
    }
  }
}
