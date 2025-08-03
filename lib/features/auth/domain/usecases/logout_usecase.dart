import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<AuthResult> call() async {
    return await repository.logout();
  }
} 