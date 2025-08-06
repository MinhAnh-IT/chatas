import '../entities/friendRequest.dart';
import '../repositories/friend_repository.dart';

class GetSentFriendRequestsUseCase {
  final FriendRepository repository;

  GetSentFriendRequestsUseCase(this.repository);

  Future<List<FriendRequest>> call(String userId) async {
    return await repository.getSentFriendRequests(userId);
  }
}
