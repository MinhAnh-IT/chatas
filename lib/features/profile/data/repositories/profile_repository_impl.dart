import 'package:dartz/dartz.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/update_profile_request.dart';
import '../../domain/entities/change_password_request.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/exceptions/profile_exceptions.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<ProfileException, UserProfile>> getUserProfile() async {
    try {
      final profile = await remoteDataSource.getUserProfile();
      return Right(profile);
    } catch (e) {
      if (e is ProfileException) {
        return Left(e);
      }
      return Left(ProfileUpdateException('Không thể lấy thông tin profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ProfileException, UserProfile>> updateProfile(UpdateProfileRequest request) async {
    try {
      final profile = await remoteDataSource.updateProfile(request);
      return Right(profile);
    } catch (e) {
      if (e is ProfileException) {
        return Left(e);
      }
      return Left(ProfileUpdateException('Không thể cập nhật profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ProfileException, void>> changePassword(ChangePasswordRequest request) async {
    try {
      await remoteDataSource.changePassword(request);
      return const Right(null);
    } catch (e) {
      if (e is ProfileException) {
        return Left(e);
      }
      return Left(PasswordChangeException('Không thể thay đổi mật khẩu: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ProfileException, String>> uploadProfileImage(String imagePath) async {
    try {
      final imageUrl = await remoteDataSource.uploadProfileImage(imagePath);
      return Right(imageUrl);
    } catch (e) {
      if (e is ProfileException) {
        return Left(e);
      }
      return Left(ImageUploadException('Không thể tải ảnh lên: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ProfileException, bool>> checkUsernameAvailability(String username) async {
    try {
      final isAvailable = await remoteDataSource.checkUsernameAvailability(username);
      return Right(isAvailable);
    } catch (e) {
      if (e is ProfileException) {
        return Left(e);
      }
      return Left(ProfileUpdateException('Không thể kiểm tra username: ${e.toString()}'));
    }
  }
} 