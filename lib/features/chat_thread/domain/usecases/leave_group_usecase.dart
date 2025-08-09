import '../repositories/chat_thread_repository.dart';

/// Use case for making a user leave a group chat.
/// Removes the user from members and joinedAt.
class LeaveGroupUseCase {
  final ChatThreadRepository repository;

  LeaveGroupUseCase(this.repository);

  /// Makes a user leave a group chat.
  /// Removes user from members and joinedAt.
  ///
  /// [threadId] The ID of the group chat thread
  /// [userId] The ID of the user who is leaving the group
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

    await repository.leaveGroup(threadId, userId);
  }
}
