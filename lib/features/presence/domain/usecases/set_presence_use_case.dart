import '../repositories/presence_repository.dart';

class SetPresenceUseCase {
  const SetPresenceUseCase(this._repository);

  final PresenceRepository _repository;

  Future<void> setOnline(String userId) async {
    if (userId.trim().isEmpty) return;
    try {
      await _repository.setOnline(userId);
    } catch (_) {}
  }

  Future<void> setOffline(String userId) async {
    if (userId.trim().isEmpty) return;
    try {
      await _repository.setOffline(userId);
    } catch (_) {}
  }

  Future<void> setupOnDisconnect(String userId) async {
    if (userId.trim().isEmpty) return;
    try {
      await _repository.setupOnDisconnect(userId);
    } catch (_) {}
  }

  Future<void> cancelOnDisconnect(String userId) async {
    if (userId.trim().isEmpty) return;
    try {
      await _repository.cancelOnDisconnect(userId);
    } catch (_) {}
  }
}
