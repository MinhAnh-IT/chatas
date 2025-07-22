class Friend {
  final String id;
  final String userId;
  final String friendId;
  final DateTime createdAt;

  Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.createdAt,
  });

  // @override
  // String toString() {
  //   return 'Friend(id: $id, userId: $userId, friendId: $friendId, createdAt: $createdAt)';
  // }
}
