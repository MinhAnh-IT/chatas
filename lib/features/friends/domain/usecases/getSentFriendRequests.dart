import '../entities/friendRequest.dart';
import '../repositories/friend_repository.dart';

class GetSentFriendRequests {
  final FriendRepository repository;

  GetSentFriendRequests(this.repository);

  Future<List<FriendRequest>> call(String userId) async {
    return await repository.getSentFriendRequests(userId);
  }
}
