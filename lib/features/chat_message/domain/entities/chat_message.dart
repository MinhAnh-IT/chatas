import 'package:equatable/equatable.dart';

/// Enum representing different types of messages.
enum MessageType { text, image, video, file, system }

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

  // File attachment properties
  final String? fileUrl; // Cloudinary URL for file/image/video
  final String? fileName; // Original file name
  final String?
  fileType; // MIME type (image/jpeg, video/mp4, application/pdf, etc.)
  final int? fileSize; // File size in bytes
  final String? thumbnailUrl; // Thumbnail URL for videos/documents

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
    // File attachment properties
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.fileSize,
    this.thumbnailUrl,
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

  /// Checks if this message has a file attachment.
  bool get hasFileAttachment => fileUrl != null && fileUrl!.isNotEmpty;

  /// Checks if this message is an image.
  bool get isImage => type == MessageType.image;

  /// Checks if this message is a video.
  bool get isVideo => type == MessageType.video;

  /// Checks if this message is a file.
  bool get isFile => type == MessageType.file;

  /// Gets formatted file size string.
  String get fileSizeString {
    if (fileSize == null) return '';
    final bytes = fileSize!;
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
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
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? thumbnailUrl,
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
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
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
    fileUrl,
    fileName,
    fileType,
    fileSize,
    thumbnailUrl,
  ];
}
