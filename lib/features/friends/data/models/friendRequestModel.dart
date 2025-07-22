import "../../domain/entities/friendRequest.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final String? status;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    this.status,
  });
  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else {
        return DateTime.now();
      }
    }

    return FriendRequestModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      createdAt: parseDate(json['createdAt']),
      status: json['status'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'createdAt': createdAt,
      'status': status,
    };
  }

  FriendRequest toEntity() {
    return FriendRequest(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      createdAt: createdAt,
      status: status,
    );
  }

  factory FriendRequestModel.fromEntity(FriendRequest request) {
    return FriendRequestModel(
      id: request.id,
      senderId: request.senderId,
      receiverId: request.receiverId,
      createdAt: request.createdAt,
      status: request.status,
    );
  }
}
