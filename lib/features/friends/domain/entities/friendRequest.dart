import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final String status;
  final DateTime? updatedAt;
  final String? senderName; // Optional: Tên người gửi
  final String? senderPhotoURL; // Optional: Ảnh đại diện người gửi

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    this.status = 'pending', // Giá trị mặc định là pending
    this.updatedAt,
    this.senderName,
    this.senderPhotoURL,
  });

  // Factory constructor để tạo từ Firestore
  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      id: map['id'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'] as String? ?? 'pending',
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      senderName: map['senderName'] as String?,
      senderPhotoURL: map['senderPhotoURL'] as String?,
    );
  }

  // Chuyển đổi sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'createdAt': createdAt,
      'status': status,
      'updatedAt': updatedAt,
      'senderName': senderName,
      'senderPhotoURL': senderPhotoURL,
    };
  }
}
