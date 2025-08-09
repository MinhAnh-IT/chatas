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

  // User-specific deletion
  final List<String>
  deletedFor; // List of user IDs who have deleted this message

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
    // User-specific deletion
    this.deletedFor = const [],
  });

  /// Checks if this message is from the specified user.
  bool isFromUser(String userId) {
    return senderId == userId;
  }

  /// Checks if this message has file attachments.
  bool get hasFileAttachment {
    return fileUrl != null && fileUrl!.isNotEmpty;
  }

  /// Checks if this message is an image.
  bool get isImage {
    return type == MessageType.image ||
        (fileType != null && fileType!.startsWith('image/'));
  }

  /// Checks if this message is a video.
  bool get isVideo {
    return type == MessageType.video ||
        (fileType != null && fileType!.startsWith('video/'));
  }

  /// Checks if this message is a file (document).
  bool get isFile {
    return type == MessageType.file ||
        (fileType != null &&
            !fileType!.startsWith('image/') &&
            !fileType!.startsWith('video/'));
  }

  /// Gets the formatted file size string.
  String get fileSizeString {
    if (fileSize == null) return '';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int size = fileSize!;
    int suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size ~/= 1024;
      suffixIndex++;
    }

    if (suffixIndex == 0) {
      return '${size}${suffixes[suffixIndex]}';
    } else {
      return '${size}.0${suffixes[suffixIndex]}';
    }
  }

  /// Checks if message is deleted for a specific user.
  bool isDeletedFor(String userId) {
    return deletedFor.contains(userId);
  }

  /// Checks if message is visible for a specific user.
  bool isVisibleFor(String userId) {
    return !isDeleted && !isDeletedFor(userId);
  }

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
    deletedFor,
  ];

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
    List<String>? deletedFor,
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
      deletedFor: deletedFor ?? this.deletedFor,
    );
  }
}
