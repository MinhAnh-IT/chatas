import 'package:dartz/dartz.dart';
import '../repositories/profile_repository.dart';
import '../exceptions/profile_exceptions.dart';

class UploadProfileImageUseCase {
  final ProfileRepository repository;

  UploadProfileImageUseCase(this.repository);

  Future<Either<ProfileException, String>> call(String imagePath) {
    return repository.uploadProfileImage(imagePath);
  }
} 