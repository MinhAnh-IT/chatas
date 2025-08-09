import '../repositories/chat_message_repository.dart';

/// Use case for marking all messages in a chat thread as read.
/// This clears the unread count for the user opening the chat.
class MarkMessagesAsReadUseCase {
  final ChatMessageRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  /// Marks all messages in the specified chat thread as read for the user.
  /// This should be called when a user opens a chat thread.
  Future<void> call({
    required String chatThreadId,
    required String userId,
  }) async {
    await repository.markMessagesAsRead(chatThreadId, userId);
  }
}
