import 'package:chatas/features/chat_thread/data/datasources/chat_thread_remote_data_source.dart';
import 'package:chatas/features/chat_thread/data/models/chat_thread_model.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

class ChatThreadRepositoryImpl implements ChatThreadRepository {
  final ChatThreadRemoteDataSource _remoteDataSource;

  ChatThreadRepositoryImpl({ChatThreadRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ChatThreadRemoteDataSource();

  @override
  Future<List<ChatThread>> getChatThreads(String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final models = await _remoteDataSource.fetchChatThreads(currentUserId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ChatThread>> getAllChatThreads(String currentUserId) async {
    final models = await _remoteDataSource.fetchAllChatThreads(currentUserId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ChatThread>> getArchivedChatThreads(String currentUserId) async {
    final models = await _remoteDataSource.getArchivedChatThreads(
      currentUserId,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  Future<void> addChatThread(ChatThread chatThread) async {
    final model = ChatThreadModel.fromEntity(chatThread);
    return await _remoteDataSource.addChatThread(model);
  }

  @override
  Future<void> createChatThread(ChatThread chatThread) async {
    final model = ChatThreadModel.fromEntity(chatThread);
    return await _remoteDataSource.addChatThread(model);
  }

  @override
  Future<ChatThread?> getChatThreadById(String threadId) async {
    final model = await _remoteDataSource.getChatThreadById(threadId);
    return model?.toEntity();
  }

  @override
  Future<void> updateChatThreadMembers(
    String threadId,
    List<String> members,
  ) async {
    return await _remoteDataSource.updateChatThreadMembers(threadId, members);
  }

  @override
  Future<void> updateChatThreadName(String threadId, String name) async {
    return await _remoteDataSource.updateChatThreadName(threadId, name);
  }

  @override
  Future<void> updateChatThreadAvatar(String threadId, String avatarUrl) async {
    return await _remoteDataSource.updateChatThreadAvatar(threadId, avatarUrl);
  }

  @override
  Future<void> updateChatThreadDescription(
    String threadId,
    String description,
  ) async {
    return await _remoteDataSource.updateChatThreadDescription(
      threadId,
      description,
    );
  }

  @override
  Future<void> updateLastMessage(
    String threadId,
    String message,
    DateTime timestamp,
  ) async {
    return await _remoteDataSource.updateLastMessage(
      threadId,
      message,
      timestamp,
    );
  }

  @override
  Future<void> incrementUnreadCount(String threadId, String userId) async {
    return await _remoteDataSource.incrementUnreadCount(threadId, userId);
  }

  @override
  Future<void> resetUnreadCount(String threadId, String userId) async {
    return await _remoteDataSource.resetUnreadCount(threadId, userId);
  }

  @override
  Future<void> deleteChatThread(String threadId) async {
    return await _remoteDataSource.deleteChatThread(threadId);
  }

  @override
  Future<void> hideChatThread(String threadId, String userId) async {
    return await _remoteDataSource.hideChatThread(threadId, userId);
  }

  @override
  Future<void> unhideChatThread(String threadId, String userId) async {
    return await _remoteDataSource.unhideChatThread(threadId, userId);
  }

  @override
  Future<void> updateLastRecreatedAt(
    String threadId,
    DateTime timestamp,
  ) async {
    return await _remoteDataSource.updateLastRecreatedAt(threadId, timestamp);
  }

  @override
  Future<void> resetThreadForUser(String threadId, String userId) async {
    return await _remoteDataSource.resetThreadForUser(threadId, userId);
  }

  @override
  Future<void> markThreadDeletedForUser(
    String threadId,
    String userId,
    DateTime cutoff,
  ) async {
    return await _remoteDataSource.markThreadDeletedForUser(
      threadId,
      userId,
      cutoff,
    );
  }

  @override
  Future<void> archiveThreadForUser(String threadId, String userId) async {
    return await _remoteDataSource.archiveThreadForUser(threadId, userId);
  }

  @override
  Future<void> reviveThreadForUser(String threadId, String userId) async {
    return await _remoteDataSource.reviveThreadForUser(threadId, userId);
  }

  @override
  Future<void> leaveGroup(String threadId, String userId) async {
    return await _remoteDataSource.leaveGroup(threadId, userId);
  }

  @override
  Future<void> joinGroup(String threadId, String userId) async {
    return await _remoteDataSource.joinGroup(threadId, userId);
  }

  @override
  Future<ChatThread> findOrCreate1v1Thread(
    String user1,
    String user2, {
    String? threadName,
    String? avatarUrl,
  }) async {
    return await _remoteDataSource.findOrCreate1v1Thread(
      user1,
      user2,
      threadName,
      avatarUrl,
    );
  }

  @override
  Future<void> updateVisibilityCutoff(
    String threadId,
    String userId,
    DateTime cutoff,
  ) async {
    return await _remoteDataSource.updateVisibilityCutoff(
      threadId,
      userId,
      cutoff,
    );
  }

  @override
  Future<List<ChatThread>> searchChatThreads(
    String query,
    String currentUserId,
  ) async {
    final models = await _remoteDataSource.searchChatThreads(
      query,
      currentUserId,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<List<ChatThread>> getChatThreadsStream(String currentUserId) {
    return _remoteDataSource.chatThreadsStream(currentUserId).map((models) {
      // Convert models to entities and sort by lastMessageTime (newest first)
      final threads = models.map((model) => model.toEntity()).toList();

      // Sort by lastMessageTime in descending order (newest first)
      threads.sort((a, b) {
        return b.lastMessageTime.compareTo(a.lastMessageTime); // Newest first
      });

      return threads;
    });
  }
}
