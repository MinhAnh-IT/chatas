import '../entities/chat_thread.dart';
import '../repositories/chat_thread_repository.dart';

/// Use case for finding an existing chat thread between two users or creating a new one.
/// Only creates the thread in database when the first message is sent.
class FindOrCreateChatThreadUseCase {
  final ChatThreadRepository repository;

  FindOrCreateChatThreadUseCase(this.repository);

  /// Finds an existing chat thread between current user and friend.
  /// If none exists, returns a temporary thread that will be created when first message is sent.
  /// If a hidden thread exists and forceCreateNew is false, it will be unhidden and returned.
  /// If forceCreateNew is true, always creates a new thread even if hidden one exists.
  ///
  /// [currentUserId] The ID of the current logged-in user
  /// [friendId] The ID of the friend to chat with
  /// [friendName] The display name of the friend
  /// [friendAvatarUrl] The avatar URL of the friend
  /// [forceCreateNew] If true, always creates new thread even if hidden one exists
  ///
  /// Returns a [ChatThread] entity - either existing or temporary
  Future<ChatThread> call({
    required String currentUserId,
    required String friendId,
    required String friendName,
    required String friendAvatarUrl,
    bool forceCreateNew = false,
  }) async {
    // Check if user is trying to chat with themselves
    if (currentUserId == friendId) {
      throw Exception('Cannot create chat thread with yourself');
    }

    // If forceCreateNew is true, skip checking for existing threads
    if (!forceCreateNew) {
      // Get ALL existing threads for current user (including hidden ones)
      final allThreads = await repository.getAllChatThreads(currentUserId);

      // Look for existing thread between these two users
      for (final thread in allThreads) {
        if (!thread.isGroup &&
            thread.members.length == 2 &&
            thread.members.contains(currentUserId) &&
            thread.members.contains(friendId)) {
          // If thread is hidden for current user, unhide it
          if (thread.isHiddenFor(currentUserId)) {
            print(
              'FindOrCreateChatThreadUseCase: Found hidden thread ${thread.id}, unhiding it for user $currentUserId',
            );
            // Remove user from hiddenFor list
            await repository.unhideChatThread(thread.id, currentUserId);

            // Return the thread (it will be visible now)
            return thread;
          }

          // Thread exists and is visible
          print(
            'FindOrCreateChatThreadUseCase: Found existing visible thread ${thread.id}',
          );
          return thread;
        }
      }
    } else {
      print(
        'FindOrCreateChatThreadUseCase: forceCreateNew is true, skipping existing thread check',
      );
    }

    // No existing thread found or forceCreateNew is true, return a temporary thread
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
      unreadCounts: {},
      createdAt: now,
      updatedAt: now,
    );

    print(
      'FindOrCreateChatThreadUseCase: Creating new temporary thread ${tempThread.id}',
    );
    return tempThread;
  }
}
