class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime sentAt;
  final String status;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.sentAt,
    this.status = 'pending',
  });
}
