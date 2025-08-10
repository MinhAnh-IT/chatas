import '../entities/chat_message.dart';
import '../repositories/chat_message_repository.dart';

/// Use case for adding reactions to chat messages.
/// Handles the business logic for message reactions.
class AddReactionUseCase {
  final ChatMessageRepository repository;

  const AddReactionUseCase(this.repository);

  /// Executes the use case to add a reaction to a message.
  /// Takes message ID and reaction type, uses current user ID.
  Future<void> call({
    required String messageId,
    required ReactionType reaction,
    required String userId,
  }) async {
    await repository.addReaction(messageId, userId, reaction);
  }
}
