import '../repositories/chat_thread_repository.dart';

/// Use case for deleting a chat thread.
class DeleteChatThreadUseCase {
  final ChatThreadRepository repository;

  DeleteChatThreadUseCase(this.repository);

  /// Deletes a chat thread by its ID.
  ///
  /// [threadId] The ID of the chat thread to be deleted.
  ///
  /// Throws an exception if the deletion fails.
  Future<void> call(String threadId) async {
    if (threadId.isEmpty) {
      throw ArgumentError('Thread ID cannot be empty');
    }

    await repository.deleteChatThread(threadId);
  }
}
