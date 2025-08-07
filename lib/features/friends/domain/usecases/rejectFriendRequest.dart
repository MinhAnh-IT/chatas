import '../repositories/friend_repository.dart';

class RejectFriendRequest {
  final FriendRepository repository;

  RejectFriendRequest(this.repository);

  Future<void> call(String requestId) async {
    return await repository.rejectFriendRequest(requestId);
  }
}
