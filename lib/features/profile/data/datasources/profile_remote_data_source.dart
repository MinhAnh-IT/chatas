import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_profile_model.dart';
import '../../domain/entities/update_profile_request.dart';
import '../../domain/entities/change_password_request.dart';
import '../../domain/exceptions/profile_exceptions.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateProfile(UpdateProfileRequest request);
  Future<void> changePassword(ChangePasswordRequest request);
  Future<String> uploadProfileImage(String imagePath);
  Future<bool> checkUsernameAvailability(String username);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ProfileRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const UserNotFoundException();
      }

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw const UserNotFoundException();
      }

      final data = doc.data()!;
      return UserProfileModel.fromJson(data);
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileUpdateException('Không thể lấy thông tin profile: ${e.toString()}');
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

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      // Get updated profile
      return await getUserProfile();
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileUpdateException('Không thể cập nhật profile: ${e.toString()}');
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
      throw PasswordChangeException('Không thể thay đổi mật khẩu: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const UserNotFoundException();
      }

      final file = File(imagePath);
      final ref = _storage
          .ref()
          .child('profile_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update profile with new image URL
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'avatarUrl': downloadUrl, // Chỉ cập nhật avatarUrl
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ImageUploadException('Không thể tải ảnh lên: ${e.toString()}');
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
      throw ProfileUpdateException('Không thể kiểm tra username: ${e.toString()}');
    }
  }
} 