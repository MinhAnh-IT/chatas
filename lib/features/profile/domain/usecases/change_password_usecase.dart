import 'package:dartz/dartz.dart';
import '../entities/change_password_request.dart';
import '../repositories/profile_repository.dart';
import '../exceptions/profile_exceptions.dart';

class ChangePasswordUseCase {
  final ProfileRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<ProfileException, void>> call(ChangePasswordRequest request) {
    return repository.changePassword(request);
  }
} 