import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/entities/User.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../../../shared/utils/auth_exception_handler.dart';
import '../../constants/auth_constants.dart';

class AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  Future<AuthResult> register(RegisterRequest request) async {
    try {
      if (request.password != request.confirmPassword) {
        return const AuthFailure(AuthConstants.passwordsDoNotMatch);
      }

      if (request.password.length < AuthConstants.minPasswordLength) {
        return const AuthFailure(AuthConstants.weakPassword);
      }
      final usernameQuery = await _firestore
          .collection(AuthConstants.usersCollection)
          .where('username', isEqualTo: request.username)
          .limit(1)
          .get();
      if (usernameQuery.docs.isNotEmpty) {
        return const AuthFailure('Username was already taken');
      }

      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: request.email,
            password: request.password,
          );

      if (userCredential.user != null) {
        final userModel = UserModel(
          fullName: request.fullName,
          username: request.username,
          email: request.email,
          gender: request.gender,
          birthDate: request.birthDate,
          password: request.password,
          confirmPassword: request.confirmPassword,
          avatarUrl: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection(AuthConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .set(userModel.toJson());

        return AuthSuccess(userModel.toEntity());
      } else {
        return const AuthFailure('Failed to create user');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseAuthException(e);
      return AuthFailure(exception.message, exception: exception);
    } catch (e) {
      final exception = AuthExceptionHandler.handleGenericException(e);
      return AuthFailure(exception.message, exception: exception);
    }
  }

  Future<AuthResult> login(LoginRequest request) async {
    try {
      String userEmail = request.emailOrUsername;

      if (!request.emailOrUsername.contains('@')) {
        final userQuery = await _firestore
            .collection(AuthConstants.usersCollection)
            .where('username', isEqualTo: request.emailOrUsername)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          return const AuthFailure(
            'User not found',
            exception: UserNotFoundException(),
          );
        }

        final userData = userQuery.docs.first.data();
        userEmail = userData['email'] as String;
      }

      final firebase_auth.UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: userEmail,
            password: request.password,
          );

      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection(AuthConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userModel = UserModel.fromJson(userDoc.data()!);
          return AuthSuccess(userModel.toEntity());
        } else {
          return const AuthFailure('User data not found');
        }
      } else {
        return const AuthFailure('Login failed');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseAuthException(e);
      return AuthFailure(exception.message, exception: exception);
    } catch (e) {
      final exception = AuthExceptionHandler.handleGenericException(e);
      return AuthFailure(exception.message, exception: exception);
    }
  }

  Future<AuthResult> logout() async {
    try {
      await _firebaseAuth.signOut();
      return const AuthSuccess(null);
    } catch (e) {
      final exception = AuthExceptionHandler.handleGenericException(e);
      return AuthFailure(exception.message, exception: exception);
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final userDoc = await _firestore
            .collection(AuthConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          final userModel = UserModel.fromJson(userDoc.data()!);
          return userModel.toEntity();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    return _firebaseAuth.currentUser != null;
  }

  Future<User?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AuthConstants.usersCollection)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userModel = UserModel.fromJson(userDoc.data()!);
        return userModel.toEntity();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AuthResult> updateUser(User user) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final userModel = UserModel.fromEntity(user);
        await _firestore
            .collection(AuthConstants.usersCollection)
            .doc(firebaseUser.uid)
            .update(userModel.toJson());

        return AuthSuccess(user);
      } else {
        return const AuthFailure('User not logged in');
      }
    } catch (e) {
      final exception = AuthExceptionHandler.handleGenericException(e);
      return AuthFailure(exception.message, exception: exception);
    }
  }

  Future<AuthResult> deleteAccount() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await _firestore
            .collection(AuthConstants.usersCollection)
            .doc(firebaseUser.uid)
            .delete();
        await firebaseUser.delete();
        return const AuthSuccess(null);
      } else {
        return const AuthFailure('User not logged in');
      }
    } catch (e) {
      final exception = AuthExceptionHandler.handleGenericException(e);
      return AuthFailure(exception.message, exception: exception);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final exception = AuthExceptionHandler.handleFirebaseAuthException(e);
      throw Exception(exception.message);
    } catch (e) {
      throw Exception(
        'Lỗi không xác định khi gửi email đặt lại mật khẩu: ${e.toString()}',
      );
    }
  }
}
