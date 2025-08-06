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

  /// Get all friends for a user
  Future<List<Friend>> getFriends(String userId) async {
    final snapshot = await firestore
        .collection(Friendremoteconstants.friendCollection)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .get();

    return snapshot.docs
        .map((doc) => FriendModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  /// Add a friend relationship (after accepting request)
  Future<void> addFriend(String userId, String friendUserId) async {
    final batch = firestore.batch();
    final now = DateTime.now();

    // Create friendship for user1
    final friend1 = Friend(
      friendId: '${userId}_$friendUserId',
      userId: userId,
      friendUserId: friendUserId,
      createdAt: now,
      status: 'accepted',
    );

    final friend1Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc(friend1.friendId);
    batch.set(friend1Ref, FriendModel.fromEntity(friend1).toJson());

    // Create friendship for user2
    final friend2 = Friend(
      friendId: '${friendUserId}_$userId',
      userId: friendUserId,
      friendUserId: userId,
      createdAt: now,
      status: 'accepted',
    );

    final friend2Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc(friend2.friendId);
    batch.set(friend2Ref, FriendModel.fromEntity(friend2).toJson());

    await batch.commit();
  }

  /// Remove friend relationship
  Future<void> removeFriend(String userId, String friendUserId) async {
    final batch = firestore.batch();

    final friend1Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc('${userId}_$friendUserId');
    batch.delete(friend1Ref);

    final friend2Ref = firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc('${friendUserId}_$userId');
    batch.delete(friend2Ref);

    await batch.commit();
  }

  /// Update friend status
  Future<void> updateFriendStatus(String friendId, String status) async {
    await firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc(friendId)
        .update({'status': status});
  }

  /// Update online status
  Future<void> updateFriendOnlineStatus(String userId, bool isOnline) async {
    final snapshot = await firestore
        .collection(Friendremoteconstants.friendCollection)
        .where('friendUserId', isEqualTo: userId)
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isOnline': isOnline,
        'lastActive': isOnline ? null : Timestamp.now(),
      });
    }
    await batch.commit();
  }

  /// Update last message info
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

  /// Send friend request
  Future<void> sendFriendRequest(FriendRequest friendRequest) async {
    final model = FriendRequestModel.fromEntity(friendRequest);
    await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .doc(friendRequest.id)
        .set(model.toJson());
  }

  /// Accept friend request
  Future<void> acceptFriendRequest(String requestId) async {
    final requestDoc = await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .doc(requestId)
        .get();

    if (!requestDoc.exists) throw Exception('Friend request not found');

    final requestData = requestDoc.data()!;
    final senderId = requestData['senderId'] as String;
    final receiverId = requestData['receiverId'] as String;

    final batch = firestore.batch();

    // Update request status
    batch.update(requestDoc.reference, {
      'status': 'accepted',
      'updatedAt': Timestamp.now(),
    });

    // Add friend relationships
    await addFriend(senderId, receiverId);

    await batch.commit();
  }

  /// Reject friend request
  Future<void> rejectFriendRequest(String requestId) async {
    await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .doc(requestId)
        .update({'status': 'rejected', 'updatedAt': Timestamp.now()});
  }

  /// Cancel friend request
  Future<void> cancelFriendRequest(String requestId) async {
    await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .doc(requestId)
        .delete();
  }

  /// Get received friend requests
  Future<List<FriendRequest>> getReceivedFriendRequests(String userId) async {
    final snapshot = await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FriendRequestModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  /// Get sent friend requests
  Future<List<FriendRequest>> getSentFriendRequests(String userId) async {
    final snapshot = await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FriendRequestModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  /// Check friendship status between two users
  Future<String?> getFriendshipStatus(String userId, String otherUserId) async {
    // Check if they are friends
    final friendDoc = await firestore
        .collection(Friendremoteconstants.friendCollection)
        .doc('${userId}_$otherUserId')
        .get();

    if (friendDoc.exists) {
      final data = friendDoc.data()!;
      return data['status'] as String;
    }

    // Check for pending requests
    final sentRequestSnapshot = await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .where('senderId', isEqualTo: userId)
        .where('receiverId', isEqualTo: otherUserId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (sentRequestSnapshot.docs.isNotEmpty) {
      return 'request_sent';
    }

    final receivedRequestSnapshot = await firestore
        .collection(Friendremoteconstants.friendRequestCollection)
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (receivedRequestSnapshot.docs.isNotEmpty) {
      return 'request_received';
    }

    return null; // No relationship
  }
}
