import '../repositories/fcm_token_repository.dart';

class RegisterFcmTokenUseCase {
  const RegisterFcmTokenUseCase(this._repository);

  final FcmTokenRepository _repository;

  Future<void> execute({
    required String userId,
    required String token,
  }) async {
    if (userId.trim().isEmpty) return;
    if (token.trim().isEmpty) return;
    try {
      await _repository.saveToken(userId, token);
    } catch (_) {}
  }
}
