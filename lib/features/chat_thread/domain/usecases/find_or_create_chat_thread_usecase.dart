import '../entities/chat_thread.dart';
import '../repositories/chat_thread_repository.dart';

/// Use case for finding an existing chat thread between two users or creating a new one.
/// Only creates the thread in database when the first message is sent.
class FindOrCreateChatThreadUseCase {
  final ChatThreadRepository repository;

  FindOrCreateChatThreadUseCase(this.repository);

  /// Finds an existing chat thread between current user and friend.
  /// If none exists, returns a temporary thread that will be created when first message is sent.
  ///
  /// [currentUserId] The ID of the current logged-in user
  /// [friendId] The ID of the friend to chat with
  /// [friendName] The display name of the friend
  /// [friendAvatarUrl] The avatar URL of the friend
  ///
  /// Returns a [ChatThread] entity - either existing or temporary
  Future<ChatThread> call({
    required String currentUserId,
    required String friendId,
    required String friendName,
    required String friendAvatarUrl,
  }) async {
    // Check if user is trying to chat with themselves
    if (currentUserId == friendId) {
      throw Exception('Cannot create chat thread with yourself');
    }

    // Get all existing threads for current user
    final allThreads = await repository.getChatThreads(currentUserId);

    // Look for existing thread between these two users
    for (final thread in allThreads) {
      if (!thread.isGroup &&
          thread.members.length == 2 &&
          thread.members.contains(currentUserId) &&
          thread.members.contains(friendId)) {
        return thread;
      }
    }

    // No existing thread found, return a temporary thread
    // This will be created in database only when first message is sent
    final now = DateTime.now();
    final tempThread = ChatThread(
      id: 'temp_${friendId}_${now.millisecondsSinceEpoch}',
      name: friendName,
      lastMessage: '',
      lastMessageTime: now,
      avatarUrl: friendAvatarUrl,
      members: [currentUserId, friendId],
      isGroup: false,
      unreadCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    return tempThread;
  }
}
