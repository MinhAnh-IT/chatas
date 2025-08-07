import '../repositories/chat_message_repository.dart';
import '../../constants/chat_message_page_constants.dart';

/// UseCase for removing a reaction from a chat message.
/// Handles the business logic for reaction removal.
class RemoveReactionUseCase {
  final ChatMessageRepository _repository;

  const RemoveReactionUseCase({
    required ChatMessageRepository repository,
  }) : _repository = repository;

  /// Removes a user's reaction from the specified message.
  /// Uses the current user ID from constants to match AddReactionUseCase behavior.
  /// 
  /// [messageId] The ID of the message to remove reaction from
  /// [userId] The ID of the user whose reaction should be removed (currently ignored, uses temporaryUserId)
  Future<void> call({
    required String messageId,
    required String userId,
  }) async {
    // TODO: Get actual current user ID from auth service
    // For now, use the same temporaryUserId as AddReactionUseCase to maintain consistency
    await _repository.removeReaction(messageId, ChatMessagePageConstants.temporaryUserId);
  }
}
