import "../../domain/entities/friend.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel {
  final String friendId;
  final String nickName;
  final DateTime addAt;
  final bool isBlock;

  FriendModel({
    required this.friendId,
    required this.nickName,
    required this.addAt,
    this.isBlock = false,
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
      nickName: json['nickName'] as String? ?? '',
      addAt: parseDate(json['addAt']),
      isBlock: json['isBlock'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'nickName': nickName,
      'addAt': Timestamp.fromDate(addAt),
      'isBlock': isBlock,
    };
  }

  Friend toEntity() {
    return Friend(
      friendId: friendId,
      nickName: nickName,
      addAt: addAt,
      isBlock: isBlock,
    );
  }

  factory FriendModel.fromEntity(Friend entity) {
    return FriendModel(
      friendId: entity.friendId,
      nickName: entity.nickName,
      addAt: entity.addAt,
      isBlock: entity.isBlock,
    );
  }
}
