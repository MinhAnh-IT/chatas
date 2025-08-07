import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';
import '../entities/update_profile_request.dart';
import '../repositories/profile_repository.dart';
import '../exceptions/profile_exceptions.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<ProfileException, UserProfile>> call(UpdateProfileRequest request) {
    return repository.updateProfile(request);
  }
} 