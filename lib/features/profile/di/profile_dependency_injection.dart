import 'package:get_it/get_it.dart';
import '../data/datasources/profile_remote_data_source.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/get_user_profile_usecase.dart';
import '../domain/usecases/update_profile_usecase.dart';
import '../domain/usecases/change_password_usecase.dart';

import '../domain/usecases/check_username_availability_usecase.dart';

final getIt = GetIt.instance;

void setupProfileDependencies() {
  // Data sources
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetUserProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateProfileUseCase(getIt()));
  getIt.registerLazySingleton(() => ChangePasswordUseCase(getIt()));

  getIt.registerLazySingleton(() => CheckUsernameAvailabilityUseCase(getIt()));
}
