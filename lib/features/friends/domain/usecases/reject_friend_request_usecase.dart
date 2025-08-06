import '../repositories/friend_repository.dart';

class RejectFriendRequestUseCase {
  final FriendRepository repository;

  RejectFriendRequestUseCase(this.repository);

  Future<void> call(String requestId) async {
    return await repository.rejectFriendRequest(requestId);
  }
}
