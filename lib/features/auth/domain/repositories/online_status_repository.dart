abstract class OnlineStatusRepository {
  Future<bool> updateOnlineStatus({
    required String userId,
    required bool isOnline,
    DateTime? lastActive,
  });

  Future<Map<String, dynamic>?> getUserOnlineStatus(String userId);

  Stream<Map<String, dynamic>?> streamUserOnlineStatus(String userId);

  Future<bool> setUserOnline(String userId);

  Future<bool> setUserOffline(String userId);

  Future<bool> cleanupUserOnlineStatus(String userId);
}
