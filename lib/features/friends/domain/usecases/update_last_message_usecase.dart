import '../repositories/friend_repository.dart';

class UpdateLastMessageUseCase {
  final FriendRepository repository;

  UpdateLastMessageUseCase(this.repository);

  Future<void> call(
    String friendId,
    String messageId,
    DateTime timestamp,
  ) async {
    return await repository.updateLastMessage(friendId, messageId, timestamp);
  }
}
