class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime sentAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.sentAt,
  });
}
