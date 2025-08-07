import 'package:dartz/dartz.dart';
import '../repositories/profile_repository.dart';
import '../exceptions/profile_exceptions.dart';

class CheckUsernameAvailabilityUseCase {
  final ProfileRepository repository;

  CheckUsernameAvailabilityUseCase(this.repository);

  Future<Either<ProfileException, bool>> call(String username) {
    return repository.checkUsernameAvailability(username);
  }
} 