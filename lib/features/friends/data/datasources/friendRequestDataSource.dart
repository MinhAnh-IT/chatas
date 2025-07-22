import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friendModel.dart';
import '../models/friendRequestModel.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friendRequest.dart';

class FriendRemoteDataSource {
  late final FirebaseFirestore firestore;
  static const String friendCollection = 'friends';
  static const String friendRequestCollection = 'friendRequest';

  FriendRemoteDataSource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;
  Future<List<Friend>> getFriends(String userId) async {
    final snapshot = await firestore
        .collection(friendCollection)
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => FriendModel.fromJson(doc.data()).toEntity())
        .toList();
  }

  Future<void> sendFriendRequest(FriendRequest friendRequest) async {
    final model = FriendRequestModel.fromEntity(friendRequest);
    await firestore
        .collection(friendRequestCollection)
        .doc(friendRequest.id)
        .set(model.toJson());
  }

  Future<void> acceptFriendRequest(String requestId, Friend friend) async {
    final friendModel = FriendModel.fromEntity(friend);
    final requestSnapshot = await firestore
        .collection(friendRequestCollection)
        .doc(requestId)
        .get();
    if (requestSnapshot.exists) {
      await firestore.collection(friendRequestCollection).doc(requestId).update(
        {'status': 'accepted'},
      );
      await firestore
          .collection(friendCollection)
          .doc(friend.id)
          .set(friendModel.toJson());
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    await firestore.collection(friendCollection).doc(requestId).update({
      'status': 'reject',
    });
  }

  Future<void> removeFriend(String friendId) async {
    await firestore.collection(friendCollection).doc(friendId).delete();
  }

  Future<List<FriendRequest>> getFriendRequest(String userId) async {
    final snapshot = await firestore
        .collection(friendRequestCollection)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs
        .map((doc) => FriendRequestModel.fromJson(doc.data()).toEntity())
        .toList();
  }
}
