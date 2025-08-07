import '../entities/chat_thread.dart';
import '../repositories/chat_thread_repository.dart';

/// Use case for searching chat threads by name or last message content.
class SearchChatThreadsUseCase {
  final ChatThreadRepository repository;

  SearchChatThreadsUseCase(this.repository);

  /// Searches for chat threads containing the given query in name or last message.
  /// 
  /// Returns a filtered list of [ChatThread] objects that match the search query.
  /// The search is case-insensitive and matches both thread names and last messages.
  Future<List<ChatThread>> call(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final allThreads = await repository.getChatThreads();
    final lowercaseQuery = query.toLowerCase().trim();

    return allThreads.where((thread) {
      final threadName = thread.name.toLowerCase();
      final lastMessage = thread.lastMessage.toLowerCase();
      
      return threadName.contains(lowercaseQuery) || 
             lastMessage.contains(lowercaseQuery);
    }).toList();
  }
}
