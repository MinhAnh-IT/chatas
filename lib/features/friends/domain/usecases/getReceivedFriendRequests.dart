import '../entities/friendRequest.dart';
import '../repositories/friend_repository.dart';

class GetReceivedFriendRequests {
  final FriendRepository repository;

  GetReceivedFriendRequests(this.repository);

  Future<List<FriendRequest>> call(String userId) async {
    return await repository.getReceivedFriendRequests(userId);
  }
}
