import '../../domain/repositories/online_status_repository.dart';
import '../datasources/online_status_remote_data_source.dart';

class OnlineStatusRepositoryImpl implements OnlineStatusRepository {
  final OnlineStatusRemoteDataSource _remoteDataSource;

  OnlineStatusRepositoryImpl({OnlineStatusRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? OnlineStatusRemoteDataSource();

  @override
  Future<bool> updateOnlineStatus({
    required String userId,
    required bool isOnline,
    DateTime? lastActive,
  }) async {
    return await _remoteDataSource.updateOnlineStatus(
      userId: userId,
      isOnline: isOnline,
      lastActive: lastActive,
    );
  }

  @override
  Future<Map<String, dynamic>?> getUserOnlineStatus(String userId) async {
    return await _remoteDataSource.getUserOnlineStatus(userId);
  }

  @override
  Stream<Map<String, dynamic>?> streamUserOnlineStatus(String userId) {
    return _remoteDataSource.streamUserOnlineStatus(userId);
  }

  @override
  Future<bool> setUserOnline(String userId) async {
    return await _remoteDataSource.setUserOnline(userId);
  }

  @override
  Future<bool> setUserOffline(String userId) async {
    return await _remoteDataSource.setUserOffline(userId);
  }
}
