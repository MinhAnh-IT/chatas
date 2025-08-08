import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_messages_stream_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/add_reaction_usecase.dart';
import '../../domain/usecases/remove_reaction_usecase.dart';
import '../../../chat_thread/domain/entities/chat_thread.dart';
import '../../../chat_thread/domain/usecases/send_first_message_usecase.dart';
import '../../constants/chat_message_page_constants.dart';
import 'chat_message_state.dart';

/// Cubit for managing chat message state and business logic.
/// Handles message loading, sending, reactions, and UI state management.
class ChatMessageCubit extends Cubit<ChatMessageState> {
  final GetMessagesStreamUseCase _getMessagesStreamUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final AddReactionUseCase _addReactionUseCase;
  final RemoveReactionUseCase _removeReactionUseCase;
  final SendFirstMessageUseCase _sendFirstMessageUseCase;

  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  String? _currentChatThreadId;
  ChatThread? _currentThread;
  bool _isTemporaryThread = false;

  ChatMessageCubit({
    required GetMessagesStreamUseCase getMessagesStreamUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required AddReactionUseCase addReactionUseCase,
    required RemoveReactionUseCase removeReactionUseCase,
    required SendFirstMessageUseCase sendFirstMessageUseCase,
  }) : _getMessagesStreamUseCase = getMessagesStreamUseCase,
       _sendMessageUseCase = sendMessageUseCase,
       _addReactionUseCase = addReactionUseCase,
       _removeReactionUseCase = removeReactionUseCase,
       _sendFirstMessageUseCase = sendFirstMessageUseCase,
       super(const ChatMessageInitial());

  /// Loads messages for a specific chat thread and sets up real-time updates.
  /// Subscribes to the message stream for automatic updates.
  Future<void> loadMessages(String chatThreadId) async {
    try {
      print('ChatMessageCubit: Loading messages for thread: $chatThreadId');
      emit(const ChatMessageLoading());
      _currentChatThreadId = chatThreadId;
      _currentThread = null; // Clear any temporary thread
      _isTemporaryThread = false;

      // Cancel any existing subscription
      await _messagesSubscription?.cancel();

      // Subscribe to real-time message updates
      _messagesSubscription = _getMessagesStreamUseCase(chatThreadId).listen(
        (messages) {
          print('ChatMessageCubit: Received ${messages.length} messages for thread $chatThreadId');
          emit(ChatMessageLoaded(messages: messages));
        },
        onError: (error) {
          print('ChatMessageCubit: Error loading messages for thread $chatThreadId: $error');
          emit(ChatMessageError(message: error.toString()));
        },
      );
    } catch (e) {
      print('ChatMessageCubit: Exception loading messages for thread $chatThreadId: $e');
      emit(ChatMessageError(message: e.toString()));
    }
  }

  /// Loads a temporary thread (not yet saved to database).
  /// Shows empty chat interface ready for first message.
  Future<void> loadTemporaryThread(ChatThread temporaryThread) async {
    try {
      emit(const ChatMessageLoading());
      _currentThread = temporaryThread;
      _currentChatThreadId = temporaryThread.id;
      _isTemporaryThread = true;

      // Cancel any existing subscription since temporary threads have no messages
      await _messagesSubscription?.cancel();

      // Show empty state for temporary thread
      emit(ChatMessageTemporary(tempThreadId: temporaryThread.id));
    } catch (e) {
      emit(ChatMessageError(message: e.toString()));
    }
  }

  /// Sends a new text message to the current chat thread.
  /// For temporary threads, creates the real thread first, then sends the message.
  /// Temporarily shows the message as sending before actual confirmation.
  Future<void> sendMessage(String content) async {
    if (_currentChatThreadId == null || content.trim().isEmpty) {
      return;
    }

    try {
      final currentState = state;
      
      // Handle temporary thread - create real thread first
      if (_isTemporaryThread && _currentThread != null) {
        // Create the first message
        final now = DateTime.now();
        final firstMessage = ChatMessage(
          id: 'msg_${now.millisecondsSinceEpoch}',
          chatThreadId: _currentThread!.id,
          senderId: ChatMessagePageConstants.temporaryUserId,
          senderName: ChatMessagePageConstants.temporaryUserName,
          senderAvatarUrl: ChatMessagePageConstants.temporaryAvatarUrl,
          content: content.trim(),
          type: MessageType.text,
          status: MessageStatus.sent,
          sentAt: now,
          createdAt: now,
          updatedAt: now,
        );
        
        final realThreadId = await _sendFirstMessageUseCase(
          chatThread: _currentThread!,
          message: firstMessage,
        );
        
        print('ChatMessageCubit: Created real thread with ID: $realThreadId');
        
        // Update to real thread
        _currentChatThreadId = realThreadId;
        _isTemporaryThread = false;
        _currentThread = null;
        
        // Wait a bit to ensure message is saved before subscribing to stream
        await Future.delayed(const Duration(milliseconds: 200));
        
        print('ChatMessageCubit: Loading messages for real thread: $realThreadId');
        
        // Start listening to the real thread's messages
        await loadMessages(realThreadId);
        return;
      }
      
      // Handle normal message sending for existing threads
      if (currentState is ChatMessageLoaded) {
        // Create a pending message
        final now = DateTime.now();
        final pendingMessage = ChatMessage(
          id: 'pending_${now.millisecondsSinceEpoch}',
          chatThreadId: _currentChatThreadId!,
          senderId: ChatMessagePageConstants.temporaryUserId,
          senderName: ChatMessagePageConstants.temporaryUserName,
          senderAvatarUrl: ChatMessagePageConstants.temporaryAvatarUrl,
          content: content.trim(),
          type: MessageType.text,
          status: MessageStatus.sending,
          sentAt: now,
          createdAt: now,
          updatedAt: now,
        );

        // Show pending message immediately
        emit(
          ChatMessageSending(
            messages: currentState.messages,
            pendingMessage: pendingMessage,
          ),
        );

        // Send the actual message
        await _sendMessageUseCase(
          chatThreadId: _currentChatThreadId!,
          content: content.trim(),
        );

        // Note: The real message will be received through the stream
        // so we don't need to manually update the state here
      }
    } catch (e) {
      emit(ChatMessageError(message: e.toString()));
    }
  }

  /// Toggles message selection to show/hide timestamp.
  /// Only one message can be selected at a time.
  void toggleMessageSelection(String messageId) {
    final currentState = state;
    if (currentState is ChatMessageLoaded) {
      final isCurrentlySelected = currentState.selectedMessageId == messageId;
      emit(
        currentState.copyWith(
          selectedMessageId: isCurrentlySelected ? null : messageId,
          clearSelection: isCurrentlySelected,
        ),
      );
    }
  }

  /// Clears the currently selected message.
  void clearMessageSelection() {
    final currentState = state;
    if (currentState is ChatMessageLoaded) {
      emit(currentState.copyWith(clearSelection: true));
    }
  }

  /// Adds a reaction to a specific message.
  /// Handles optimistic updates and error recovery.
  Future<void> addReaction(String messageId, ReactionType reaction) async {
    try {
      final currentState = state;
      if (currentState is ChatMessageLoaded) {
        emit(
          ChatMessageReactionAdding(
            messages: currentState.messages,
            messageId: messageId,
            reaction: reaction,
          ),
        );

        await _addReactionUseCase(messageId: messageId, reaction: reaction);

        // Note: The updated message will be received through the stream
        // so we don't need to manually update the state here
      }
    } catch (e) {
      emit(ChatMessageError(message: e.toString()));
    }
  }

  /// Removes a reaction from a specific message.
  /// Handles optimistic updates and error recovery.
  Future<void> removeReaction(String messageId, String userId) async {
    try {
      final currentState = state;
      if (currentState is ChatMessageLoaded) {
        await _removeReactionUseCase(messageId: messageId, userId: userId);

        // Note: The updated message will be received through the stream
        // so we don't need to manually update the state here
      }
    } catch (e) {
      emit(ChatMessageError(message: e.toString()));
    }
  }

  /// Refreshes the message list by reloading from the current chat thread.
  Future<void> refreshMessages() async {
    if (_currentChatThreadId != null) {
      await loadMessages(_currentChatThreadId!);
    }
  }

  /// Checks if a message is currently selected.
  bool isMessageSelected(String messageId) {
    final currentState = state;
    if (currentState is ChatMessageLoaded) {
      return currentState.selectedMessageId == messageId;
    }
    return false;
  }

  /// Gets the currently loaded messages.
  List<ChatMessage> get currentMessages {
    final currentState = state;
    if (currentState is ChatMessageLoaded) {
      return currentState.messages;
    } else if (currentState is ChatMessageSending) {
      return [...currentState.messages, currentState.pendingMessage];
    }
    return [];
  }

  /// Disposes resources and cancels subscriptions.
  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
}
