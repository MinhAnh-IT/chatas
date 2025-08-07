import 'package:equatable/equatable.dart';

class ChatThread extends Equatable {
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

  const ChatThread({
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

  @override
  List<Object?> get props => [
    id,
    name,
    lastMessage,
    lastMessageTime,
    avatarUrl,
    members,
    isGroup,
    unreadCount,
    createdAt,
    updatedAt,
  ];
}
