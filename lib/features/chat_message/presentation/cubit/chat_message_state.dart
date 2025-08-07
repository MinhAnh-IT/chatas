import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

/// Base state for chat message feature.
abstract class ChatMessageState extends Equatable {
  const ChatMessageState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the chat message page is first loaded.
class ChatMessageInitial extends ChatMessageState {
  const ChatMessageInitial();
}

/// State when messages are being loaded from the data source.
class ChatMessageLoading extends ChatMessageState {
  const ChatMessageLoading();
}

/// State when messages have been successfully loaded.
class ChatMessageLoaded extends ChatMessageState {
  final List<ChatMessage> messages;
  final String? selectedMessageId; // For showing timestamp

  const ChatMessageLoaded({required this.messages, this.selectedMessageId});

  @override
  List<Object?> get props => [messages, selectedMessageId];

  /// Creates a copy of this state with updated values.
  ChatMessageLoaded copyWith({
    List<ChatMessage>? messages,
    String? selectedMessageId,
    bool clearSelection = false,
  }) {
    return ChatMessageLoaded(
      messages: messages ?? this.messages,
      selectedMessageId: clearSelection
          ? null
          : (selectedMessageId ?? this.selectedMessageId),
    );
  }
}

/// State when an error occurs while loading or managing messages.
class ChatMessageError extends ChatMessageState {
  final String message;

  const ChatMessageError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when a message is being sent.
class ChatMessageSending extends ChatMessageState {
  final List<ChatMessage> messages;
  final ChatMessage pendingMessage;

  const ChatMessageSending({
    required this.messages,
    required this.pendingMessage,
  });

  @override
  List<Object?> get props => [messages, pendingMessage];
}

/// State when a message has been successfully sent.
class ChatMessageSent extends ChatMessageState {
  final List<ChatMessage> messages;

  const ChatMessageSent({required this.messages});

  @override
  List<Object?> get props => [messages];
}

/// State when adding a reaction to a message.
class ChatMessageReactionAdding extends ChatMessageState {
  final List<ChatMessage> messages;
  final String messageId;
  final ReactionType reaction;

  const ChatMessageReactionAdding({
    required this.messages,
    required this.messageId,
    required this.reaction,
  });

  @override
  List<Object?> get props => [messages, messageId, reaction];
}

/// State when a reaction has been successfully added.
class ChatMessageReactionAdded extends ChatMessageState {
  final List<ChatMessage> messages;

  const ChatMessageReactionAdded({required this.messages});

  @override
  List<Object?> get props => [messages];
}
