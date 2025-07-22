import "package:chatas/features/friends/data/datasources/friendRequestDataSource.dart";
import "package:chatas/features/friends/data/models/friendRequestModel.dart";
import "package:chatas/features/friends/domain/entities/friend.dart";
import "package:chatas/features/friends/domain/entities/friendRequest.dart";
import "package:chatas/features/friends/domain/repositories/friendRepository.dart";

class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource _remoteDataSource;

  FriendRepositoryImpl({FriendRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? FriendRemoteDataSource();
  @override
  Future<List<Friend>> getFriend(String userId) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // mô phỏng độ trễ:>>>
    return _remoteDataSource.getFriends(userId);
  }

  @override
  Future<void> sendFriendRequest(FriendRequest friendRequest) async {
    await _remoteDataSource.sendFriendRequest(friendRequest);
  }

  @override
  Future<void> acceptFriendRequest(String requestId, Friend friend) async {
    await _remoteDataSource.acceptFriendRequest(requestId, friend);
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    await _remoteDataSource.rejectFriendRequest(requestId);
  }

  @override
  Future<void> removeFriend(String friendId) async {
    await _remoteDataSource.removeFriend(friendId);
  }

  @override
  Future<List<FriendRequest>> getFriendRequest(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _remoteDataSource.getFriendRequest(userId);
  }
}
