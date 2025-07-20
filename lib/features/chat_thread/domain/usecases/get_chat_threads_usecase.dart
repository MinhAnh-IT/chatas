import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

import '../repositories/chat_thread_repository.dart';

class GetChatThreadsUseCase {
  final ChatThreadRepository repository;

  GetChatThreadsUseCase(this.repository);

  Future<List<ChatThread>> call() async {
    return await repository.getChatThreads();
  }
}
