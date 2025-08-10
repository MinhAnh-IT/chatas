import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';

import 'package:chatas/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:chatas/features/profile/presentation/cubit/profile_state.dart';
import 'package:chatas/features/profile/domain/entities/user_profile.dart';
import 'package:chatas/features/profile/domain/entities/update_profile_request.dart';
import 'package:chatas/features/profile/domain/entities/change_password_request.dart';
import 'package:chatas/features/profile/domain/exceptions/profile_exceptions.dart';
import 'package:chatas/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:chatas/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:chatas/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:chatas/features/profile/domain/usecases/check_username_availability_usecase.dart';
import 'package:chatas/features/profile/domain/repositories/profile_repository.dart'
    as repo;

class DummyProfileRepository implements repo.ProfileRepository {
  @override
  Future<Either<ProfileException, bool>> checkUsernameAvailability(
    String username,
  ) async => const Right(true);

  @override
  Future<Either<ProfileException, void>> changePassword(
    ChangePasswordRequest request,
  ) async => const Right(null);

  @override
  Future<Either<ProfileException, UserProfile>> getUserProfile() async => Right(
    UserProfile(
      id: 'dummy',
      fullName: 'Dummy',
      email: 'dummy@example.com',
      username: 'dummy',
      gender: 'male',
      birthDate: DateTime(2000, 1, 1),
    ),
  );

  @override
  Future<Either<ProfileException, UserProfile>> updateProfile(
    UpdateProfileRequest request,
  ) async => getUserProfile();
}

class TestGetUserProfileUseCase extends GetUserProfileUseCase {
  Either<ProfileException, UserProfile> result;
  TestGetUserProfileUseCase(this.result) : super(DummyProfileRepository());

  @override
  Future<Either<ProfileException, UserProfile>> call() async => result;
}

class TestUpdateProfileUseCase extends UpdateProfileUseCase {
  Either<ProfileException, UserProfile> result;
  TestUpdateProfileUseCase(this.result) : super(DummyProfileRepository());

  @override
  Future<Either<ProfileException, UserProfile>> call(
    UpdateProfileRequest request,
  ) async => result;
}

class TestChangePasswordUseCase extends ChangePasswordUseCase {
  Either<ProfileException, void> result;
  TestChangePasswordUseCase(this.result) : super(DummyProfileRepository());

  @override
  Future<Either<ProfileException, void>> call(
    ChangePasswordRequest request,
  ) async => result;
}

class TestCheckUsernameAvailabilityUseCase
    extends CheckUsernameAvailabilityUseCase {
  Either<ProfileException, bool> result;
  TestCheckUsernameAvailabilityUseCase(this.result)
    : super(DummyProfileRepository());

  @override
  Future<Either<ProfileException, bool>> call(String username) async => result;
}

void main() {
  group('ProfileCubit', () {
    late ProfileCubit cubit;
    late TestGetUserProfileUseCase getUseCase;
    late TestUpdateProfileUseCase updateUseCase;
    late TestChangePasswordUseCase changePassUseCase;
    late TestCheckUsernameAvailabilityUseCase checkUsernameUseCase;

    setUp(() {
      getUseCase = TestGetUserProfileUseCase(
        Right(
          UserProfile(
            id: 'u1',
            fullName: 'Test User',
            email: 'test@example.com',
            username: 'testuser',
            gender: 'male',
            birthDate: DateTime(2000, 1, 1),
          ),
        ),
      );
      updateUseCase = TestUpdateProfileUseCase(
        Right(
          UserProfile(
            id: 'u1',
            fullName: 'Updated',
            email: 'test@example.com',
            username: 'updated',
            gender: 'male',
            birthDate: DateTime(2000, 1, 1),
          ),
        ),
      );
      changePassUseCase = TestChangePasswordUseCase(const Right(null));
      checkUsernameUseCase = TestCheckUsernameAvailabilityUseCase(
        const Right(true),
      );

      cubit = ProfileCubit(
        getUserProfileUseCase: getUseCase,
        updateProfileUseCase: updateUseCase,
        changePasswordUseCase: changePassUseCase,
        checkUsernameAvailabilityUseCase: checkUsernameUseCase,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is ProfileInitial', () {
      expect(cubit.state, isA<ProfileInitial>());
    });

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when getUserProfile succeeds',
      build: () => cubit,
      act: (c) => c.getUserProfile(),
      expect: () => [isA<ProfileLoading>(), isA<ProfileLoaded>()],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileFailure] when getUserProfile fails',
      build: () {
        getUseCase.result = Left(const ProfileUpdateException('err'));
        return cubit;
      },
      act: (c) => c.getUserProfile(),
      expect: () => [isA<ProfileLoading>(), isA<ProfileFailure>()],
    );

    final updateReq = UpdateProfileRequest(
      fullName: 'New Name',
      username: 'newuser',
      gender: 'male',
      birthDate: DateTime(1990, 1, 1),
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileUpdating, ProfileUpdated] when updateProfile succeeds',
      build: () => cubit,
      act: (c) => c.updateProfile(updateReq),
      expect: () => [isA<ProfileUpdating>(), isA<ProfileUpdated>()],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileUpdating, ProfileFailure] when updateProfile fails',
      build: () {
        updateUseCase.result = Left(const UsernameAlreadyExistsException());
        return cubit;
      },
      act: (c) => c.updateProfile(updateReq),
      expect: () => [isA<ProfileUpdating>(), isA<ProfileFailure>()],
    );

    final changeReq = const ChangePasswordRequest(
      currentPassword: 'old',
      newPassword: 'newPassword123',
      confirmNewPassword: 'newPassword123',
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [PasswordChanging, PasswordChanged] when changePassword succeeds',
      build: () => cubit,
      act: (c) => c.changePassword(changeReq),
      expect: () => [isA<PasswordChanging>(), isA<PasswordChanged>()],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [PasswordChanging, ProfileFailure] when changePassword fails',
      build: () {
        changePassUseCase.result = Left(
          const CurrentPasswordIncorrectException(),
        );
        return cubit;
      },
      act: (c) => c.changePassword(changeReq),
      expect: () => [isA<PasswordChanging>(), isA<ProfileFailure>()],
    );

    test('checkUsernameAvailability returns bool (true/false)', () async {
      checkUsernameUseCase.result = const Right(true);
      final available = await cubit.checkUsernameAvailability('ok');
      expect(available, true);

      checkUsernameUseCase.result = const Right(false);
      final unavailable = await cubit.checkUsernameAvailability('no');
      expect(unavailable, false);
    });
  });
}
