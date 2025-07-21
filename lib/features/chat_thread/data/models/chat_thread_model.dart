import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_thread.dart';

class ChatThreadModel {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String avatarUrl;
  final List<String> members;
  final bool isGroup;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatThreadModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.avatarUrl,
    required this.members,
    required this.isGroup,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else {
        return DateTime.now();
      }
    }
    return ChatThreadModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: parseDate(map['lastMessageTime']),
      avatarUrl: map['avatarUrl'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      isGroup: map['isGroup'] ?? false,
      unreadCount: map['unreadCount'] ?? 0,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'avatarUrl': avatarUrl,
      'members': members,
      'isGroup': isGroup,
      'unreadCount': unreadCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ChatThread toEntity() {
    return ChatThread(
      id: id,
      name: name,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      avatarUrl: avatarUrl,
      members: members,
      isGroup: isGroup,
      unreadCount: unreadCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ChatThreadModel.fromEntity(ChatThread entity) {
    return ChatThreadModel(
      id: entity.id,
      name: entity.name,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime,
      avatarUrl: entity.avatarUrl,
      members: entity.members,
      isGroup: entity.isGroup,
      unreadCount: entity.unreadCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
