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
      final now = DateTime.now();
      final Map<String, dynamic> updates = {
        'isOnline': isOnline,
        'updatedAt': now.toIso8601String(),
      };

      // Only update lastActive when going offline
      if (!isOnline) {
        updates['lastActive'] = (lastActive ?? now).toIso8601String();
      }

      await _firestore.collection('users').doc(userId).update(updates);
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
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setUserOffline(String userId) async {
    return await updateOnlineStatus(
      userId: userId,
      isOnline: false,
      lastActive: DateTime.now(),
    );
  }

  // Set user offline for cleanup without updating lastActive
  Future<bool> cleanupUserOnlineStatus(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current user ID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;
}
