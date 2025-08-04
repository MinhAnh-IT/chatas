import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/register_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';

class AuthDependencyInjection {
  static AuthRepository get authRepository {
    return AuthRepositoryImpl();
  }

  static AuthRemoteDataSource get authRemoteDataSource {
    return AuthRemoteDataSource();
  }

  static RegisterUseCase get registerUseCase {
    return RegisterUseCase(authRepository);
  }

  static LoginUseCase get loginUseCase {
    return LoginUseCase(authRepository);
  }

  static LogoutUseCase get logoutUseCase {
    return LogoutUseCase(authRepository);
  }

  static GetCurrentUserUseCase get getCurrentUserUseCase {
    return GetCurrentUserUseCase(authRepository);
  }
} 