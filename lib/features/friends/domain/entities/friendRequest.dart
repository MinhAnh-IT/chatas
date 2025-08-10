class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime sentAt;
  final String status;
  final String senderName;
  final String receiverName;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.sentAt,
    this.status = 'pending',
    this.senderName = '',
    this.receiverName = '',
  });

  // Convenience getters for backward compatibility
  String get senderId => fromUserId;
  String get receiverId => toUserId;
  DateTime get createdAt => sentAt;
}
