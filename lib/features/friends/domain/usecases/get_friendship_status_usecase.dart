import '../repositories/friend_repository.dart';

class GetFriendshipStatusUseCase {
  final FriendRepository repository;

  GetFriendshipStatusUseCase(this.repository);

  Future<String?> call(String userId, String otherUserId) async {
    return await repository.getFriendshipStatus(userId, otherUserId);
  }
}
