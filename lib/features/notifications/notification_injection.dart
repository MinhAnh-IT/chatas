import 'package:get_it/get_it.dart';

import 'data/datasources/notification_local_datasource.dart';
import 'data/datasources/notification_remote_datasource.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/usecases/get_notifications.dart';
import 'domain/usecases/get_unread_notifications_count.dart';
import 'domain/usecases/initialize_notifications.dart';
import 'domain/usecases/mark_notification_as_read.dart';
import 'domain/usecases/send_friend_accepted_notification.dart';
import 'domain/usecases/send_friend_request_notification.dart';
import 'presentation/cubit/notification_cubit.dart';

final GetIt sl = GetIt.instance;

void setupNotificationDependencies() {
  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(),
  );
  
  sl.registerLazySingleton<NotificationLocalDataSource>(
    () => NotificationLocalDataSource(),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => InitializeNotifications(sl()));
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => GetUnreadNotificationsCount(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsRead(sl()));
  sl.registerLazySingleton(() => SendFriendRequestNotification(sl()));
  sl.registerLazySingleton(() => SendFriendAcceptedNotification(sl()));

  // Cubit
  sl.registerFactory(
    () => NotificationCubit(
      initializeNotifications: sl(),
      getNotifications: sl(),
      getUnreadCount: sl(),
      markAsRead: sl(),
      sendFriendRequestNotification: sl(),
      sendFriendAcceptedNotification: sl(),
    ),
  );
}
