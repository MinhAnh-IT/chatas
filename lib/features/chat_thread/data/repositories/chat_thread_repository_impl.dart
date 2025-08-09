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
  Future<void> addChatThread(ChatThread chatThread) async {
    final model = ChatThreadModel.fromEntity(chatThread);
    return await _remoteDataSource.addChatThread(model);
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
  Future<void> createChatThread(ChatThread chatThread) async {
    final model = ChatThreadModel.fromEntity(chatThread);
    return await _remoteDataSource.createChatThread(model);
  }

  @override
  Future<ChatThread?> getChatThreadById(String chatThreadId) async {
    final model = await _remoteDataSource.getChatThreadById(chatThreadId);
    return model?.toEntity();
  }

  @override
  Future<void> updateChatThreadMembers(
    String chatThreadId,
    List<String> members,
  ) async {
    return await _remoteDataSource.updateChatThreadMembers(
      chatThreadId,
      members,
    );
  }

  @override
  Future<void> updateChatThreadName(String chatThreadId, String name) async {
    return await _remoteDataSource.updateChatThreadName(chatThreadId, name);
  }

  @override
  Future<void> updateChatThreadAvatar(
    String chatThreadId,
    String avatarUrl,
  ) async {
    return await _remoteDataSource.updateChatThreadAvatar(
      chatThreadId,
      avatarUrl,
    );
  }

  @override
  Future<void> updateChatThreadDescription(
    String chatThreadId,
    String description,
  ) async {
    return await _remoteDataSource.updateChatThreadDescription(
      chatThreadId,
      description,
    );
  }
}
