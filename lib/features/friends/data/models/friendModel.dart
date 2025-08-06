import "../../domain/entities/friend.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel {
  final String friendId;
  final String userId;
  final String friendUserId;
  final DateTime createdAt;
  final String status;
  final DateTime? lastActive;
  final bool isOnline;
  final String? lastMessageId;
  final DateTime? lastMessageAt;

  FriendModel({
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

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      } else {
        return DateTime.now();
      }
    }

    return FriendModel(
      friendId: json['friendId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      friendUserId: json['friendUserId'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
      status: json['status'] as String? ?? 'pending',
      lastActive: json['lastActive'] != null
          ? parseDate(json['lastActive'])
          : null,
      isOnline: json['isOnline'] as bool? ?? false,
      lastMessageId: json['lastMessageId'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? parseDate(json['lastMessageAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'userId': userId,
      'friendUserId': friendUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'isOnline': isOnline,
      'lastMessageId': lastMessageId,
      'lastMessageAt': lastMessageAt != null
          ? Timestamp.fromDate(lastMessageAt!)
          : null,
    };
  }

  Friend toEntity() {
    return Friend(
      friendId: friendId,
      userId: userId,
      friendUserId: friendUserId,
      createdAt: createdAt,
      status: status,
      lastActive: lastActive,
      isOnline: isOnline,
      lastMessageId: lastMessageId,
      lastMessageAt: lastMessageAt,
    );
  }

  factory FriendModel.fromEntity(Friend entity) {
    return FriendModel(
      friendId: entity.friendId,
      userId: entity.userId,
      friendUserId: entity.friendUserId,
      createdAt: entity.createdAt,
      status: entity.status,
      lastActive: entity.lastActive,
      isOnline: entity.isOnline,
      lastMessageId: entity.lastMessageId,
      lastMessageAt: entity.lastMessageAt,
    );
  }
}
