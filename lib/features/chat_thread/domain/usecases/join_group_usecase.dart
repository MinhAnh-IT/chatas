import '../repositories/chat_thread_repository.dart';

/// Use case for making a user join a group chat.
/// Adds the user to members and sets joinedAt timestamp.
class JoinGroupUseCase {
  final ChatThreadRepository repository;

  JoinGroupUseCase(this.repository);

  /// Makes a user join a group chat.
  /// Adds user to members and sets joinedAt timestamp.
  ///
  /// [threadId] The ID of the group chat thread
  /// [userId] The ID of the user who is joining the group
  ///
  /// Throws an exception if the operation fails.
  Future<void> call({required String threadId, required String userId}) async {
    if (threadId.isEmpty) {
      throw ArgumentError('Thread ID cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    await repository.joinGroup(threadId, userId);
  }
}
