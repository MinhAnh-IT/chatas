import "../../domain/entities/friendRequest.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final String status;
  final DateTime? updatedAt;
  final String? senderName;
  final String? senderPhotoURL;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    this.status = 'pending',
    this.updatedAt,
    this.senderName,
    this.senderPhotoURL,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
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

    return FriendRequestModel(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
      status: json['status'] as String? ?? 'pending',
      updatedAt: json['updatedAt'] != null
          ? parseDate(json['updatedAt'])
          : null,
      senderName: json['senderName'] as String?,
      senderPhotoURL: json['senderPhotoURL'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'senderName': senderName,
      'senderPhotoURL': senderPhotoURL,
    };
  }

  FriendRequest toEntity() {
    return FriendRequest(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      createdAt: createdAt,
      status: status,
      updatedAt: updatedAt,
      senderName: senderName,
      senderPhotoURL: senderPhotoURL,
    );
  }

  factory FriendRequestModel.fromEntity(FriendRequest entity) {
    return FriendRequestModel(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      createdAt: entity.createdAt,
      status: entity.status,
      updatedAt: entity.updatedAt,
      senderName: entity.senderName,
      senderPhotoURL: entity.senderPhotoURL,
    );
  }
}
