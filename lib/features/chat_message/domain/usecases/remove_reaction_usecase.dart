import '../repositories/chat_message_repository.dart';

/// UseCase for removing a reaction from a chat message.
/// Handles the business logic for reaction removal.
class RemoveReactionUseCase {
  final ChatMessageRepository _repository;

  const RemoveReactionUseCase({required ChatMessageRepository repository})
    : _repository = repository;

  /// Removes a user's reaction from the specified message.
  ///
  /// [messageId] The ID of the message to remove reaction from
  /// [userId] The ID of the user whose reaction should be removed
  Future<void> call({required String messageId, required String userId}) async {
    await _repository.removeReaction(
      messageId,
      userId,
    );
  }
}
