import '../entities/friend.dart';
import '../entities/friendRequest.dart';

abstract class FriendRepository {
  // Friend operations
  Future<List<Friend>> getFriends(String userId);
  Future<void> addFriend(String userId, String friendUserId);
  Future<void> removeFriend(String userId, String friendUserId);
  Future<void> updateFriendStatus(String friendId, String status);
  Future<void> updateFriendOnlineStatus(String userId, bool isOnline);
  Future<void> updateLastMessage(
    String friendId,
    String messageId,
    DateTime timestamp,
  );

  // Friend Request operations
  Future<void> sendFriendRequest(FriendRequest friendRequest);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
  Future<void> cancelFriendRequest(String requestId);
  Future<List<FriendRequest>> getReceivedFriendRequests(String userId);
  Future<List<FriendRequest>> getSentFriendRequests(String userId);

  // Status check
  Future<String?> getFriendshipStatus(String userId, String otherUserId);
}
