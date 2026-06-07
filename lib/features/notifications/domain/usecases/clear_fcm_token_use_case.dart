import '../repositories/fcm_token_repository.dart';

class ClearFcmTokenUseCase {
  const ClearFcmTokenUseCase(this._repository);

  final FcmTokenRepository _repository;

  Future<void> execute({required String userId}) async {
    if (userId.trim().isEmpty) return;
    try {
      await _repository.clearToken(userId);
    } catch (_) {}
  }
}
