import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String friendId;
  final String userId;
  final String friendUserId;
  final DateTime createdAt;
  final String status;
  final DateTime? lastActive;
  final bool isOnline;
  final String? lastMessageId;
  final DateTime? lastMessageAt;

  Friend({
    required this.friendId,
    required this.userId,
    required this.friendUserId,
    required this.createdAt,
    this.status = "pending",
    this.lastActive,
    this.isOnline = false,
    this.lastMessageId,
    this.lastMessageAt,
  });

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      friendId: map['friendId'] as String,
      userId: map['userId'] as String,
      friendUserId: map['friendUserId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'] as String? ?? 'pending',
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] as Timestamp).toDate()
          : null,
      isOnline: map['isOnline'] as bool? ?? false,
      lastMessageId: map['lastMessageId'] as String?,
      lastMessageAt: map['lastMessageAt'] != null
          ? (map['lastMessageAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'friendId': friendId,
      'userId': userId,
      'friendUserId': friendUserId,
      'createdAt': createdAt,
      'status': status,
      'lastActive': lastActive,
      'isOnline': isOnline,
      'lastMessageId': lastMessageId,
      'lastMessageAt': lastMessageAt,
    };
  }
}
