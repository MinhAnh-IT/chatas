import 'package:equatable/equatable.dart';

class ChatThread extends Equatable {
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
  final String? groupAdminId; // Admin user ID for group management
  final String? groupDescription; // Optional group description
  // Soft delete fields
  final List<String> hiddenFor; // List of user IDs who have hidden this thread
  // For 1-1 chats: timestamp when the chat was last recreated (after deletion)
  final DateTime? lastRecreatedAt;
  // For 1-1 chats: visibility cutoff per user (messages before this timestamp are hidden)
  final Map<String, DateTime> visibilityCutoff;
  // For group chats: when each user joined the group
  final Map<String, DateTime> joinedAt;

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
    this.lastRecreatedAt,
    this.visibilityCutoff = const {},
    this.joinedAt = const {},
  });

  /// Check if thread is hidden for a specific user
  bool isHiddenFor(String userId) {
    return hiddenFor.contains(userId);
  }

  /// Check if user can see this thread (is member and not hidden)
  bool isVisibleFor(String userId) {
    return members.contains(userId) && !isHiddenFor(userId);
  }

  /// Check if the specified user is the admin of this group
  bool isUserAdmin(String userId) {
    return isGroup && groupAdminId == userId;
  }

  /// Check if the specified user can manage this group (is admin)
  bool canUserManage(String userId) {
    return isUserAdmin(userId);
  }

  /// Get unread count for a specific user
  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  /// Get the timestamp from which messages should be visible for a user
  /// For 1-1 chats: returns visibilityCutoff timestamp
  /// For group chats: returns joinedAt timestamp
  DateTime? getVisibleMessagesFrom(String userId) {
    if (isGroup) {
      return joinedAt[userId]; // Only see messages after join time
    } else {
      return visibilityCutoff[userId]; // Only see messages after visibility cutoff
    }
  }

  /// Mark thread as deleted for a specific user (1-1 chats only)
  /// This sets the visibility cutoff to hide old messages
  ChatThread markDeletedFor(
    String userId,
    DateTime now, {
    DateTime? lastMsgTime,
  }) {
    assert(!isGroup, 'markDeletedFor only applies to 1-1 chats');

    // Set cutoff to max of now and last message time to avoid exposing recent messages
    final cutoff = (lastMsgTime != null && lastMsgTime.isAfter(now))
        ? lastMsgTime
        : now;

    // Add user to hiddenFor if not already there
    final newHidden = hiddenFor.contains(userId)
        ? hiddenFor
        : [...hiddenFor, userId];

    // Set visibility cutoff for this user
    final newCutoff = Map<String, DateTime>.from(visibilityCutoff)
      ..[userId] = cutoff;

    return copyWith(
      hiddenFor: newHidden,
      visibilityCutoff: newCutoff,
      updatedAt: now,
    );
  }

  /// Archive thread for a specific user (applies to both 1-1 and group chats)
  /// This only hides from inbox, doesn't set cutoff
  ChatThread archiveFor(String userId, DateTime now) {
    final newHidden = hiddenFor.contains(userId)
        ? hiddenFor
        : [...hiddenFor, userId];
    return copyWith(hiddenFor: newHidden, updatedAt: now);
  }

  /// Revive thread for a specific user (show in inbox again)
  /// Keeps cutoff (1-1) or joinedAt (group) intact
  ChatThread reviveFor(String userId, DateTime now) {
    final newHidden = hiddenFor.where((u) => u != userId).toList();
    return copyWith(hiddenFor: newHidden, updatedAt: now);
  }

  /// Leave group for a specific user (group chats only)
  /// Removes user from members and joinedAt
  ChatThread leaveGroupFor(String userId, DateTime now) {
    assert(isGroup, 'leaveGroupFor only applies to group chats');
    final newMembers = members.where((u) => u != userId).toList();
    final newJoinedAt = Map<String, DateTime>.from(joinedAt)..remove(userId);
    return copyWith(members: newMembers, joinedAt: newJoinedAt, updatedAt: now);
  }

  /// Join group for a specific user (group chats only)
  /// Adds user to members and sets joinedAt timestamp
  ChatThread joinGroupFor(String userId, DateTime now) {
    assert(isGroup, 'joinGroupFor only applies to group chats');
    final newMembers = members.contains(userId)
        ? members
        : [...members, userId];
    final newJoinedAt = Map<String, DateTime>.from(joinedAt)..[userId] = now;
    return copyWith(members: newMembers, joinedAt: newJoinedAt, updatedAt: now);
  }

  /// Check if user is a member of this thread
  bool isMember(String userId) {
    return members.contains(userId);
  }

  /// Get the other member in a 1-1 chat
  String? getOtherMember(String currentUserId) {
    if (!isGroup && members.length == 2) {
      return members.firstWhere(
        (member) => member != currentUserId,
        orElse: () => '',
      );
    }
    return null;
  }

  /// Generate thread ID for 1-1 chats based on member IDs
  static String generate1v1ThreadId(String user1, String user2) {
    final sortedMembers = [user1, user2]..sort();
    return '${sortedMembers[0]}_${sortedMembers[1]}';
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
    lastRecreatedAt,
    visibilityCutoff,
    joinedAt,
  ];

  ChatThread copyWith({
    String? id,
    String? name,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? avatarUrl,
    List<String>? members,
    bool? isGroup,
    Map<String, int>? unreadCounts,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? groupAdminId,
    String? groupDescription,
    List<String>? hiddenFor,
    DateTime? lastRecreatedAt,
    Map<String, DateTime>? visibilityCutoff,
    Map<String, DateTime>? joinedAt,
  }) {
    return ChatThread(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      members: members ?? this.members,
      isGroup: isGroup ?? this.isGroup,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      groupAdminId: groupAdminId ?? this.groupAdminId,
      groupDescription: groupDescription ?? this.groupDescription,
      hiddenFor: hiddenFor ?? this.hiddenFor,
      lastRecreatedAt: lastRecreatedAt ?? this.lastRecreatedAt,
      visibilityCutoff: visibilityCutoff ?? this.visibilityCutoff,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
