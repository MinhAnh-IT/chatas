import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friendRequest.dart';

class FriendRequestModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime sentAt;

  FriendRequestModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.sentAt,
  });

  /// Tạo từ JSON (Firestore data)
  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] as String? ?? '',
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      sentAt: (json['sentAt'] as Timestamp).toDate(),
    );
  }

  /// Convert sang JSON để lưu vào Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }

  /// Convert từ Entity sang Model
  factory FriendRequestModel.fromEntity(FriendRequest friendRequest) {
    return FriendRequestModel(
      id: friendRequest.id,
      fromUserId: friendRequest.fromUserId,
      toUserId: friendRequest.toUserId,
      sentAt: friendRequest.sentAt,
    );
  }

  /// Convert từ Model sang Entity
  FriendRequest toEntity() {
    return FriendRequest(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      sentAt: sentAt,
    );
  }
}
