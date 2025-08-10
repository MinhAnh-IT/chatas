import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:chatas/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:chatas/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:chatas/features/profile/data/models/user_profile_model.dart';
import 'package:chatas/features/profile/domain/entities/update_profile_request.dart';
import 'package:chatas/features/profile/domain/entities/change_password_request.dart';
import 'package:chatas/features/profile/domain/exceptions/profile_exceptions.dart';

class FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  UserProfileModel profile = UserProfileModel(
    id: 'u1',
    fullName: 'Test User',
    email: 'test@example.com',
    username: 'testuser',
    gender: 'male',
    birthDate: DateTime(2000, 1, 1),
  );

  bool usernameAvailable = true;
  bool shouldThrow = false;
  Exception? customException;

  @override
  Future<UserProfileModel> getUserProfile() async {
    if (shouldThrow) {
      throw customException ?? const ProfileUpdateException('error');
    }
    return profile;
  }

  @override
  Future<UserProfileModel> updateProfile(UpdateProfileRequest request) async {
    if (shouldThrow) {
      throw customException ?? const ProfileUpdateException('error');
    }
    if (!usernameAvailable && request.username.isNotEmpty) {
      throw const UsernameAlreadyExistsException();
    }
    profile = profile.copyWith(
      fullName: request.fullName,
      username: request.username,
      gender: request.gender,
      birthDate: request.birthDate,
      profileImageUrl: request.profileImageUrl,
    );
    return profile;
  }

  @override
  Future<void> changePassword(ChangePasswordRequest request) async {
    if (shouldThrow) {
      throw customException ?? const PasswordChangeException('error');
    }
  }

  @override
  Future<bool> checkUsernameAvailability(String username) async {
    if (shouldThrow) {
      throw customException ?? const ProfileUpdateException('error');
    }
    return usernameAvailable;
  }
}

void main() {
  group('ProfileRepositoryImpl', () {
    late FakeProfileRemoteDataSource fakeRemote;
    late ProfileRepositoryImpl repository;

    setUp(() {
      fakeRemote = FakeProfileRemoteDataSource();
      repository = ProfileRepositoryImpl(fakeRemote);
    });

    test('getUserProfile returns Right(UserProfile)', () async {
      final result = await repository.getUserProfile();
      expect(result.isRight(), true);
      result.fold((_) => fail('Expected Right'), (r) => expect(r.id, 'u1'));
    });

    test('getUserProfile returns Left(ProfileException) on error', () async {
      fakeRemote.shouldThrow = true;
      final result = await repository.getUserProfile();
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ProfileException>()),
        (_) => fail('Expected Left'),
      );
    });

    test('updateProfile returns updated profile on success', () async {
      final req = UpdateProfileRequest(
        fullName: 'New Name',
        username: 'newuser',
        gender: 'male',
        birthDate: DateTime(1999, 1, 1),
      );
      final result = await repository.updateProfile(req);
      expect(result.isRight(), true);
      result.fold((_) => fail('Expected Right'), (r) {
        expect(r.fullName, 'New Name');
        expect(r.username, 'newuser');
      });
    });

    test('updateProfile returns Left when username exists', () async {
      fakeRemote.usernameAvailable = false;
      final req = UpdateProfileRequest(
        fullName: 'New Name',
        username: 'taken',
        gender: 'male',
        birthDate: DateTime(1999, 1, 1),
      );
      final result = await repository.updateProfile(req);
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<UsernameAlreadyExistsException>()),
        (_) => fail('Expected Left'),
      );
    });

    test('changePassword returns Right(void) on success', () async {
      final result = await repository.changePassword(
        const ChangePasswordRequest(
          currentPassword: 'oldPass123',
          newPassword: 'newPass1234',
          confirmNewPassword: 'newPass1234',
        ),
      );
      expect(result, const Right(null));
    });

    test('changePassword returns Left on data source error', () async {
      fakeRemote.shouldThrow = true;
      final result = await repository.changePassword(
        const ChangePasswordRequest(
          currentPassword: 'oldPass123',
          newPassword: 'newPass1234',
          confirmNewPassword: 'newPass1234',
        ),
      );
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ProfileException>()),
        (_) => fail('Expected Left'),
      );
    });

    test('checkUsernameAvailability returns Right(bool)', () async {
      fakeRemote.usernameAvailable = true;
      final result = await repository.checkUsernameAvailability('abc');
      expect(result, const Right(true));
    });

    test('checkUsernameAvailability returns Left on error', () async {
      fakeRemote.shouldThrow = true;
      final result = await repository.checkUsernameAvailability('abc');
      expect(result.isLeft(), true);
    });
  });
}
