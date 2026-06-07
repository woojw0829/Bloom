abstract class FcmTokenRepository {
  Future<void> requestPermission();
  Future<String?> getToken();
  Stream<String> watchTokenRefresh();
  Future<void> saveToken(String userId, String token);
  Future<void> clearToken(String userId);
}
