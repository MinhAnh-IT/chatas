import 'package:equatable/equatable.dart';

class ChatThread extends Equatable {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String avatarUrl;
  final List<String> members;
  final bool isGroup;
  final Map<String, int> unreadCounts; // Per-user unread counts
  final DateTime createdAt;
  final DateTime updatedAt;
  // Group specific fields
  final String? groupAdminId; // Admin user ID for group management
  final String? groupDescription; // Optional group description
  // Soft delete fields
  final List<String> hiddenFor; // List of user IDs who have hidden this thread

  const ChatThread({
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
    this.hiddenFor = const [],
  });

  /// Gets unread count for a specific user
  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  /// Check if user is group admin
  bool isUserAdmin(String userId) {
    return groupAdminId == userId;
  }

  /// Check if user can manage group (admin only)
  bool canUserManage(String userId) {
    return isGroup && isUserAdmin(userId);
  }

  /// Check if thread is hidden for a specific user
  bool isHiddenFor(String userId) {
    return hiddenFor.contains(userId);
  }

  /// Check if user can see this thread (is member and not hidden)
  bool isVisibleFor(String userId) {
    return members.contains(userId) && !isHiddenFor(userId);
  }

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
    hiddenFor,
  ];
}
