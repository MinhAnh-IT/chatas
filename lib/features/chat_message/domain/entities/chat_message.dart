import 'package:equatable/equatable.dart';

/// Enum representing different types of messages.
enum MessageType { text, image, file, system }

/// Enum representing message status.
enum MessageStatus { sending, sent, delivered, read, failed }

/// Enum representing reaction types for messages.
enum ReactionType { like, love, sad, angry, laugh, wow }

/// Represents a chat message entity with all its properties and behaviors.
/// This is the core domain model for chat messages in the application.
class ChatMessage extends Equatable {
  final String id;
  final String chatThreadId;
  final String senderId;
  final String senderName;
  final String senderAvatarUrl;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime sentAt;
  final DateTime? editedAt;
  final bool isDeleted;
  final Map<String, ReactionType> reactions; // userId -> reactionType
  final String? replyToMessageId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatMessage({
    required this.id,
    required this.chatThreadId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sending,
    required this.sentAt,
    this.editedAt,
    this.isDeleted = false,
    this.reactions = const {},
    this.replyToMessageId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Checks if this message is from the specified user.
  bool isFromUser(String userId) => senderId == userId;

  /// Checks if this message has any reactions.
  bool get hasReactions => reactions.isNotEmpty;

  /// Gets the count of a specific reaction type.
  int getReactionCount(ReactionType type) {
    return reactions.values.where((reaction) => reaction == type).length;
  }

  /// Checks if the specified user has reacted to this message.
  bool hasUserReacted(String userId) {
    return reactions.containsKey(userId);
  }

  /// Gets the reaction type of a specific user.
  ReactionType? getUserReaction(String userId) {
    return reactions[userId];
  }

  /// Creates a copy of this message with updated fields.
  ChatMessage copyWith({
    String? id,
    String? chatThreadId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? sentAt,
    DateTime? editedAt,
    bool? isDeleted,
    Map<String, ReactionType>? reactions,
    String? replyToMessageId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatThreadId: chatThreadId ?? this.chatThreadId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      reactions: reactions ?? this.reactions,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    chatThreadId,
    senderId,
    senderName,
    senderAvatarUrl,
    content,
    type,
    status,
    sentAt,
    editedAt,
    isDeleted,
    reactions,
    replyToMessageId,
    createdAt,
    updatedAt,
  ];
}
