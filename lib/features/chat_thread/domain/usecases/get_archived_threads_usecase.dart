import '../entities/chat_thread.dart';
import '../repositories/chat_thread_repository.dart';

/// Use case for retrieving archived (hidden) chat threads for a specific user.
class GetArchivedThreadsUseCase {
  final ChatThreadRepository repository;

  GetArchivedThreadsUseCase(this.repository);

  /// Retrieves all archived chat threads for the given user.
  /// These are threads that the user has hidden from their main inbox.
  ///
  /// [currentUserId] The ID of the current user
  ///
  /// Returns a list of [ChatThread] entities that are archived for this user.
  /// Returns an empty list if no archived threads are found.
  ///
  /// Throws an exception if the operation fails.
  Future<List<ChatThread>> call(String currentUserId) async {
    if (currentUserId.isEmpty) {
      throw ArgumentError('Current user ID cannot be empty');
    }

    return await repository.getArchivedChatThreads(currentUserId);
  }
}
