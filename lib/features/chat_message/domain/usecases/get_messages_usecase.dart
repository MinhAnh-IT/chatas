import '../repositories/chat_message_repository.dart';
import '../entities/chat_message.dart';

/// Use case for getting messages from a chat thread.
class GetMessagesUseCase {
  final ChatMessageRepository _repository;

  const GetMessagesUseCase({required ChatMessageRepository repository})
    : _repository = repository;

  /// Gets all messages for a specific chat thread.
  ///
  /// [chatThreadId] The ID of the chat thread to get messages from
  /// [currentUserId] The ID of the current user (for filtering deleted messages)
  ///
  /// Returns a list of [ChatMessage] entities
  Future<List<ChatMessage>> call(
    String chatThreadId,
    String currentUserId,
  ) async {
    return await _repository.getMessages(chatThreadId, currentUserId);
  }
}
