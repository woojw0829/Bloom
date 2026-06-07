import '../repositories/message_repository.dart';

sealed class SendImageMessageResult {
  const SendImageMessageResult();
}

final class SendImageMessageSuccess extends SendImageMessageResult {
  const SendImageMessageSuccess();
}

final class SendImageMessageValidationError extends SendImageMessageResult {
  const SendImageMessageValidationError(this.message);
  final String message;
}

final class SendImageMessageFailure extends SendImageMessageResult {
  const SendImageMessageFailure(this.error);
  final Object error;
}

class SendImageMessageUseCase {
  const SendImageMessageUseCase(this._repository);

  final MessageRepository _repository;

  Future<SendImageMessageResult> execute({
    required String matchId,
    required String senderId,
    required String imageFilePath,
  }) async {
    if (matchId.trim().isEmpty) {
      return const SendImageMessageValidationError('Match ID is required.');
    }
    if (senderId.trim().isEmpty) {
      return const SendImageMessageValidationError('Sender ID is required.');
    }
    if (imageFilePath.trim().isEmpty) {
      return const SendImageMessageValidationError('Image file path is required.');
    }
    try {
      await _repository.sendImageMessage(
        matchId: matchId,
        senderId: senderId,
        imageFilePath: imageFilePath,
      );
      return const SendImageMessageSuccess();
    } catch (e) {
      return SendImageMessageFailure(e);
    }
  }
}
