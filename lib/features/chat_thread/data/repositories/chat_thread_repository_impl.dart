import 'package:chatas/features/chat_thread/data/datasources/chat_thread_remote_data_source.dart';
import 'package:chatas/features/chat_thread/data/models/chat_thread_model.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

class ChatThreadRepositoryImpl implements ChatThreadRepository {
  final ChatThreadRemoteDataSource _remoteDataSource;

  ChatThreadRepositoryImpl({ChatThreadRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ChatThreadRemoteDataSource();

  @override
  Future<List<ChatThread>> getChatThreads() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final models = await _remoteDataSource.fetchChatThreads();
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
}
