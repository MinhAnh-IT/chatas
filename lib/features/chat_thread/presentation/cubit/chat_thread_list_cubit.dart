import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/usecases/get_chat_threads_usecase.dart';
import '../../domain/usecases/create_chat_thread_usecase.dart';
import '../../domain/usecases/search_chat_threads_usecase.dart';
import '../../domain/usecases/delete_chat_thread_usecase.dart';
import '../../domain/usecases/find_or_create_chat_thread_usecase.dart';
import 'chat_thread_list_state.dart';

class ChatThreadListCubit extends Cubit<ChatThreadListState> {
  final GetChatThreadsUseCase getChatThreadsUseCase;
  final CreateChatThreadUseCase createChatThreadUseCase;
  final SearchChatThreadsUseCase searchChatThreadsUseCase;
  final DeleteChatThreadUseCase deleteChatThreadUseCase;
  final FindOrCreateChatThreadUseCase findOrCreateChatThreadUseCase;

  ChatThreadListCubit({
    required this.getChatThreadsUseCase,
    required this.createChatThreadUseCase,
    required this.searchChatThreadsUseCase,
    required this.deleteChatThreadUseCase,
    required this.findOrCreateChatThreadUseCase,
  }) : super(ChatThreadListInitial());

  /// Fetches all chat threads from the repository for a specific user.
  Future<void> fetchChatThreads(String currentUserId) async {
    emit(ChatThreadListLoading());
    try {
      final threads = await getChatThreadsUseCase(currentUserId);
      emit(ChatThreadListLoaded(threads));
    } catch (e) {
      emit(ChatThreadListError(e.toString()));
    }
  }

  /// Searches for chat threads based on the given query.
  Future<List<ChatThread>> searchChatThreads(
    String query,
    String currentUserId,
  ) async {
    try {
      return await searchChatThreadsUseCase(query, currentUserId);
    } catch (e) {
      return [];
    }
  }

  /// Creates a new chat thread with the specified friend.
  Future<void> createNewChatThread({
    required String currentUserId,
    required String friendId,
    required String friendName,
    required String friendAvatarUrl,
    String? initialMessage,
  }) async {
    try {
      await createChatThreadUseCase(
        currentUserId: currentUserId,
        friendId: friendId,
        friendName: friendName,
        friendAvatarUrl: friendAvatarUrl,
        initialMessage: initialMessage,
      );
      // Refresh danh sách sau khi tạo thành công
      await fetchChatThreads(currentUserId);
    } catch (e) {
      emit(ChatThreadListError('Failed to create chat: $e'));
    }
  }

  /// Deletes a chat thread by its ID.
  Future<void> deleteChatThread(String threadId, String currentUserId) async {
    if (threadId.isEmpty) {
      emit(const ChatThreadListError('Invalid thread ID'));
      return;
    }

    emit(ChatThreadDeleting(threadId));

    try {
      await deleteChatThreadUseCase(threadId);
      // Refresh the list after successful deletion
      await fetchChatThreads(currentUserId);
    } catch (e) {
      emit(ChatThreadListError('Failed to delete chat: ${e.toString()}'));
    }
  }

  /// Finds an existing chat thread or creates a temporary one for opening chat.
  /// Returns the chat thread that should be opened for messaging.
  Future<ChatThread> findOrCreateChatThreadForMessaging({
    required String currentUserId,
    required String friendId,
    required String friendName,
    required String friendAvatarUrl,
  }) async {
    try {
      return await findOrCreateChatThreadUseCase(
        currentUserId: currentUserId,
        friendId: friendId,
        friendName: friendName,
        friendAvatarUrl: friendAvatarUrl,
      );
    } catch (e) {
      // If error occurs, return a temporary thread to allow messaging
      final now = DateTime.now();
      return ChatThread(
        id: 'temp_${friendId}_${now.millisecondsSinceEpoch}',
        name: friendName,
        lastMessage: '',
        lastMessageTime: now,
        avatarUrl: friendAvatarUrl,
        members: [currentUserId, friendId],
        isGroup: false,
        unreadCount: 0,
        createdAt: now,
        updatedAt: now,
      );
    }
  }
}
