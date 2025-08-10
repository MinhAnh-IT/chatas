import '../entities/friend.dart';
import '../repositories/friend_repository.dart';

class GetFriendsUseCase {
  final FriendRepository repository;

  GetFriendsUseCase(this.repository);

  Future<List<Friend>> call(String userId) async {
    return await repository.getFriends(userId);
  }
}
