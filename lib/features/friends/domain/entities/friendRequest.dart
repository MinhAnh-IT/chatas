class FriendRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final String? status;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.status,
  });
}
