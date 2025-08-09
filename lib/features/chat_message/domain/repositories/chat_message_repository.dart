import '../entities/chat_message.dart';

/// Repository interface for chat message operations.
/// Defines the contract for data access operations without implementation details.
abstract class ChatMessageRepository {
  /// Fetches all messages for a specific chat thread.
  /// Returns a list of [ChatMessage] entities sorted by creation time.
  Future<List<ChatMessage>> getMessages(String chatThreadId);

  /// Provides a real-time stream of messages for a specific chat thread.
  /// Returns a stream that emits updated message lists when changes occur.
  Stream<List<ChatMessage>> messagesStream(String chatThreadId);

  /// Sends a new message to the specified chat thread.
  /// Takes a [ChatMessage] entity and persists it to the data source.
  Future<void> sendMessage(ChatMessage message);

  /// Updates an existing message with new content or status.
  /// Takes a [ChatMessage] entity with updated fields.
  Future<void> updateMessage(ChatMessage message);

  /// Soft deletes a message by setting its isDeleted flag to true.
  /// Takes the message ID to identify which message to delete.
  Future<void> deleteMessage(String messageId);

  /// Edits the content of an existing message with ownership validation.
  /// Takes message ID, new content, and user ID for ownership check.
  Future<void> editMessage({
    required String messageId,
    required String newContent,
    required String userId,
  });

  /// Deletes a message with ownership validation.
  /// Takes message ID and user ID for ownership check.
  Future<void> deleteMessageWithValidation({
    required String messageId,
    required String userId,
  });

  /// Adds a reaction to a specific message from a user.
  /// Takes message ID, user ID, and the reaction type to add.
  Future<void> addReaction(
    String messageId,
    String userId,
    ReactionType reaction,
  );

  /// Removes a reaction from a specific message for a user.
  /// Takes message ID and user ID to identify which reaction to remove.
  Future<void> removeReaction(String messageId, String userId);

  /// Marks all messages in a chat thread as read for a specific user.
  /// Resets the unread count for the chat thread.
  Future<void> markMessagesAsRead(String chatThreadId, String userId);
}
