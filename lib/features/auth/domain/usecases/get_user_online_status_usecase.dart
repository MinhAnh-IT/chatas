import '../repositories/auth_repository.dart';

class GetUserOnlineStatusUseCase {
  final AuthRepository repository;

  GetUserOnlineStatusUseCase(this.repository);

  Future<Map<String, dynamic>?> call(String userId) async {
    try {
      final user = await repository.getUserById(userId);
      if (user == null) {
        return null;
      }

      return {
        'isOnline': user.isOnline,
        'lastActive': user.lastActive,
        'userId': user.userId,
        'fullName': user.fullName,
        'username': user.username,
        'avatarUrl': user.avatarUrl,
      };
    } catch (e) {
      return null;
    }
  }
}
