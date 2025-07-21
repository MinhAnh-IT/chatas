class ChatThread {
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

  ChatThread({
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

}
