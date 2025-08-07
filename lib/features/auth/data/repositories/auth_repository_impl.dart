import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/entities/user.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource();

  @override
  Future<AuthResult> register(RegisterRequest request) async {
    return await _remoteDataSource.register(request);
  }

  @override
  Future<AuthResult> login(LoginRequest request) async {
    return await _remoteDataSource.login(request);
  }

  @override
  Future<AuthResult> logout() async {
    return await _remoteDataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _remoteDataSource.isLoggedIn();
  }

  @override
  Future<User?> getUserById(String userId) async {
    return await _remoteDataSource.getUserById(userId);
  }

  @override
  Future<AuthResult> updateUser(User user) async {
    return await _remoteDataSource.updateUser(user);
  }

  @override
  Future<AuthResult> deleteAccount() async {
    return await _remoteDataSource.deleteAccount();
  }
}
