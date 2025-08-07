import '../entities/auth_result.dart';
import '../entities/register_request.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthResult> call(RegisterRequest request) async {
    return await repository.register(request);
  }
}
