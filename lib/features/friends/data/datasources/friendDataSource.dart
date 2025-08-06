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
    final snapshot = await firestore
        .collection(Friendremoteconstants.friendCollection)
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
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
      id: '${senderId}_$receiverId',
      userId: senderId,
      friendId: receiverId,
      createdAt: DateTime.now(),
    );
    final friend1Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc(friend1.id);
    batch.set(friend1Ref, FriendModel.fromEntity(friend1).toJson());

    // Add friend relationship for receiver
    final friend2 = Friend(
      id: '${receiverId}_$senderId',
      userId: receiverId,
      friendId: senderId,
      createdAt: DateTime.now(),
    );
    final friend2Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc(friend2.id);
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
}
