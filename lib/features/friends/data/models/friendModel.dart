import "../../domain/entities/friend.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel {
  final String id;
  final String userId;
  final String friendId;
  final DateTime createdAt;

  FriendModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.createdAt,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else {
        return DateTime.now();
      }
    }

    return FriendModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      friendId: json['friendId'] ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'createdAt': createdAt,
    };
  }

  Friend toEntity() {
    return Friend(
      id: id,
      userId: userId,
      friendId: friendId,
      createdAt: createdAt,
    );
  }

  factory FriendModel.fromEntity(Friend friend) {
    return FriendModel(
      id: friend.id,
      userId: friend.userId,
      friendId: friend.friendId,
      createdAt: friend.createdAt,
    );
  }
}
