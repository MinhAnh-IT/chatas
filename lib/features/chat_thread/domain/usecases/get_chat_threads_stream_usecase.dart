import '../entities/chat_thread.dart';
import '../repositories/chat_thread_repository.dart';

class GetChatThreadsStreamUseCase {
  final ChatThreadRepository repository;

  GetChatThreadsStreamUseCase(this.repository);

  Stream<List<ChatThread>> call(String currentUserId) {
    return repository.getChatThreadsStream(currentUserId);
  }
}
