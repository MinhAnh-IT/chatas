import '../repositories/chat_thread_repository.dart';

/// Use case for marking a 1-1 chat thread as deleted for a specific user.
/// This sets the visibility cutoff to hide old messages.
class MarkThreadDeletedUseCase {
  final ChatThreadRepository repository;

  MarkThreadDeletedUseCase(this.repository);

  /// Marks a 1-1 chat thread as deleted for a specific user.
  /// Sets visibility cutoff to hide messages before the deletion time.
  ///
  /// [threadId] The ID of the chat thread
  /// [userId] The ID of the user who is deleting the thread
  /// [lastMessageTime] Optional timestamp of the last message (to avoid exposing recent messages)
  ///
  /// Throws an exception if the operation fails.
  Future<void> call({
    required String threadId,
    required String userId,
    DateTime? lastMessageTime,
  }) async {
    if (threadId.isEmpty) {
      throw ArgumentError('Thread ID cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    final now = DateTime.now();
    final cutoff = (lastMessageTime != null && lastMessageTime.isAfter(now)) 
        ? lastMessageTime 
        : now;

    await repository.markThreadDeletedForUser(threadId, userId, cutoff);
  }
}
