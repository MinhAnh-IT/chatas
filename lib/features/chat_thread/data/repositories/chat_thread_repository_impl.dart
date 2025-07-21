import 'package:chatas/features/chat_thread/data/datasources/chat_thread_remote_data_source.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

class ChatThreadRepositoryImpl implements ChatThreadRepository {
  
  final ChatThreadRemoteDataSource _remoteDataSource;

  ChatThreadRepositoryImpl({ChatThreadRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ChatThreadRemoteDataSource();

  @override
  Future<List<ChatThread>> getChatThreads() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _remoteDataSource.fetchChatThreads();
  }
}
