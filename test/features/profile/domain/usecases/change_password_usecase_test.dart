import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:chatas/features/profile/domain/entities/change_password_request.dart';
import 'package:chatas/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:chatas/features/profile/domain/repositories/profile_repository.dart';
import 'package:chatas/features/profile/domain/entities/user_profile.dart'
    as domain;
import 'package:chatas/features/profile/domain/usecases/change_password_usecase.dart';

class FakeProfileRepository implements ProfileRepository {
  Either<ProfileException, void> changePasswordResult = const Right(null);

  @override
  Future<Either<ProfileException, void>> changePassword(
    ChangePasswordRequest request,
  ) async => changePasswordResult;

  // unused for these tests
  @override
  Future<Either<ProfileException, domain.UserProfile>> getUserProfile() async =>
      Left(const ProfileUpdateException('unused'));

  @override
  Future<Either<ProfileException, domain.UserProfile>> updateProfile(_) async =>
      Left(const ProfileUpdateException('unused'));

  @override
  Future<Either<ProfileException, bool>> checkUsernameAvailability(_) async =>
      const Right(true);
}

// remove local stub; using domain.UserProfile type above

void main() {
  group('ChangePasswordUseCase', () {
    late FakeProfileRepository fakeRepository;
    late ChangePasswordUseCase useCase;

    setUp(() {
      fakeRepository = FakeProfileRepository();
      useCase = ChangePasswordUseCase(fakeRepository);
    });

    final request = ChangePasswordRequest(
      currentPassword: 'oldPass123',
      newPassword: 'newPass1234',
      confirmNewPassword: 'newPass1234',
    );

    test('returns Right(void) when repository succeeds', () async {
      final result = await useCase(request);
      expect(result.isRight(), true);
    });

    test(
      'returns Left(CurrentPasswordIncorrectException) on wrong password',
      () async {
        fakeRepository.changePasswordResult = Left(
          const CurrentPasswordIncorrectException(),
        );

        final result = await useCase(request);
        result.fold(
          (l) => expect(l, isA<CurrentPasswordIncorrectException>()),
          (_) => fail('Expected Left, got Right'),
        );
      },
    );
  });
}
