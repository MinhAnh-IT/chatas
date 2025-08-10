import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friendRequest.dart';

class FriendRequestModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime sentAt;
  final String status;
  final String senderName;
  final String receiverName;

  FriendRequestModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.sentAt,
    this.status = 'pending',
    this.senderName = '',
    this.receiverName = '',
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] as String? ?? '',
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      sentAt: (json['sentAt'] as Timestamp).toDate(),
      status: json['status'] as String? ?? 'pending',
      senderName: json['senderName'] as String? ?? '',
      receiverName: json['receiverName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'sentAt': Timestamp.fromDate(sentAt),
      'status': status,
      'senderName': senderName,
      'receiverName': receiverName,
    };
  }

  FriendRequest toEntity() {
    return FriendRequest(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      sentAt: sentAt,
      status: status,
      senderName: senderName,
      receiverName: receiverName,
    );
  }

  factory FriendRequestModel.fromEntity(FriendRequest friendRequest) {
    return FriendRequestModel(
      id: friendRequest.id,
      fromUserId: friendRequest.fromUserId,
      toUserId: friendRequest.toUserId,
      sentAt: friendRequest.sentAt,
      status: friendRequest.status,
      senderName: friendRequest.senderName,
      receiverName: friendRequest.receiverName,
    );
  }
}
