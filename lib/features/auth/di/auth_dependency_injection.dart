// lib/features/auth/di/auth_dependency_injection.dart
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/register_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';

class AuthDependencyInjection {
  static AuthRepository? _authRepository;
  static AuthRemoteDataSource? _authRemoteDataSource;
  static RegisterUseCase? _registerUseCase;
  static LoginUseCase? _loginUseCase;
  static LogoutUseCase? _logoutUseCase;
  static GetCurrentUserUseCase? _getCurrentUserUseCase;

  static AuthRemoteDataSource get authRemoteDataSource {
    _authRemoteDataSource ??= AuthRemoteDataSource();
    return _authRemoteDataSource!;
  }

  static AuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );
    return _authRepository!;
  }

  static RegisterUseCase get registerUseCase {
    _registerUseCase ??= RegisterUseCase(authRepository);
    return _registerUseCase!;
  }

  static LoginUseCase get loginUseCase {
    _loginUseCase ??= LoginUseCase(authRepository);
    return _loginUseCase!;
  }

  static LogoutUseCase get logoutUseCase {
    _logoutUseCase ??= LogoutUseCase(authRepository);
    return _logoutUseCase!;
  }

  static GetCurrentUserUseCase get getCurrentUserUseCase {
    _getCurrentUserUseCase ??= GetCurrentUserUseCase(authRepository);
    return _getCurrentUserUseCase!;
  }

  static void dispose() {
    _authRepository = null;
    _authRemoteDataSource = null;
    _registerUseCase = null;
    _loginUseCase = null;
    _logoutUseCase = null;
    _getCurrentUserUseCase = null;
  }

  static void reset() {
    dispose();
  }
}