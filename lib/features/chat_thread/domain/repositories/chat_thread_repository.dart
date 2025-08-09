import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

abstract class ChatThreadRepository {
  /// Gets all chat threads for a user.
  Future<List<ChatThread>> getChatThreads(String currentUserId);

  /// Gets all chat threads for a user, including hidden ones.
  /// Used for finding existing threads before creating new ones.
  Future<List<ChatThread>> getAllChatThreads(String currentUserId);

  /// Gets archived (hidden) chat threads for a user.
  Future<List<ChatThread>> getArchivedChatThreads(String currentUserId);

  /// Creates a new chat thread.
  Future<void> createChatThread(ChatThread chatThread);

  /// Gets a chat thread by its ID.
  Future<ChatThread?> getChatThreadById(String threadId);

  /// Updates the members of a chat thread.
  Future<void> updateChatThreadMembers(String threadId, List<String> members);

  /// Updates the name of a chat thread.
  Future<void> updateChatThreadName(String threadId, String name);

  /// Updates the avatar URL of a chat thread.
  Future<void> updateChatThreadAvatar(String threadId, String avatarUrl);

  /// Updates the description of a chat thread.
  Future<void> updateChatThreadDescription(String threadId, String description);

  /// Updates the last message of a chat thread.
  Future<void> updateLastMessage(String threadId, String message, DateTime timestamp);

  /// Increments the unread count for a specific user in a chat thread.
  Future<void> incrementUnreadCount(String threadId, String userId);

  /// Resets the unread count for a specific user in a chat thread.
  Future<void> resetUnreadCount(String threadId, String userId);

  /// Deletes a chat thread completely (hard delete).
  Future<void> deleteChatThread(String threadId);

  /// Hides a chat thread for a specific user (soft delete).
  Future<void> hideChatThread(String threadId, String userId);

  /// Unhides a chat thread for a specific user.
  Future<void> unhideChatThread(String threadId, String userId);

  /// Updates the lastRecreatedAt timestamp for a chat thread.
  Future<void> updateLastRecreatedAt(String threadId, DateTime timestamp);

  /// Resets thread state for a specific user (clears unread count).
  Future<void> resetThreadForUser(String threadId, String userId);

  /// Marks a 1-1 chat thread as deleted for a specific user.
  /// Sets visibility cutoff to hide old messages.
  Future<void> markThreadDeletedForUser(String threadId, String userId, DateTime cutoff);

  /// Archives a chat thread for a specific user (hides from inbox).
  /// Applies to both 1-1 and group chats.
  Future<void> archiveThreadForUser(String threadId, String userId);

  /// Revives a chat thread for a specific user (shows in inbox again).
  /// Keeps cutoff (1-1) or joinedAt (group) intact.
  Future<void> reviveThreadForUser(String threadId, String userId);

  /// Makes a user leave a group chat.
  /// Removes user from members and joinedAt.
  Future<void> leaveGroup(String threadId, String userId);

  /// Makes a user join a group chat.
  /// Adds user to members and sets joinedAt timestamp.
  Future<void> joinGroup(String threadId, String userId);

  /// Finds or creates a 1-1 chat thread between two users.
  /// Only creates the thread when the first message is sent.
  Future<ChatThread> findOrCreate1v1Thread(String user1, String user2, {
    String? threadName,
    String? avatarUrl,
  });

  /// Updates the visibility cutoff timestamp for a specific user in a 1-1 chat.
  /// Used when recreating deleted chats.
  Future<void> updateVisibilityCutoff(String threadId, String userId, DateTime cutoff);

  /// Searches for chat threads based on a query.
  Future<List<ChatThread>> searchChatThreads(String query, String currentUserId);
}
