import 'dart:async';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_datasource.dart';
import '../datasources/notification_local_notification_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> initialize() async {
    // Khởi tạo local notifications
    await NotificationLocalNotificationDataSource.initialize();

    // Khởi tạo Firebase Messaging
    await remoteDataSource.initialize();

    // Lắng nghe thông báo foreground và lưu vào database
    remoteDataSource.onForegroundMessage.listen((notificationModel) async {
      await localDataSource.insertNotification(notificationModel);
      // Hiển thị local notification
      await NotificationLocalNotificationDataSource.showNotificationFromModel(
        notificationModel,
      );
    });

    // Lắng nghe thông báo background và lưu vào database
    remoteDataSource.onBackgroundMessage.listen((notificationModel) async {
      await localDataSource.insertNotification(notificationModel);
    });
  }

  @override
  Future<String?> getFCMToken() async {
    return await remoteDataSource.getFCMToken();
  }

  @override
  Stream<NotificationEntity> onForegroundMessage() {
    return remoteDataSource.onForegroundMessage.map(
      (model) => model.toEntity(),
    );
  }

  @override
  Stream<NotificationEntity> onBackgroundMessage() {
    return remoteDataSource.onBackgroundMessage.map(
      (model) => model.toEntity(),
    );
  }

  @override
  Future<NotificationEntity?> getInitialMessage() async {
    final model = await remoteDataSource.getInitialMessage();
    if (model != null) {
      // Lưu vào database nếu có initial message
      await localDataSource.insertNotification(model);
      return model.toEntity();
    }
    return null;
  }

  @override
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: data?['type'] ?? 'general',
      data: data ?? {},
      createdAt: DateTime.now(),
      imageUrl: imageUrl,
    );

    // Lưu vào database
    await localDataSource.insertNotification(notification);

    // Hiển thị local notification
    await NotificationLocalNotificationDataSource.showNotificationFromModel(
      notification,
    );
  }

  @override
  Future<void> saveNotification(NotificationEntity notification) async {
    final model = NotificationModel.fromEntity(notification);
    await localDataSource.insertNotification(model);
  }

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final models = await localDataSource.getAllNotifications();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await localDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await localDataSource.deleteNotification(notificationId);
    // Hủy local notification nếu có
    await NotificationLocalNotificationDataSource.cancelNotification(
      notificationId.hashCode,
    );
  }

  @override
  Future<void> clearAllNotifications() async {
    await localDataSource.deleteAllNotifications();
    await NotificationLocalNotificationDataSource.cancelAllNotifications();
  }

  @override
  Future<int> getUnreadCount() async {
    return await localDataSource.getUnreadCount();
  }

  @override
  Future<void> updateFCMTokenOnServer(String token) async {
    await remoteDataSource.sendTokenToServer(token);
  }
}
