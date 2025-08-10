import '../data/datasources/online_status_remote_data_source.dart';
import '../data/repositories/online_status_repository_impl.dart';
import '../domain/repositories/online_status_repository.dart';
import '../domain/usecases/online_status_usecases.dart';

class OnlineStatusDependencyInjection {
  static OnlineStatusRepository? _onlineStatusRepository;
  static OnlineStatusRemoteDataSource? _onlineStatusRemoteDataSource;
  static SetUserOnlineUseCase? _setUserOnlineUseCase;
  static SetUserOfflineUseCase? _setUserOfflineUseCase;
  static GetUserOnlineStatusUseCase? _getUserOnlineStatusUseCase;
  static StreamUserOnlineStatusUseCase? _streamUserOnlineStatusUseCase;
  static CleanupUserOnlineStatusUseCase? _cleanupUserOnlineStatusUseCase;

  static OnlineStatusRemoteDataSource get onlineStatusRemoteDataSource {
    _onlineStatusRemoteDataSource ??= OnlineStatusRemoteDataSource();
    return _onlineStatusRemoteDataSource!;
  }

  static OnlineStatusRepository get onlineStatusRepository {
    _onlineStatusRepository ??= OnlineStatusRepositoryImpl(
      remoteDataSource: onlineStatusRemoteDataSource,
    );
    return _onlineStatusRepository!;
  }

  static SetUserOnlineUseCase get setUserOnlineUseCase {
    _setUserOnlineUseCase ??= SetUserOnlineUseCase(onlineStatusRepository);
    return _setUserOnlineUseCase!;
  }

  static SetUserOfflineUseCase get setUserOfflineUseCase {
    _setUserOfflineUseCase ??= SetUserOfflineUseCase(onlineStatusRepository);
    return _setUserOfflineUseCase!;
  }

  static GetUserOnlineStatusUseCase get getUserOnlineStatusUseCase {
    _getUserOnlineStatusUseCase ??= GetUserOnlineStatusUseCase(
      onlineStatusRepository,
    );
    return _getUserOnlineStatusUseCase!;
  }

  static StreamUserOnlineStatusUseCase get streamUserOnlineStatusUseCase {
    _streamUserOnlineStatusUseCase ??= StreamUserOnlineStatusUseCase(
      onlineStatusRepository,
    );
    return _streamUserOnlineStatusUseCase!;
  }

  static CleanupUserOnlineStatusUseCase get cleanupUserOnlineStatusUseCase {
    _cleanupUserOnlineStatusUseCase ??= CleanupUserOnlineStatusUseCase(
      onlineStatusRepository,
    );
    return _cleanupUserOnlineStatusUseCase!;
  }

  static void dispose() {
    _onlineStatusRepository = null;
    _onlineStatusRemoteDataSource = null;
    _setUserOnlineUseCase = null;
    _setUserOfflineUseCase = null;
    _getUserOnlineStatusUseCase = null;
    _streamUserOnlineStatusUseCase = null;
    _cleanupUserOnlineStatusUseCase = null;
  }

  static void reset() {
    dispose();
  }
}
