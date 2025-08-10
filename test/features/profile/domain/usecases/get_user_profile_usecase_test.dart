import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:chatas/features/profile/domain/entities/user_profile.dart';
import 'package:chatas/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:chatas/features/profile/domain/repositories/profile_repository.dart';
import 'package:chatas/features/profile/domain/usecases/get_user_profile_usecase.dart';

class FakeProfileRepository implements ProfileRepository {
  Either<ProfileException, UserProfile> result = Right(
    UserProfile(
      id: 'u1',
      fullName: 'Test User',
      email: 'test@example.com',
      username: 'testuser',
      gender: 'male',
      birthDate: DateTime(2000, 1, 1),
    ),
  );

  @override
  Future<Either<ProfileException, UserProfile>> getUserProfile() async =>
      result;

  @override
  Future<Either<ProfileException, void>> changePassword(_) async =>
      const Right(null);

  @override
  Future<Either<ProfileException, bool>> checkUsernameAvailability(_) async =>
      const Right(true);

  @override
  Future<Either<ProfileException, UserProfile>> updateProfile(_) async =>
      result;
}

void main() {
  group('GetUserProfileUseCase', () {
    late FakeProfileRepository fakeRepository;
    late GetUserProfileUseCase useCase;

    setUp(() {
      fakeRepository = FakeProfileRepository();
      useCase = GetUserProfileUseCase(fakeRepository);
    });

    test('returns Right(UserProfile) when repository succeeds', () async {
      // act
      final result = await useCase();

      // assert
      result.fold((l) => fail('Expected Right, got Left: ${l.message}'), (r) {
        expect(r.id, 'u1');
        expect(r.fullName, 'Test User');
      });
    });

    test('returns Left(ProfileException) when repository fails', () async {
      // arrange
      fakeRepository.result = Left(const ProfileUpdateException('error'));

      // act
      final result = await useCase();

      // assert
      result.fold(
        (l) => expect(l, isA<ProfileUpdateException>()),
        (_) => fail('Expected Left, got Right'),
      );
    });
  });
}
