import '../entities/chat_thread.dart';
import '../repositories/chat_thread_repository.dart';

/// Use case for finding an existing chat thread between two users or creating a new one.
/// Only creates the thread in database when the first message is sent.
class FindOrCreateChatThreadUseCase {
  final ChatThreadRepository repository;

  FindOrCreateChatThreadUseCase(this.repository);

  /// Finds an existing chat thread between current user and friend.
  /// If none exists, returns a temporary thread that will be created when first message is sent.
  /// If a hidden thread exists, returns a temporary thread until first message is sent.
  /// For group chats, only supports hiding (no recreation logic).
  ///
  /// [currentUserId] The ID of the current logged-in user
  /// [friendId] The ID of the friend to chat with
  /// [friendName] The display name of the friend
  /// [friendAvatarUrl] The avatar URL of the friend
  /// [forceCreateNew] If true for 1-1 chats, returns temporary thread with lastRecreatedAt info
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

    // Get ALL existing threads for current user (including hidden ones)
    final allThreads = await repository.getAllChatThreads(currentUserId);
    print(
      'FindOrCreateChatThreadUseCase: Found ${allThreads.length} total threads for user $currentUserId',
    );

    // Look for existing thread between these two users
    for (final thread in allThreads) {
      print(
        'FindOrCreateChatThreadUseCase: Checking thread ${thread.id} - Members: ${thread.members}, IsGroup: ${thread.isGroup}, HiddenFor: ${thread.hiddenFor}',
      );

      if (!thread.isGroup &&
          thread.members.length == 2 &&
          thread.members.contains(currentUserId) &&
          thread.members.contains(friendId)) {
        print(
          'FindOrCreateChatThreadUseCase: Found matching 1-1 thread ${thread.id} between $currentUserId and $friendId',
        );

        // Check if thread is hidden for current user (whether or not other user has also hidden it)
        if (thread.isHiddenFor(currentUserId)) {
          // For 1-1 chats: Return the original hidden thread with lastRecreatedAt set
          // This will be unhidden when first message is sent
          print(
            'FindOrCreateChatThreadUseCase: Found hidden 1-1 thread ${thread.id}, returning it with lastRecreatedAt for user $currentUserId',
          );

          final now = DateTime.now();
          // Return the original thread with lastRecreatedAt set
          return thread.copyWith(
            lastRecreatedAt:
                now, // Set lastRecreatedAt to indicate this is a recreation
          );
        }

        // Thread exists and is visible
        print(
          'FindOrCreateChatThreadUseCase: Found existing visible thread ${thread.id}',
        );
        return thread;
      } else {
        print(
          'FindOrCreateChatThreadUseCase: Thread ${thread.id} does not match criteria - IsGroup: ${thread.isGroup}, Members: ${thread.members}, Contains currentUserId: ${thread.members.contains(currentUserId)}, Contains friendId: ${thread.members.contains(friendId)}',
        );
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
