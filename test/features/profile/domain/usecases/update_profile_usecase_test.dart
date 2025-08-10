import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:chatas/features/profile/domain/entities/user_profile.dart';
import 'package:chatas/features/profile/domain/entities/update_profile_request.dart';
import 'package:chatas/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:chatas/features/profile/domain/repositories/profile_repository.dart';
import 'package:chatas/features/profile/domain/usecases/update_profile_usecase.dart';

class FakeProfileRepository implements ProfileRepository {
  Either<ProfileException, UserProfile> updateResult = Right(
    UserProfile(
      id: 'u1',
      fullName: 'Updated User',
      email: 'test@example.com',
      username: 'testuser',
      gender: 'male',
      birthDate: DateTime(2000, 1, 1),
    ),
  );

  @override
  Future<Either<ProfileException, UserProfile>> updateProfile(
    UpdateProfileRequest request,
  ) async => updateResult;

  // unused in these tests
  @override
  Future<Either<ProfileException, UserProfile>> getUserProfile() async =>
      updateResult;

  @override
  Future<Either<ProfileException, void>> changePassword(_) async =>
      const Right(null);

  @override
  Future<Either<ProfileException, bool>> checkUsernameAvailability(_) async =>
      const Right(true);
}

void main() {
  group('UpdateProfileUseCase', () {
    late FakeProfileRepository fakeRepository;
    late UpdateProfileUseCase useCase;

    setUp(() {
      fakeRepository = FakeProfileRepository();
      useCase = UpdateProfileUseCase(fakeRepository);
    });

    final request = UpdateProfileRequest(
      fullName: 'Updated User',
      username: 'newuser',
      gender: 'male',
      birthDate: DateTime(2000, 1, 1),
    );

    test('returns Right(UserProfile) when repository succeeds', () async {
      final result = await useCase(request);

      result.fold(
        (l) => fail('Expected Right, got Left: ${l.message}'),
        (r) => expect(r.fullName, 'Updated User'),
      );
    });

    test('returns Left(ProfileException) when repository fails', () async {
      fakeRepository.updateResult = Left(
        const UsernameAlreadyExistsException(),
      );

      final result = await useCase(request);

      result.fold(
        (l) => expect(l, isA<UsernameAlreadyExistsException>()),
        (_) => fail('Expected Left, got Right'),
      );
    });
  });
}
