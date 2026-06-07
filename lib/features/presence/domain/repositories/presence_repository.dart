abstract class PresenceRepository {
  Future<void> setOnline(String userId);
  Future<void> setOffline(String userId);
  Future<void> setupOnDisconnect(String userId);
  Future<void> cancelOnDisconnect(String userId);
}
