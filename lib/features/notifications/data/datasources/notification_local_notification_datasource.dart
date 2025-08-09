import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';

class NotificationLocalNotificationDataSource {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Khởi tạo local notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Yêu cầu quyền trên Android 13+
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Xử lý khi user tap vào notification
  static void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      print('Notification payload: $payload');
      // TODO: Handle navigation based on payload
      // You can parse the payload and navigate to appropriate screen
    }
  }

  /// Hiển thị notification đơn giản
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'chatas_channel',
          'ChatAs Notifications',
          channelDescription: 'Notifications for ChatAs app',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Hiển thị notification với hình ảnh
  static Future<void> showNotificationWithImage({
    required int id,
    required String title,
    required String body,
    required String imageUrl,
    String? payload,
  }) async {
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
          DrawableResourceAndroidBitmap(
            '@mipmap/ic_launcher',
          ), // Fallback image
          contentTitle: title,
          summaryText: body,
        );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'chatas_channel',
          'ChatAs Notifications',
          channelDescription: 'Notifications for ChatAs app',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: bigPictureStyleInformation,
          icon: '@mipmap/ic_launcher',
        );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          attachments: [DarwinNotificationAttachment(imageUrl)],
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Hiển thị notification từ NotificationModel
  static Future<void> showNotificationFromModel(
    NotificationModel notification,
  ) async {
    final id = notification.id.hashCode;
    final payload = notification.data.toString();

    if (notification.imageUrl != null && notification.imageUrl!.isNotEmpty) {
      await showNotificationWithImage(
        id: id,
        title: notification.title,
        body: notification.body,
        imageUrl: notification.imageUrl!,
        payload: payload,
      );
    } else {
      await showNotification(
        id: id,
        title: notification.title,
        body: notification.body,
        payload: payload,
      );
    }
  }

  /// Hủy notification
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Hủy tất cả notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Lấy pending notifications
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Lấy active notifications (Android only)
  static Future<List<ActiveNotification>> getActiveNotifications() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      return await androidImplementation.getActiveNotifications();
    }
    return [];
  }
}
