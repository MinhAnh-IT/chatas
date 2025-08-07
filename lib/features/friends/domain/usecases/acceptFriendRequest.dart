import '../repositories/friend_repository.dart';

class AcceptFriendRequest {
  final FriendRepository repository;

  AcceptFriendRequest(this.repository);

  Future<void> call(
    String requestId,
    String senderId,
    String receiverId,
  ) async {
    return await repository.acceptFriendRequest(
      requestId,
      senderId,
      receiverId,
    );
  }
}
