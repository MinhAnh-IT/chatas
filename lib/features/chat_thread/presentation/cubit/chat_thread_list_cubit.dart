import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_chat_threads_usecase.dart';
import '../../domain/usecases/create_chat_thread_usecase.dart';
import 'chat_thread_list_state.dart';

class ChatThreadListCubit extends Cubit<ChatThreadListState> {
  final GetChatThreadsUseCase getChatThreadsUseCase;
  final CreateChatThreadUseCase createChatThreadUseCase;

  ChatThreadListCubit({
    required this.getChatThreadsUseCase,
    required this.createChatThreadUseCase,
  }) : super(ChatThreadListInitial());

  Future<void> fetchChatThreads() async {
    emit(ChatThreadListLoading());
    try {
      final threads = await getChatThreadsUseCase();
      emit(ChatThreadListLoaded(threads));
    } catch (e) {
      emit(ChatThreadListError(e.toString()));
    }
  }

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
}
