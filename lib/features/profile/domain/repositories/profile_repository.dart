import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';
import '../entities/update_profile_request.dart';
import '../entities/change_password_request.dart';
import '../exceptions/profile_exceptions.dart';

abstract class ProfileRepository {
  Future<Either<ProfileException, UserProfile>> getUserProfile();
  Future<Either<ProfileException, UserProfile>> updateProfile(UpdateProfileRequest request);
  Future<Either<ProfileException, void>> changePassword(ChangePasswordRequest request);
  Future<Either<ProfileException, String>> uploadProfileImage(String imagePath);
  Future<Either<ProfileException, bool>> checkUsernameAvailability(String username);
} 