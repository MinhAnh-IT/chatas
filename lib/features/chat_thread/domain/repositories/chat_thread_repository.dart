import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

abstract class ChatThreadRepository {
  Future<List<ChatThread>> getChatThreads(String currentUserId);
  Future<void> addChatThread(ChatThread chatThread);

  /// Deletes a chat thread by its ID.
  Future<void> deleteChatThread(String threadId);

  // New methods for group chat management
  Future<void> createChatThread(ChatThread chatThread);
  Future<ChatThread?> getChatThreadById(String chatThreadId);
  Future<void> updateChatThreadMembers(
    String chatThreadId,
    List<String> members,
  );
  Future<void> updateChatThreadName(String chatThreadId, String name);
  Future<void> updateChatThreadAvatar(String chatThreadId, String avatarUrl);
  Future<void> updateChatThreadDescription(
    String chatThreadId,
    String description,
  );
}
