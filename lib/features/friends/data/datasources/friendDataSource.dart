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

  /// Xem danh sách bạn bè
  Future<List<Friend>> getFriends(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID không được để trống');
      }
      final snapshot = await firestore
          .collection(Friendremoteconstants.friendCollection)
          .where('friendId', isGreaterThanOrEqualTo: '${userId}_')
          .where('friendId', isLessThan: '${userId}_\uf8ff')
          .get();
      return snapshot.docs
          .map((doc) => FriendModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách bạn bè: $e');
    }
  }

  /// Gửi lời mời kết bạn
  Future<void> sendFriendRequest(FriendRequest friendRequest) async {
    try {
      final model = FriendRequestModel.fromEntity(friendRequest);
      await firestore
          .collection(Friendremoteconstants.friendRequestCollection)
          .doc(friendRequest.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Không thể gửi lời mời kết bạn: $e');
    }
  }

  /// Chấp nhận lời mời kết bạn
  Future<void> acceptFriendRequest(
    String requestId,
    String senderId,
    String receiverId,
  ) async {
    try {
      final batch = firestore.batch();
      final requestRef = firestore
          .collection(Friendremoteconstants.friendRequestCollection)
          .doc(requestId);
      batch.update(requestRef, {'status': 'accepted'});

      // Lấy tên người dùng từ collection users
      final senderDoc = await firestore.collection('users').doc(senderId).get();
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverId)
          .get();
      final senderName = senderDoc.data()?['name'] ?? 'Friend';
      final receiverName = receiverDoc.data()?['name'] ?? 'Friend';

      final friend1 = Friend(
        friendId: '${senderId}_$receiverId',
        nickName: receiverName,
        addAt: DateTime.now(),
        isBlock: false,
      );
      final friend1Ref = firestore
          .collection(Friendremoteconstants.friendCollection)
          .doc(friend1.friendId);
      batch.set(friend1Ref, FriendModel.fromEntity(friend1).toJson());

      final friend2 = Friend(
        friendId: '${receiverId}_$senderId',
        nickName: senderName,
        addAt: DateTime.now(),
        isBlock: false,
      );
      final friend2Ref = firestore
          .collection(Friendremoteconstants.friendCollection)
          .doc(friend2.friendId);
      batch.set(friend2Ref, FriendModel.fromEntity(friend2).toJson());

      await batch.commit();
    } catch (e) {
      throw Exception('Không thể chấp nhận lời mời kết bạn: $e');
    }
  }

  /// Từ chối lời mời kết bạn
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await firestore
          .collection(Friendremoteconstants.friendRequestCollection)
          .doc(requestId)
          .update({'status': 'rejected'});
    } catch (e) {
      throw Exception('Không thể từ chối lời mời kết bạn: $e');
    }
  }

  /// Xóa bạn bè
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      final batch = firestore.batch();
      final friend1Ref = firestore
          .collection(Friendremoteconstants.friendCollection)
          .doc('${userId}_$friendId');
      batch.delete(friend1Ref);
      final friend2Ref = firestore
          .collection(Friendremoteconstants.friendCollection)
          .doc('${friendId}_$userId');
      batch.delete(friend2Ref);
      await batch.commit();
    } catch (e) {
      throw Exception('Không thể xóa bạn bè: $e');
    }
  }

  /// Lấy danh sách lời mời kết bạn nhận được
  Future<List<FriendRequest>> getReceivedFriendRequests(String userId) async {
    try {
      final snapshot = await firestore
          .collection(Friendremoteconstants.friendRequestCollection)
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs
          .map((doc) => FriendRequestModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách lời mời nhận được: $e');
    }
  }

  /// Lấy danh sách lời mời kết bạn đã gửi
  Future<List<FriendRequest>> getSentFriendRequests(String userId) async {
    try {
      final snapshot = await firestore
          .collection(Friendremoteconstants.friendRequestCollection)
          .where('senderId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs
          .map((doc) => FriendRequestModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách lời mời đã gửi: $e');
    }
  }

  /// Kiểm tra trạng thái kết bạn
  Future<String?> getFriendshipStatus(String userId, String otherUserId) async {
    try {
      final friendSnapshot = await firestore
          .collection(Friendremoteconstants.friendCollection)
          .doc('${userId}_$otherUserId')
          .get();
      if (friendSnapshot.exists) {
        return 'friends';
      }

      final sentRequestSnapshot = await firestore
          .collection(Friendremoteconstants.friendRequestCollection)
          .where('senderId', isEqualTo: userId)
          .where('receiverId', isEqualTo: otherUserId)
          .where('status', isEqualTo: 'pending')
          .get();
      if (sentRequestSnapshot.docs.isNotEmpty) {
        return 'request_sent';
      }

      final receivedRequestSnapshot = await firestore
          .collection(Friendremoteconstants.friendRequestCollection)
          .where('senderId', isEqualTo: otherUserId)
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();
      if (receivedRequestSnapshot.docs.isNotEmpty) {
        return 'request_received';
      }

      return null;
    } catch (e) {
      throw Exception('Không thể kiểm tra trạng thái kết bạn: $e');
    }
  }

  /// Hủy lời mời kết bạn đã gửi
  Future<void> cancelFriendRequest(String senderId, String receiverId) async {
    try {
      final snapshot = await firestore
          .collection(Friendremoteconstants.friendRequestCollection)
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();
      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Không thể hủy lời mời kết bạn: $e');
    }
  }

  /// Thêm bạn (tạo quan hệ bạn bè trực tiếp)
  Future<void> addFriend(String userId, String friendUserId) async {
    try {
      final batch = firestore.batch();
      final now = DateTime.now();
      final userDoc = await firestore.collection('users').doc(userId).get();
      final friendDoc = await firestore
          .collection('users')
          .doc(friendUserId)
          .get();
      final userName = userDoc.data()?['name'] ?? 'Friend';
      final friendName = friendDoc.data()?['name'] ?? 'Friend';

      final friend1 = Friend(
        friendId: '${userId}_$friendUserId',
        nickName: friendName,
        addAt: now,
        isBlock: false,
      );
      final friend1Ref = firestore
          .collection(Friendremoteconstants.friendCollection)
          .doc(friend1.friendId);
      batch.set(friend1Ref, FriendModel.fromEntity(friend1).toJson());

      final friend2 = Friend(
        friendId: '${friendUserId}_$userId',
        nickName: userName,
        addAt: now,
        isBlock: false,
      );
      final friend2Ref = firestore
          .collection(Friendremoteconstants.friendCollection)
          .doc(friend2.friendId);
      batch.set(friend2Ref, FriendModel.fromEntity(friend2).toJson());

      await batch.commit();
    } catch (e) {
      throw Exception('Không thể thêm bạn bè: $e');
    }
  }

  /// Cập nhật trạng thái bạn bè
  Future<void> updateFriendStatus(String friendId, String status) async {
    try {
      await firestore
          .collection(Friendremoteconstants.friendCollection)
          .doc(friendId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái bạn bè: $e');
    }
  }

  /// Cập nhật trạng thái online
  Future<void> updateFriendOnlineStatus(String userId, bool isOnline) async {
    try {
      final now = DateTime.now();
      final updateData = <String, dynamic>{'isOnline': isOnline};
      if (!isOnline) {
        updateData['lastActive'] = Timestamp.fromDate(now);
      }

      final userFriendsSnapshot = await firestore
          .collection(Friendremoteconstants.friendCollection)
          .where('friendId', isGreaterThanOrEqualTo: '${userId}_')
          .where('friendId', isLessThan: '${userId}_\uf8ff')
          .get();

      if (userFriendsSnapshot.docs.length > 500) {
        throw Exception('Quá nhiều bạn bè để cập nhật trong một batch');
      }

      final batch = firestore.batch();
      for (final doc in userFriendsSnapshot.docs) {
        batch.update(doc.reference, updateData);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái online: $e');
    }
  }

  /// Cập nhật tin nhắn cuối cùng
  Future<void> updateLastMessage(
    String friendId,
    String messageId,
    DateTime timestamp,
  ) async {
    try {
      await firestore
          .collection(Friendremoteconstants.friendCollection)
          .doc(friendId)
          .update({
            'lastMessageId': messageId,
            'lastMessageAt': Timestamp.fromDate(timestamp),
          });
    } catch (e) {
      throw Exception('Không thể cập nhật tin nhắn cuối cùng: $e');
    }
  }

  /// Cập nhật trạng thái block/unblock bạn bè
  Future<void> updateBlockStatus(
    String userId,
    String friendId,
    bool isBlock,
  ) async {
    try {
      final friendRef = firestore
          .collection(Friendremoteconstants.friendCollection)
          .doc('${userId}_$friendId');
      await friendRef.update({'isBlock': isBlock});
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái chặn: $e');
    }
  }
}
