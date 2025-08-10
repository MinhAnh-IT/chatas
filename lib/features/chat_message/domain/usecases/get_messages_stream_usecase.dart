import '../repositories/chat_message_repository.dart';
import '../entities/chat_message.dart';

/// Use case for getting a stream of messages from a chat thread.
class GetMessagesStreamUseCase {
  final ChatMessageRepository _repository;

  const GetMessagesStreamUseCase({required ChatMessageRepository repository})
    : _repository = repository;

  /// Gets a real-time stream of messages for a specific chat thread.
  ///
  /// [chatThreadId] The ID of the chat thread to get messages from
  /// [currentUserId] The ID of the current user (for filtering deleted messages)
  ///
  /// Returns a stream of [ChatMessage] lists
  Stream<List<ChatMessage>> call(String chatThreadId, String currentUserId) {
    return _repository.messagesStream(chatThreadId, currentUserId);
  }
}
