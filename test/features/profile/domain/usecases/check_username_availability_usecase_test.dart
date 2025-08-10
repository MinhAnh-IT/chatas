import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:chatas/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:chatas/features/profile/domain/repositories/profile_repository.dart';
import 'package:chatas/features/profile/domain/entities/user_profile.dart'
    as domain;
import 'package:chatas/features/profile/domain/usecases/check_username_availability_usecase.dart';

class FakeProfileRepository implements ProfileRepository {
  Either<ProfileException, bool> availabilityResult = const Right(true);

  @override
  Future<Either<ProfileException, bool>> checkUsernameAvailability(
    String username,
  ) async => availabilityResult;

  // unused for these tests
  @override
  Future<Either<ProfileException, domain.UserProfile>> getUserProfile() async =>
      Left(const ProfileUpdateException('unused'));

  @override
  Future<Either<ProfileException, domain.UserProfile>> updateProfile(_) async =>
      Left(const ProfileUpdateException('unused'));

  @override
  Future<Either<ProfileException, void>> changePassword(_) async =>
      const Right(null);
}

// remove local stub; using domain.UserProfile to satisfy type

void main() {
  group('CheckUsernameAvailabilityUseCase', () {
    late FakeProfileRepository fakeRepository;
    late CheckUsernameAvailabilityUseCase useCase;

    setUp(() {
      fakeRepository = FakeProfileRepository();
      useCase = CheckUsernameAvailabilityUseCase(fakeRepository);
    });

    test('returns true when available', () async {
      fakeRepository.availabilityResult = const Right(true);
      final result = await useCase('new_username');
      result.fold(
        (l) => fail('Expected Right, got Left: ${l.message}'),
        (isAvailable) => expect(isAvailable, true),
      );
    });

    test('returns false when not available (Left)', () async {
      fakeRepository.availabilityResult = Left(
        const UsernameAlreadyExistsException(),
      );
      final result = await useCase('taken_username');
      result.fold(
        (l) => expect(l, isA<UsernameAlreadyExistsException>()),
        (_) => fail('Expected Left, got Right'),
      );
    });
  });
}
