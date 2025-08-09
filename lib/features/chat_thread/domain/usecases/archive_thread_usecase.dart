import '../repositories/chat_thread_repository.dart';

/// Use case for archiving a chat thread for a specific user.
/// This hides the thread from the user's inbox without setting visibility cutoff.
class ArchiveThreadUseCase {
  final ChatThreadRepository repository;

  ArchiveThreadUseCase(this.repository);

  /// Archives a chat thread for a specific user.
  /// Hides the thread from inbox but doesn't set visibility cutoff.
  ///
  /// [threadId] The ID of the chat thread
  /// [userId] The ID of the user who is archiving the thread
  ///
  /// Throws an exception if the operation fails.
  Future<void> call({
    required String threadId,
    required String userId,
  }) async {
    if (threadId.isEmpty) {
      throw ArgumentError('Thread ID cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    await repository.archiveThreadForUser(threadId, userId);
  }
}
