import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class OnlineStatusRemoteDataSource {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  OnlineStatusRemoteDataSource({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  Future<bool> updateOnlineStatus({
    required String userId,
    required bool isOnline,
    DateTime? lastActive,
  }) async {
    try {
      final now = lastActive ?? DateTime.now();
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastActive': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserOnlineStatus(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        return {
          'isOnline': data['isOnline'] ?? false,
          'lastActive': DateTime.parse(
            data['lastActive'] ?? DateTime.now().toIso8601String(),
          ),
          'userId': data['userId'],
          'fullName': data['fullName'],
          'username': data['username'],
          'avatarUrl': data['avatarUrl'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<Map<String, dynamic>?> streamUserOnlineStatus(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'isOnline': data['isOnline'] ?? false,
          'lastActive': DateTime.parse(
            data['lastActive'] ?? DateTime.now().toIso8601String(),
          ),
          'userId': data['userId'],
          'fullName': data['fullName'],
          'username': data['username'],
          'avatarUrl': data['avatarUrl'],
        };
      }
      return null;
    });
  }

  Future<bool> setUserOnline(String userId) async {
    return await updateOnlineStatus(
      userId: userId,
      isOnline: true,
      lastActive: DateTime.now(),
    );
  }

  Future<bool> setUserOffline(String userId) async {
    return await updateOnlineStatus(
      userId: userId,
      isOnline: false,
      lastActive: DateTime.now(),
    );
  }

  // Get current user ID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;
}
