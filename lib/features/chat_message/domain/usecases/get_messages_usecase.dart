import '../entities/chat_message.dart';
import '../repositories/chat_message_repository.dart';

/// Use case for fetching messages from a specific chat thread.
/// Encapsulates the business logic for retrieving message history.
class GetMessagesUseCase {
  final ChatMessageRepository repository;

  const GetMessagesUseCase(this.repository);

  /// Executes the use case to get messages for a chat thread.
  /// Returns a list of [ChatMessage] entities sorted by time.
  Future<List<ChatMessage>> call(String chatThreadId) async {
    return await repository.getMessages(chatThreadId);
  }
}
