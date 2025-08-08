import '../repositories/friend_repository.dart';

class BlockFriendUseCase {
  final FriendRepository repository;

  BlockFriendUseCase(this.repository);

  /// Block/Unblock bạn bè
  /// Input: currentUserId, friendId, isBlock - true để block, false để unblock
  Future<void> call(String currentUserId, String friendId, bool isBlock) async {
    if (currentUserId.isEmpty || friendId.isEmpty) {
      throw ArgumentError('User ID và Friend ID không được để trống');
    }

    if (currentUserId == friendId) {
      throw ArgumentError('Không thể block chính mình');
    }

    await repository.updateBlockStatus(currentUserId, friendId, isBlock);
  }
}
