import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Lắng nghe thông báo khi app đang mở (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');

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
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

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
    });
  }

  /// Lấy FCM token
  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Lấy thông báo ban đầu (khi app được mở từ terminated state)
  Future<NotificationModel?> getInitialMessage() async {
    try {
      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();

      if (initialMessage != null) {
        print('App was opened from a terminated state via notification');
        print('Initial message data: ${initialMessage.data}');

        return NotificationModel.fromFirebaseMessage({
          'notification': {
            'title': initialMessage.notification?.title,
            'body': initialMessage.notification?.body,
            'imageUrl':
                initialMessage.notification?.android?.imageUrl ??
                initialMessage.notification?.apple?.imageUrl,
          },
          'data': initialMessage.data,
        });
      }
      return null;
    } catch (e) {
      print('Error getting initial message: $e');
      return null;
    }
  }

  /// Subscribe vào topic (nếu cần)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe từ topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Gửi token lên server (cần implement endpoint trên backend)
  Future<void> sendTokenToServer(String token) async {
    try {
      // TODO: Implement API call to your backend
      // Example:
      // final response = await http.post(
      //   Uri.parse('YOUR_BACKEND_URL/api/fcm-tokens'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({'token': token}),
      // );
      print('Token sent to server: $token');
    } catch (e) {
      print('Error sending token to server: $e');
    }
  }

  /// Gửi thông báo đến user cụ thể thông qua FCM token được lưu trong Firestore
  Future<void> sendNotificationToUser({
    required String userId,
    required NotificationModel notification,
  }) async {
    try {
      print('🔔 Preparing to send notification to user: $userId');
      print('   Title: ${notification.title}');
      print('   Body: ${notification.body}');

      // Lấy FCM token của user từ Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print('❌ User not found: $userId');
        return;
      }

      final userData = userDoc.data()!;
      final fcmToken = userData['fcmToken'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        print('❌ FCM token not found for user: $userId');
        return;
      }

      // Tạo notification data để gửi
      final notificationData = {
        'to': fcmToken,
        'notification': {
          'title': notification.title,
          'body': notification.body,
        },
        'data': {
          ...notification.data,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      };

      // TODO: Ở đây cần implement việc gửi qua FCM server
      // Hiện tại chỉ log ra để demo
      print('📱 Notification data prepared for FCM:');
      print('   Token: ${fcmToken.substring(0, 20)}...');
      print('   Data: $notificationData');

      // Note: Để gửi thực sự, cần backend server với admin SDK
      // hoặc sử dụng HTTP POST tới FCM API với server key

      print('✅ Notification prepared successfully for user: $userId');
    } catch (e) {
      print('❌ Error sending notification to user: $e');
      throw Exception('Failed to send notification to user: $e');
    }
  }

  void dispose() {
    _foregroundMessageController.close();
    _backgroundMessageController.close();
  }
}
