import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Stream controllers để xử lý thông báo
  final StreamController<NotificationModel> _foregroundMessageController =
      StreamController<NotificationModel>.broadcast();
  final StreamController<NotificationModel> _backgroundMessageController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get onForegroundMessage =>
      _foregroundMessageController.stream;
  Stream<NotificationModel> get onBackgroundMessage =>
      _backgroundMessageController.stream;

  /// Khởi tạo Firebase Messaging
  Future<void> initialize() async {
    // Yêu cầu quyền thông báo
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Lắng nghe thông báo khi app đang mở (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final notificationModel = NotificationModel.fromFirebaseMessage({
          'notification': {
            'title': message.notification?.title,
            'body': message.notification?.body,
            'imageUrl':
                message.notification?.android?.imageUrl ??
                message.notification?.apple?.imageUrl,
          },
          'data': message.data,
        });

        _foregroundMessageController.add(notificationModel);
      }
    });

    // Lắng nghe khi app được mở từ background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        final notificationModel = NotificationModel.fromFirebaseMessage({
          'notification': {
            'title': message.notification?.title,
            'body': message.notification?.body,
            'imageUrl':
                message.notification?.android?.imageUrl ??
                message.notification?.apple?.imageUrl,
          },
          'data': message.data,
        });

        _backgroundMessageController.add(notificationModel);
      }
    });
  }

  /// Lấy FCM token hiện tại
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Lắng nghe thay đổi FCM token
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  /// Xử lý thông báo khi app được mở từ terminated state
  Future<RemoteMessage?> getInitialMessage() async {
    try {
      return await _firebaseMessaging.getInitialMessage();
    } catch (e) {
      return null;
    }
  }

  /// Dispose các stream controllers
  void dispose() {
    _foregroundMessageController.close();
    _backgroundMessageController.close();
  }

  /// Đăng ký topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Hủy đăng ký topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Cấu hình foreground notification presentation (iOS)
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }

  /// Xóa tất cả thông báo được gửi bởi app (iOS only)
  Future<void> clearBadge() async {
    // Only available on iOS
    // Android badges are managed by the system
  }

  /// Kiểm tra quyền thông báo hiện tại
  Future<AuthorizationStatus> getNotificationSettings() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// Yêu cầu quyền thông báo một cách chi tiết hơn
  Future<AuthorizationStatus> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: alert,
      announcement: announcement,
      badge: badge,
      carPlay: carPlay,
      criticalAlert: criticalAlert,
      provisional: provisional,
      sound: sound,
    );
    return settings.authorizationStatus;
  }
}
