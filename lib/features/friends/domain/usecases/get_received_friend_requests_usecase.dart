import '../entities/friendRequest.dart';
import '../repositories/friend_repository.dart';

class GetReceivedFriendRequestsUseCase {
  final FriendRepository repository;

  GetReceivedFriendRequestsUseCase(this.repository);

  Future<List<FriendRequest>> call(String userId) async {
    return await repository.getReceivedFriendRequests(userId);
  }
}
