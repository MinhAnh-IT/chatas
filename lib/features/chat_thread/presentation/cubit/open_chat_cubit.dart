import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/find_or_create_chat_thread_usecase.dart';
import 'open_chat_state.dart';

/// Cubit for handling opening new chat with friends
class OpenChatCubit extends Cubit<OpenChatState> {
  final FindOrCreateChatThreadUseCase findOrCreateChatThreadUseCase;

  OpenChatCubit({required this.findOrCreateChatThreadUseCase})
    : super(OpenChatInitial());

  /// Opens chat with a friend - finds existing thread or creates temporary one
  /// This method only prepares the chat thread for navigation
  /// The actual thread creation in database happens when first message is sent
  Future<void> openChatWithFriend({
    required String currentUserId,
    required String friendId,
    required String friendName,
    required String friendAvatarUrl,
    bool forceCreateNew = false,
  }) async {
    emit(OpenChatLoading());

    try {
      // Block rule: disallow opening chat if friendship is blocked in either direction
      // Check friend documents: `${currentUserId}_${friendId}` and `${friendId}_${currentUserId}`
      // We keep this as a soft check via repository if available, otherwise fallback in UI layer
      final chatThread = await findOrCreateChatThreadUseCase(
        currentUserId: currentUserId,
        friendId: friendId,
        friendName: friendName,
        friendAvatarUrl: friendAvatarUrl,
        forceCreateNew: forceCreateNew,
      );

      emit(OpenChatReady(chatThread));
    } catch (e) {
      emit(OpenChatError('Failed to open chat: ${e.toString()}'));
    }
  }

  /// Resets the state to initial
  void reset() {
    emit(OpenChatInitial());
  }
}
