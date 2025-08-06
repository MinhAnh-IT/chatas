import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friendModel.dart';
import '../models/friendRequestModel.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friendRequest.dart';
import "../../constants/FriendRemoteConstants.dart";

class FriendRemoteDataSource {
  final FirebaseFirestore firestore;

  FriendRemoteDataSource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  /// 1. Xem danh sách bạn bè
  Future<List<Friend>> getFriends(String userId) async {
    // Query friends where the current user is part of the friendship
    final snapshot = await firestore
        .collection(Friendremoteconstants.friendCollection)
        .where('friendId', isGreaterThanOrEqualTo: '${userId}_')
        .where('friendId', isLessThan: '${userId}_\uf8ff')
        .get();

    final snapshot2 = await firestore
        .collection(Friendremoteconstants.friendCollection)
        .where('friendId', isGreaterThanOrEqualTo: '')
        .where('friendId', isLessThan: '\uf8ff')
        .get();

    // Filter results to get friends of current user
    final allDocs = [...snapshot.docs, ...snapshot2.docs];
    final userFriends = allDocs
        .where(
          (doc) =>
              doc.id.startsWith('${userId}_') || doc.id.endsWith('_$userId'),
        )
        .toList();

    return userFriends
        .map((doc) => FriendModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  /// 2. Gửi lời mời kết bạn
  Future<void> sendFriendRequest(FriendRequest friendRequest) async {
    final model = FriendRequestModel.fromEntity(friendRequest);
    await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .doc(friendRequest.id)
        .set(model.toJson());
  }

  /// 3. Chấp nhận lời mời kết bạn
  Future<void> acceptFriendRequest(
    String requestId,
    String senderId,
    String receiverId,
  ) async {
    final batch = firestore.batch();

    // Update request status to accepted
    final requestRef = firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .doc(requestId);
    batch.update(requestRef, {'status': 'accepted'});

    // Add friend relationship for sender
    final friend1 = Friend(
      friendId: '${senderId}_$receiverId',
      nickName: 'Friend', // You might want to get actual user name
      addAt: DateTime.now(),
      isBlock: false,
    );
    final friend1Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc(friend1.friendId);
    batch.set(friend1Ref, FriendModel.fromEntity(friend1).toJson());

    // Add friend relationship for receiver
    final friend2 = Friend(
      friendId: '${receiverId}_$senderId',
      nickName: 'Friend', // You might want to get actual user name
      addAt: DateTime.now(),
      isBlock: false,
    );
    final friend2Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc(friend2.friendId);
    batch.set(friend2Ref, FriendModel.fromEntity(friend2).toJson());

    await batch.commit();
  }

  /// 4. Từ chối lời mời kết bạn
  Future<void> rejectFriendRequest(String requestId) async {
    await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .doc(requestId)
        .update({'status': 'rejected'});
  }

  /// 5. Xóa bạn bè
  Future<void> removeFriend(String userId, String friendId) async {
    final batch = firestore.batch();

    // Remove friend relationship for user
    final friend1Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc('${userId}_$friendId');
    batch.delete(friend1Ref);

    // Remove friend relationship for friend
    final friend2Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc('${friendId}_$userId');
    batch.delete(friend2Ref);

    await batch.commit();
  }

  /// 6. Lấy danh sách lời mời kết bạn nhận được
  Future<List<FriendRequest>> getReceivedFriendRequests(String userId) async {
    final snapshot = await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs
        .map((doc) => FriendRequestModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  /// 7. Lấy danh sách lời mời kết bạn đã gửi
  Future<List<FriendRequest>> getSentFriendRequests(String userId) async {
    final snapshot = await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs
        .map((doc) => FriendRequestModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  /// 8. Kiểm tra trạng thái kết bạn
  Future<String?> getFriendshipStatus(String userId, String otherUserId) async {
    // Check if they are already friends
    final friendSnapshot = await firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc('${userId}_$otherUserId')
        .get();

    if (friendSnapshot.exists) {
      return 'friends';
    }

    // Check if there's a pending request from current user
    final sentRequestSnapshot = await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: otherUserId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (sentRequestSnapshot.docs.isNotEmpty) {
      return 'request_sent';
    }

    // Check if there's a pending request to current user
    final receivedRequestSnapshot = await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (receivedRequestSnapshot.docs.isNotEmpty) {
      return 'request_received';
    }

    return null; // No relationship
  }

  /// 9. Hủy lời mời kết bạn đã gửi
  Future<void> cancelFriendRequest(String senderId, String receiverId) async {
    final snapshot = await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending')
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// 10. Thêm bạn (tạo quan hệ bạn bè trực tiếp)
  Future<void> addFriend(String userId, String friendUserId) async {
    final batch = firestore.batch();
    final now = DateTime.now();

    // Add friend relationship for user
    final friend1 = Friend(
      friendId: '${userId}_$friendUserId',
      nickName: 'Friend', // You might want to get actual user name
      addAt: now,
      isBlock: false,
    );
    final friend1Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc(friend1.friendId);
    batch.set(friend1Ref, FriendModel.fromEntity(friend1).toJson());

    // Add friend relationship for friend
    final friend2 = Friend(
      friendId: '${friendUserId}_$userId',
      nickName: 'Friend', // You might want to get actual user name
      addAt: now,
      isBlock: false,
    );
    final friend2Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc(friend2.friendId);
    batch.set(friend2Ref, FriendModel.fromEntity(friend2).toJson());

    await batch.commit();
  }

  /// 11. Cập nhật trạng thái bạn bè
  Future<void> updateFriendStatus(String friendId, String status) async {
    await firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc(friendId)
        .update({'status': status});
  }

  /// 12. Cập nhật trạng thái online
  Future<void> updateFriendOnlineStatus(String userId, bool isOnline) async {
    final now = DateTime.now();
    final updateData = <String, dynamic>{'isOnline': isOnline};

    if (!isOnline) {
      updateData['lastActive'] = Timestamp.fromDate(now);
    }

    // Update all friend relationships where this user is involved
    final userFriendsSnapshot = await firestore
        .collection(Friendremoteconstants.friendCollection)
        .where('userId', isEqualTo: userId)
        .get();

    final batch = firestore.batch();
    for (final doc in userFriendsSnapshot.docs) {
      batch.update(doc.reference, updateData);
    }
    await batch.commit();
  }

  /// 13. Cập nhật tin nhắn cuối cùng
  Future<void> updateLastMessage(
    String friendId,
    String messageId,
    DateTime timestamp,
  ) async {
    await firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc(friendId)
        .update({
          'lastMessageId': messageId,
          'lastMessageAt': Timestamp.fromDate(timestamp),
        });
  }

  /// 14. Cập nhật trạng thái block/unblock bạn bè
  Future<void> updateBlockStatus(
    String userId,
    String friendId,
    bool isBlock,
  ) async {
    await firestore
        .collection(Friendremoteconstants.friendCollection)
        .where('userId', isEqualTo: userId)
        .where('friendId', isEqualTo: friendId)
        .get()
        .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final batch = firestore.batch();
            for (final doc in snapshot.docs) {
              batch.update(doc.reference, {'isBlock': isBlock});
            }
            return batch.commit();
          }
        });
  }
}
