import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_chat_threads_usecase.dart';
import 'chat_thread_list_state.dart';

class ChatThreadListCubit extends Cubit<ChatThreadListState> {
  final GetChatThreadsUseCase getChatThreadsUseCase;

  ChatThreadListCubit(this.getChatThreadsUseCase) : super(ChatThreadListInitial());

  Future<void> fetchChatThreads() async {
    emit(ChatThreadListLoading());
    try {
      final threads = await getChatThreadsUseCase();
      emit(ChatThreadListLoaded(threads));
    } catch (e) {
      emit(ChatThreadListError(e.toString()));
    }
  }
}
