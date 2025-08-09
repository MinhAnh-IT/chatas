import '../../presentation/cubit/auth_cubit.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateOnlineStatusUseCase {
  final AuthRepository repository;

  UpdateOnlineStatusUseCase(this.repository);

  Future<bool> call({
    required String userId,
    required bool isOnline,
    DateTime? lastActive,
  }) async {
    try {
      final currentUser = await repository.getUserById(userId);
      if (currentUser == null) {
        return false;
      }

      final updatedUser = User(
        userId: currentUser.userId,
        isOnline: isOnline,
        lastActive: lastActive ?? DateTime.now(),
        fullName: currentUser.fullName,
        username: currentUser.username,
        email: currentUser.email,
        gender: currentUser.gender,
        birthDate: currentUser.birthDate,
        avatarUrl: currentUser.avatarUrl,
        createdAt: currentUser.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateUser(updatedUser);
      return result is AuthSuccess;
    } catch (e) {
      return false;
    }
  }
}
