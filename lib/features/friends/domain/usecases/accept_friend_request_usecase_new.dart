import '../repositories/friend_repository.dart';

class AcceptFriendRequestUseCase {
  final FriendRepository repository;

  AcceptFriendRequestUseCase(this.repository);

  Future<void> call(String requestId) async {
    return await repository.acceptFriendRequest(requestId);
  }
}
