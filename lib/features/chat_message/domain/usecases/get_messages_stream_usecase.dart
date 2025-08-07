import '../entities/chat_message.dart';
import '../repositories/chat_message_repository.dart';

/// Use case for getting real-time message stream from a chat thread.
/// Encapsulates the business logic for real-time message updates.
class GetMessagesStreamUseCase {
  final ChatMessageRepository repository;

  const GetMessagesStreamUseCase(this.repository);

  /// Executes the use case to get a real-time stream of messages.
  /// Returns a stream that emits updated message lists when changes occur.
  Stream<List<ChatMessage>> call(String chatThreadId) {
    return repository.messagesStream(chatThreadId);
  }
}
