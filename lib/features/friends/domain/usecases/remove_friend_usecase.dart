import '../repositories/friend_repository.dart';

class RemoveFriendUseCase {
  final FriendRepository repository;

  RemoveFriendUseCase(this.repository);

  Future<void> call(String userId, String friendId) async {
    return await repository.removeFriend(userId, friendId);
  }
}
