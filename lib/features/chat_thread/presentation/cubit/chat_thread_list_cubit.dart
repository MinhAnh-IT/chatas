import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/usecases/get_chat_threads_usecase.dart';
import '../../domain/usecases/create_chat_thread_usecase.dart';
import '../../domain/usecases/search_chat_threads_usecase.dart';
import '../../domain/usecases/delete_chat_thread_usecase.dart';
import 'chat_thread_list_state.dart';

class ChatThreadListCubit extends Cubit<ChatThreadListState> {
  final GetChatThreadsUseCase getChatThreadsUseCase;
  final CreateChatThreadUseCase createChatThreadUseCase;
  final SearchChatThreadsUseCase searchChatThreadsUseCase;
  final DeleteChatThreadUseCase deleteChatThreadUseCase;

  ChatThreadListCubit({
    required this.getChatThreadsUseCase,
    required this.createChatThreadUseCase,
    required this.searchChatThreadsUseCase,
    required this.deleteChatThreadUseCase,
  }) : super(ChatThreadListInitial());

  /// Fetches all chat threads from the repository.
  Future<void> fetchChatThreads() async {
    emit(ChatThreadListLoading());
    try {
      final threads = await getChatThreadsUseCase();
      emit(ChatThreadListLoaded(threads));
    } catch (e) {
      emit(ChatThreadListError(e.toString()));
    }
  }

  /// Searches for chat threads based on the given query.
  Future<List<ChatThread>> searchChatThreads(String query) async {
    try {
      return await searchChatThreadsUseCase(query);
    } catch (e) {
      return [];
    }
  }

  /// Creates a new chat thread with the specified friend.
  Future<void> createNewChatThread({
    required String friendId,
    required String friendName,
    required String friendAvatarUrl,
    String? initialMessage,
  }) async {
    try {
      await createChatThreadUseCase(
        friendId: friendId,
        friendName: friendName,
        friendAvatarUrl: friendAvatarUrl,
        initialMessage: initialMessage,
      );
      // Refresh danh sách sau khi tạo thành công
      await fetchChatThreads();
    } catch (e) {
      emit(ChatThreadListError('Failed to create chat: $e'));
    }
  }

  /// Deletes a chat thread by its ID.
  Future<void> deleteChatThread(String threadId) async {
    if (threadId.isEmpty) {
      emit(const ChatThreadListError('Invalid thread ID'));
      return;
    }

    emit(ChatThreadDeleting(threadId));

    try {
      await deleteChatThreadUseCase(threadId);
      // Refresh the list after successful deletion
      await fetchChatThreads();
    } catch (e) {
      emit(ChatThreadListError('Failed to delete chat: ${e.toString()}'));
    }
  }
}
