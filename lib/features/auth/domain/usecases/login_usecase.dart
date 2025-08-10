import '../entities/auth_result.dart';
import '../entities/login_request.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResult> call(LoginRequest request) async {
    return await repository.login(request);
  }
}
