import '../repositories/friend_repository.dart';

class UpdateFriendOnlineStatusUseCase {
  final FriendRepository repository;

  UpdateFriendOnlineStatusUseCase(this.repository);

  Future<void> call(String userId, bool isOnline) async {
    return await repository.updateFriendOnlineStatus(userId, isOnline);
  }
}
