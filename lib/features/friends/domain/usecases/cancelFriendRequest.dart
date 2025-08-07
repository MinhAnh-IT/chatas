import '../repositories/friend_repository.dart';

class CancelFriendRequest {
  final FriendRepository repository;

  CancelFriendRequest(this.repository);

  Future<void> call(String senderId, String receiverId) async {
    return await repository.cancelFriendRequest(senderId, receiverId);
  }
}
