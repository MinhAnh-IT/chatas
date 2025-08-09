import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/usecases/get_chat_threads_usecase.dart';
import '../../domain/usecases/get_archived_threads_usecase.dart';
import '../../domain/usecases/create_chat_thread_usecase.dart';
import '../../domain/usecases/search_chat_threads_usecase.dart';
import '../../domain/usecases/delete_chat_thread_usecase.dart';
import '../../domain/usecases/hide_chat_thread_usecase.dart';
import '../../domain/usecases/mark_thread_deleted_usecase.dart';
import '../../domain/usecases/archive_thread_usecase.dart';
import '../../domain/usecases/leave_group_usecase.dart';
import '../../domain/usecases/join_group_usecase.dart';
import '../../domain/usecases/find_or_create_chat_thread_usecase.dart';
import 'chat_thread_list_state.dart';

class ChatThreadListCubit extends Cubit<ChatThreadListState> {
  final GetChatThreadsUseCase getChatThreadsUseCase;
  final GetArchivedThreadsUseCase getArchivedThreadsUseCase;
  final CreateChatThreadUseCase createChatThreadUseCase;
  final DeleteChatThreadUseCase deleteChatThreadUseCase;
  final HideChatThreadUseCase hideChatThreadUseCase;
  final MarkThreadDeletedUseCase markThreadDeletedUseCase;
  final ArchiveThreadUseCase archiveThreadUseCase;
  final LeaveGroupUseCase leaveGroupUseCase;
  final JoinGroupUseCase joinGroupUseCase;
  final FindOrCreateChatThreadUseCase findOrCreateChatThreadUseCase;
  final SearchChatThreadsUseCase searchChatThreadsUseCase;

  ChatThreadListCubit({
    required this.getChatThreadsUseCase,
    required this.getArchivedThreadsUseCase,
    required this.createChatThreadUseCase,
    required this.deleteChatThreadUseCase,
    required this.hideChatThreadUseCase,
    required this.markThreadDeletedUseCase,
    required this.archiveThreadUseCase,
    required this.leaveGroupUseCase,
    required this.joinGroupUseCase,
    required this.findOrCreateChatThreadUseCase,
    required this.searchChatThreadsUseCase,
  }) : super(ChatThreadListInitial());

  /// Fetches chat threads for the current user.
  Future<void> fetchChatThreads(String currentUserId) async {
    if (currentUserId.isEmpty) {
      emit(const ChatThreadListError('User ID cannot be empty'));
      return;
    }

    emit(ChatThreadListLoading());

    try {
      final threads = await getChatThreadsUseCase(currentUserId);
      emit(ChatThreadListLoaded(threads));
    } catch (e) {
      emit(ChatThreadListError('Failed to fetch chat threads: $e'));
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

  /// Creates a new chat thread.
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

  /// Hides a chat thread for the current user (soft delete).
  Future<void> hideChatThread(String threadId, String currentUserId) async {
    if (threadId.isEmpty) {
      emit(const ChatThreadListError('Invalid thread ID'));
      return;
    }

    emit(ChatThreadDeleting(threadId));

    try {
      await hideChatThreadUseCase(threadId, currentUserId);
      // Refresh the list after successful hiding
      await fetchChatThreads(currentUserId);
    } catch (e) {
      emit(ChatThreadListError('Failed to hide chat: ${e.toString()}'));
    }
  }

  /// Finds an existing chat thread or creates a temporary one for opening chat.
  /// Returns the chat thread that should be opened for messaging.
  Future<ChatThread> findOrCreateChatThreadForMessaging({
    required String currentUserId,
    required String friendId,
    required String friendName,
    required String friendAvatarUrl,
    bool forceCreateNew = false,
  }) async {
    try {
      return await findOrCreateChatThreadUseCase(
        currentUserId: currentUserId,
        friendId: friendId,
        friendName: friendName,
        friendAvatarUrl: friendAvatarUrl,
        forceCreateNew: forceCreateNew,
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
        unreadCounts: {},
        createdAt: now,
        updatedAt: now,
      );
    }
  }

  /// Marks a 1-1 chat thread as deleted for the current user.
  /// Sets visibility cutoff to hide old messages.
  Future<void> markThreadDeleted(String threadId, String currentUserId, {DateTime? lastMessageTime}) async {
    if (threadId.isEmpty) {
      emit(const ChatThreadListError('Invalid thread ID'));
      return;
    }

    emit(ChatThreadDeleting(threadId));

    try {
      await markThreadDeletedUseCase(
        threadId: threadId, 
        userId: currentUserId,
        lastMessageTime: lastMessageTime,
      );
      
      // Refresh the list after successful deletion
      await fetchChatThreads(currentUserId);
    } catch (e) {
      emit(ChatThreadListError('Failed to delete chat: ${e.toString()}'));
    }
  }

  /// Archives a chat thread for the current user.
  /// Hides the thread from inbox but doesn't set visibility cutoff.
  Future<void> archiveThread(String threadId, String currentUserId) async {
    if (threadId.isEmpty) {
      emit(const ChatThreadListError('Invalid thread ID'));
      return;
    }

    emit(ChatThreadDeleting(threadId));

    try {
      await archiveThreadUseCase(
        threadId: threadId,
        userId: currentUserId,
      );
      
      // Refresh the list after successful archiving
      await fetchChatThreads(currentUserId);
    } catch (e) {
      emit(ChatThreadListError('Failed to archive chat: ${e.toString()}'));
    }
  }

  /// Makes the current user leave a group chat.
  Future<void> leaveGroup(String threadId, String currentUserId) async {
    if (threadId.isEmpty) {
      emit(const ChatThreadListError('Invalid thread ID'));
      return;
    }

    emit(ChatThreadDeleting(threadId));

    try {
      await leaveGroupUseCase(
        threadId: threadId,
        userId: currentUserId,
      );
      
      // Refresh the list after successful leaving
      await fetchChatThreads(currentUserId);
    } catch (e) {
      emit(ChatThreadListError('Failed to leave group: ${e.toString()}'));
    }
  }

  /// Makes the current user join a group chat.
  Future<void> joinGroup(String threadId, String currentUserId) async {
    if (threadId.isEmpty) {
      emit(const ChatThreadListError('Invalid thread ID'));
      return;
    }

    emit(ChatThreadDeleting(threadId));

    try {
      await joinGroupUseCase(
        threadId: threadId,
        userId: currentUserId,
      );
      
      // Refresh the list after successful joining
      await fetchChatThreads(currentUserId);
    } catch (e) {
      emit(ChatThreadListError('Failed to join group: ${e.toString()}'));
    }
  }

  /// Unarchives (revives) a chat thread for the current user.
  /// Removes the user from hiddenFor list to make the thread visible again.
  Future<void> unarchiveThread(String threadId, String currentUserId) async {
    if (threadId.isEmpty) {
      emit(const ChatThreadListError('Invalid thread ID'));
      return;
    }
    
    if (currentUserId.isEmpty) {
      emit(const ChatThreadListError('Invalid user ID'));
      return;
    }

    try {
      // Use the existing reviveThreadForUser method in repository
      await getChatThreadsUseCase.repository.reviveThreadForUser(threadId, currentUserId);
      
      // Refresh the list after successful unarchiving
      await fetchChatThreads(currentUserId);
    } catch (e) {
      emit(ChatThreadListError('Failed to unarchive thread: ${e.toString()}'));
    }
  }

  /// Fetches archived chat threads for the current user.
  Future<void> fetchArchivedThreads(String currentUserId) async {
    if (currentUserId.isEmpty) {
      emit(const ChatThreadListError('User ID cannot be empty'));
      return;
    }

    emit(ChatThreadListLoading());

    try {
      final threads = await getArchivedThreadsUseCase(currentUserId);
      emit(ChatThreadListLoaded(threads));
    } catch (e) {
      emit(ChatThreadListError('Failed to load archived threads: ${e.toString()}'));
    }
  }
}
