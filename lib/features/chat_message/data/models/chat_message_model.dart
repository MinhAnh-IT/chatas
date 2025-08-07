import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';

/// Data model for chat messages.
/// Handles serialization/deserialization between Firestore and domain entities.
class ChatMessageModel extends Equatable {
  final String id;
  final String chatThreadId;
  final String senderId;
  final String senderName;
  final String senderAvatarUrl;
  final String content;
  final String type;
  final String status;
  final DateTime sentAt;
  final DateTime? editedAt;
  final bool isDeleted;
  final Map<String, String> reactions;
  final String? replyToMessageId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatMessageModel({
    required this.id,
    required this.chatThreadId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.content,
    required this.type,
    required this.status,
    required this.sentAt,
    this.editedAt,
    this.isDeleted = false,
    this.reactions = const {},
    this.replyToMessageId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [ChatMessageModel] from Firestore document data.
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else {
        return DateTime.now();
      }
    }

    return ChatMessageModel(
      id: json['id'] ?? '',
      chatThreadId: json['chatThreadId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatarUrl: json['senderAvatarUrl'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      status: json['status'] ?? 'sending',
      sentAt: parseDate(json['sentAt']),
      editedAt: json['editedAt'] != null ? parseDate(json['editedAt']) : null,
      isDeleted: json['isDeleted'] ?? false,
      reactions: Map<String, String>.from(json['reactions'] ?? {}),
      replyToMessageId: json['replyToMessageId'],
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  /// Converts this model to a JSON map for Firestore storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatThreadId': chatThreadId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'content': content,
      'type': type,
      'status': status,
      'sentAt': sentAt,
      'editedAt': editedAt,
      'isDeleted': isDeleted,
      'reactions': reactions,
      'replyToMessageId': replyToMessageId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Converts this model to a domain entity.
  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      chatThreadId: chatThreadId,
      senderId: senderId,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      content: content,
      type: _parseMessageType(type),
      status: _parseMessageStatus(status),
      sentAt: sentAt,
      editedAt: editedAt,
      isDeleted: isDeleted,
      reactions: _parseReactions(reactions),
      replyToMessageId: replyToMessageId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a model from a domain entity.
  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      chatThreadId: entity.chatThreadId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderAvatarUrl: entity.senderAvatarUrl,
      content: entity.content,
      type: _messageTypeToString(entity.type),
      status: _messageStatusToString(entity.status),
      sentAt: entity.sentAt,
      editedAt: entity.editedAt,
      isDeleted: entity.isDeleted,
      reactions: _reactionsToString(entity.reactions),
      replyToMessageId: entity.replyToMessageId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Parses string to MessageType enum.
  static MessageType _parseMessageType(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  /// Converts MessageType enum to string.
  static String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.file:
        return 'file';
      case MessageType.system:
        return 'system';
    }
  }

  /// Parses string to MessageStatus enum.
  static MessageStatus _parseMessageStatus(String status) {
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sending;
    }
  }

  /// Converts MessageStatus enum to string.
  static String _messageStatusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 'sending';
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      case MessageStatus.failed:
        return 'failed';
    }
  }

  /// Parses string reactions map to ReactionType enum map.
  static Map<String, ReactionType> _parseReactions(Map<String, String> reactions) {
    final Map<String, ReactionType> result = {};
    reactions.forEach((userId, reactionString) {
      final reaction = _parseReactionType(reactionString);
      if (reaction != null) {
        result[userId] = reaction;
      }
    });
    return result;
  }

  /// Converts ReactionType enum map to string map.
  static Map<String, String> _reactionsToString(Map<String, ReactionType> reactions) {
    final Map<String, String> result = {};
    reactions.forEach((userId, reaction) {
      result[userId] = _reactionTypeToString(reaction);
    });
    return result;
  }

  /// Parses string to ReactionType enum.
  static ReactionType? _parseReactionType(String reaction) {
    switch (reaction) {
      case 'like':
        return ReactionType.like;
      case 'love':
        return ReactionType.love;
      case 'sad':
        return ReactionType.sad;
      case 'angry':
        return ReactionType.angry;
      case 'laugh':
        return ReactionType.laugh;
      case 'wow':
        return ReactionType.wow;
      default:
        return null;
    }
  }

  /// Converts ReactionType enum to string.
  static String _reactionTypeToString(ReactionType reaction) {
    switch (reaction) {
      case ReactionType.like:
        return 'like';
      case ReactionType.love:
        return 'love';
      case ReactionType.sad:
        return 'sad';
      case ReactionType.angry:
        return 'angry';
      case ReactionType.laugh:
        return 'laugh';
      case ReactionType.wow:
        return 'wow';
    }
  }

  @override
  List<Object?> get props => [
    id, chatThreadId, senderId, senderName, senderAvatarUrl,
    content, type, status, sentAt, editedAt, isDeleted,
    reactions, replyToMessageId, createdAt, updatedAt,
  ];
}
