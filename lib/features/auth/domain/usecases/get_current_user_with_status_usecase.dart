import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting current user with online status information.
class GetCurrentUserWithStatusUseCase {
  final AuthRepository _repository;

  GetCurrentUserWithStatusUseCase({required AuthRepository repository})
    : _repository = repository;

  /// Gets the current authenticated user with their online status.
  /// Returns null if no user is authenticated or if there's an error.
  Future<User?> call() async {
    try {
      return await _repository.getCurrentUser();
    } catch (e) {
      return null;
    }
  }
}
