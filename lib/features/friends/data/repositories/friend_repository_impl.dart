import '../../domain/entities/friend.dart';
import '../../domain/entities/friendRequest.dart';
import '../../domain/repositories/friend_repository.dart';
import '../datasources/friendDataSource.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource remoteDataSource;

  FriendRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Friend>> getFriends(String userId) async {
    return await remoteDataSource.getFriends(userId);
  }

  @override
  Future<void> addFriend(String userId, String friendUserId) async {
    await remoteDataSource.addFriend(userId, friendUserId);
  }

  @override
  Future<void> removeFriend(String userId, String friendUserId) async {
    await remoteDataSource.removeFriend(userId, friendUserId);
  }

  @override
  Future<void> updateFriendStatus(String friendId, String status) async {
    await remoteDataSource.updateFriendStatus(friendId, status);
  }

  @override
  Future<void> updateFriendOnlineStatus(String userId, bool isOnline) async {
    await remoteDataSource.updateFriendOnlineStatus(userId, isOnline);
  }

  @override
  Future<void> updateLastMessage(
    String friendId,
    String messageId,
    DateTime timestamp,
  ) async {
    await remoteDataSource.updateLastMessage(friendId, messageId, timestamp);
  }

  @override
  Future<void> sendFriendRequest(FriendRequest friendRequest) async {
    await remoteDataSource.sendFriendRequest(friendRequest);
  }

  @override
  Future<void> acceptFriendRequest(
    String requestId,
    String senderId,
    String receiverId,
  ) async {
    await remoteDataSource.acceptFriendRequest(requestId, senderId, receiverId);
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    await remoteDataSource.rejectFriendRequest(requestId);
  }

  @override
  Future<void> cancelFriendRequest(String senderId, String receiverId) async {
    await remoteDataSource.cancelFriendRequest(senderId, receiverId);
  }

  @override
  Future<List<FriendRequest>> getReceivedFriendRequests(String userId) async {
    return await remoteDataSource.getReceivedFriendRequests(userId);
  }

  @override
  Future<List<FriendRequest>> getSentFriendRequests(String userId) async {
    return await remoteDataSource.getSentFriendRequests(userId);
  }

  @override
  Future<String?> getFriendshipStatus(String userId, String otherUserId) async {
    return await remoteDataSource.getFriendshipStatus(userId, otherUserId);
  }

  @override
  Future<void> updateBlockStatus(
    String userId,
    String friendId,
    bool isBlock,
  ) async {
    await remoteDataSource.updateBlockStatus(userId, friendId, isBlock);
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(
    String query,
    String currentUserId,
  ) async {
    return await remoteDataSource.searchUsers(query, currentUserId);
  }
}
