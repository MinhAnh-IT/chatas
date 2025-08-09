import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_thread.dart';

class ChatThreadModel extends Equatable {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String avatarUrl;
  final List<String> members;
  final bool isGroup;
  final Map<String, int> unreadCounts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? groupAdminId;
  final String? groupDescription;

  const ChatThreadModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.avatarUrl,
    required this.members,
    required this.isGroup,
    required this.unreadCounts,
    required this.createdAt,
    required this.updatedAt,
    this.groupAdminId,
    this.groupDescription,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    lastMessage,
    lastMessageTime,
    avatarUrl,
    members,
    isGroup,
    unreadCounts,
    createdAt,
    updatedAt,
    groupAdminId,
    groupDescription,
  ];

  factory ChatThreadModel.fromJson(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('ChatThreadModel: Error parsing date string "$value": $e');
          return DateTime.now();
        }
      } else {
        print(
          'ChatThreadModel: Unexpected date type: ${value.runtimeType}, value: $value',
        );
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
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      groupAdminId: map['groupAdminId'],
      groupDescription: map['groupDescription'],
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
      'unreadCounts': unreadCounts,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'groupAdminId': groupAdminId,
      'groupDescription': groupDescription,
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
      unreadCounts: unreadCounts,
      createdAt: createdAt,
      updatedAt: updatedAt,
      groupAdminId: groupAdminId,
      groupDescription: groupDescription,
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
      unreadCounts: entity.unreadCounts,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      groupAdminId: entity.groupAdminId,
      groupDescription: entity.groupDescription,
    );
  }
}
