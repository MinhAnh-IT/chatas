import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile_model.dart';
import '../../domain/entities/update_profile_request.dart';
import '../../domain/entities/change_password_request.dart';
import '../../domain/exceptions/profile_exceptions.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateProfile(UpdateProfileRequest request);
  Future<void> changePassword(ChangePasswordRequest request);

  Future<bool> checkUsernameAvailability(String username);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ProfileRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const UserNotFoundException();
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        throw const UserNotFoundException();
      }

      final data = doc.data()!;
      return UserProfileModel.fromJson(data);
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileUpdateException(
        'Không thể lấy thông tin profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserProfileModel> updateProfile(UpdateProfileRequest request) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const UserNotFoundException();
      }

      // Check if username is already taken by another user
      if (request.username.isNotEmpty) {
        final isAvailable = await checkUsernameAvailability(request.username);
        if (!isAvailable) {
          throw const UsernameAlreadyExistsException();
        }
      }

      final updateData = <String, dynamic>{
        'fullName': request.fullName,
        'username': request.username,
        'gender': request.gender,
        'birthDate': request.birthDate.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add image URL if provided
      if (request.profileImageUrl != null) {
        updateData['avatarUrl'] = request.profileImageUrl;
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);

      // Get updated profile
      return await getUserProfile();
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileUpdateException(
        'Không thể cập nhật profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const UserNotFoundException();
      }

      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: request.currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(request.newPassword);
    } catch (e) {
      if (e is ProfileException) rethrow;
      if (e.toString().contains('wrong-password')) {
        throw const CurrentPasswordIncorrectException();
      }
      throw PasswordChangeException(
        'Không thể thay đổi mật khẩu: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const UserNotFoundException();
      }

      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      // Username is available if no documents found or if it belongs to current user
      return querySnapshot.docs.isEmpty ||
          querySnapshot.docs.first.id == user.uid;
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileUpdateException(
        'Không thể kiểm tra username: ${e.toString()}',
      );
    }
  }
}
