import "../entities/friend.dart";
import "../entities/friendRequest.dart";

abstract class FriendRepository {
  Future<List<Friend>> getFriend(String userId);
  Future<void> sendFriendRequest(FriendRequest friendRequest);
  Future<void> acceptFriendRequest(String requestId, Friend friend);
  Future<void> rejectFriendRequest(String requestId);
  Future<void> removeFriend(String friendI);
  Future<List<FriendRequest>> getFriendRequest(String userId);
}
