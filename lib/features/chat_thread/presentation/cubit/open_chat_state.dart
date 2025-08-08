import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_thread.dart';

/// States for opening new chat with friends
abstract class OpenChatState extends Equatable {
  const OpenChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OpenChatInitial extends OpenChatState {}

/// Loading state when finding or creating chat thread
class OpenChatLoading extends OpenChatState {}

/// Successfully found or created chat thread - ready to navigate
class OpenChatReady extends OpenChatState {
  final ChatThread chatThread;

  const OpenChatReady(this.chatThread);

  @override
  List<Object?> get props => [chatThread];
}

/// Error state when failed to open chat
class OpenChatError extends OpenChatState {
  final String message;

  const OpenChatError(this.message);

  @override
  List<Object?> get props => [message];
}
