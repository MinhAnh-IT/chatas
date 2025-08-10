import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/update_profile_request.dart';
import '../../domain/entities/change_password_request.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';

import '../../domain/usecases/check_username_availability_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  final CheckUsernameAvailabilityUseCase _checkUsernameAvailabilityUseCase;

  ProfileCubit({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required ChangePasswordUseCase changePasswordUseCase,

    required CheckUsernameAvailabilityUseCase checkUsernameAvailabilityUseCase,
  }) : _getUserProfileUseCase = getUserProfileUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       _changePasswordUseCase = changePasswordUseCase,

       _checkUsernameAvailabilityUseCase = checkUsernameAvailabilityUseCase,
       super(ProfileInitial());

  Future<void> getUserProfile() async {
    emit(ProfileLoading());

    final result = await _getUserProfileUseCase();

    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> updateProfile(UpdateProfileRequest request) async {
    emit(ProfileUpdating());

    final result = await _updateProfileUseCase(request);

    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (profile) => emit(ProfileUpdated(profile)),
    );
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    emit(PasswordChanging());

    final result = await _changePasswordUseCase(request);

    result.fold(
      (failure) => emit(ProfileFailure(failure.message)),
      (_) => emit(PasswordChanged()),
    );
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final result = await _checkUsernameAvailabilityUseCase(username);

    return result.fold((failure) => false, (isAvailable) => isAvailable);
  }
}
