import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../exceptions/profile_exceptions.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<ProfileException, UserProfile>> call() {
    return repository.getUserProfile();
  }
}
