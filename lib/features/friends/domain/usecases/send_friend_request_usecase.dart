import '../repositories/friend_repository.dart';
import '../entities/friendRequest.dart';

class SendFriendRequestUseCase {
  final FriendRepository repository;

  SendFriendRequestUseCase(this.repository);

  Future<void> call(FriendRequest friendRequest) async {
    return await repository.sendFriendRequest(friendRequest);
  }
}
