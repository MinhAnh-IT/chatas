import '../repositories/chat_thread_repository.dart';

/// Use case for hiding a chat thread for a specific user (soft delete).
class HideChatThreadUseCase {
  final ChatThreadRepository repository;

  HideChatThreadUseCase(this.repository);

  /// Hides a chat thread for a specific user.
  ///
  /// [threadId] The ID of the chat thread to be hidden.
  /// [userId] The ID of the user who wants to hide the thread.
  ///
  /// Throws an exception if the hiding fails.
  Future<void> call(String threadId, String userId) async {
    if (threadId.isEmpty) {
      throw ArgumentError('Thread ID cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    await repository.hideChatThread(threadId, userId);
  }
}
