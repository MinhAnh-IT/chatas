import '../repositories/online_status_repository.dart';

class SetUserOnlineUseCase {
  final OnlineStatusRepository repository;

  SetUserOnlineUseCase(this.repository);

  Future<bool> call(String userId) async {
    return await repository.setUserOnline(userId);
  }
}

class SetUserOfflineUseCase {
  final OnlineStatusRepository repository;

  SetUserOfflineUseCase(this.repository);

  Future<bool> call(String userId) async {
    return await repository.setUserOffline(userId);
  }
}

class GetUserOnlineStatusUseCase {
  final OnlineStatusRepository repository;

  GetUserOnlineStatusUseCase(this.repository);

  Future<Map<String, dynamic>?> call(String userId) async {
    return await repository.getUserOnlineStatus(userId);
  }
}

class StreamUserOnlineStatusUseCase {
  final OnlineStatusRepository repository;

  StreamUserOnlineStatusUseCase(this.repository);

  Stream<Map<String, dynamic>?> call(String userId) {
    return repository.streamUserOnlineStatus(userId);
  }
}

class CleanupUserOnlineStatusUseCase {
  final OnlineStatusRepository repository;

  CleanupUserOnlineStatusUseCase(this.repository);

  Future<bool> call(String userId) async {
    return await repository.cleanupUserOnlineStatus(userId);
  }
}
