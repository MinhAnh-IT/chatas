import '../repositories/friend_repository.dart';

class CancelFriendRequestUseCase {
  final FriendRepository repository;

  CancelFriendRequestUseCase(this.repository);

  Future<void> call(String requestId) async {
    return await repository.cancelFriendRequest(requestId);
  }
}
