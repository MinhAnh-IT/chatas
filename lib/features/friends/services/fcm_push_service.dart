import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:get_it/get_it.dart';
import '../../notifications/data/datasources/notification_local_notification_datasource.dart';
import '../../notifications/domain/repositories/notification_repository.dart';
import '../../notifications/domain/entities/notification.dart';
import '../../notifications/presentation/cubit/notification_cubit.dart';
import 'notification_navigation_service.dart';

final GetIt sl = GetIt.instance;

class FCMPushService {
  // Firebase Admin SDK credentials
  static const String _projectId = 'chatas-9469d';
  static const String _fcmSendUrl =
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

  // Service Account credentials - TODO: Move to secure storage
  static Map<String, dynamic>? _serviceAccountCredentials;

  /// Initialize service account credentials from secure source
  static void initializeCredentials(Map<String, dynamic> credentials) {
    _serviceAccountCredentials = credentials;
  }

  /// Lấy FCM token của thiết bị hiện tại
  static Future<String?> getDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print('📱 Device FCM Token: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      print('❌ Lỗi lấy FCM token: $e');
      return null;
    }
  }

  /// Lưu FCM token vào Firestore khi user đăng nhập
  static Future<void> saveTokenToFirestore(String userId) async {
    try {
      final token = await getDeviceToken();
      if (token != null && token.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('✅ Đã lưu FCM token cho user: $userId');
      }
    } catch (e) {
      print('❌ Lỗi lưu FCM token: $e');
    }
  }

  /// Lấy FCM token của user khác từ Firestore
  static Future<String?> getUserToken(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final token = doc.data()?['fcmToken'] as String?;
        if (token != null && token.isNotEmpty) {
          print(
            '🔍 Found FCM token cho user $userId: ${token.substring(0, 20)}...',
          );
          return token;
        }
      }
      print('❌ Không tìm thấy FCM token cho user: $userId');
      return null;
    } catch (e) {
      print('❌ Lỗi lấy FCM token của user $userId: $e');
      return null;
    }
  }

  /// Lấy Access Token cho Firebase Admin SDK
  static Future<String?> getAccessToken() async {
    try {
      if (_serviceAccountCredentials == null) {
        print('❌ Service account credentials chưa được khởi tạo');
        return null;
      }

      // Debug: kiểm tra thông tin credentials
      print('🔍 Debug credentials keys: ${_serviceAccountCredentials!.keys}');
      print('🔍 Project ID: ${_serviceAccountCredentials!['project_id']}');
      print('🔍 Client email: ${_serviceAccountCredentials!['client_email']}');
      print(
        '🔍 Private key ID: ${_serviceAccountCredentials!['private_key_id']}',
      );

      final privateKey =
          _serviceAccountCredentials!['private_key']?.toString() ?? '';
      print('🔍 Private key length: ${privateKey.length}');
      print('🔍 Private key starts with: ${privateKey.substring(0, 50)}...');
      print(
        '🔍 Private key ends with: ...${privateKey.substring(privateKey.length - 50)}',
      );

      // Validate private key format
      if (!privateKey.contains('-----BEGIN PRIVATE KEY-----') ||
          !privateKey.contains('-----END PRIVATE KEY-----')) {
        print('❌ Private key format invalid - missing BEGIN/END markers');
        return null;
      }

      // Check for proper newlines
      final lines = privateKey.split('\n');
      print('🔍 Private key has ${lines.length} lines');
      if (lines.length < 3) {
        print('❌ Private key doesn\'t have proper line breaks');
        return null;
      }

      // Tạo service account credentials từ JSON với explicit clock skew
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(
        _serviceAccountCredentials!,
      );

      print('🔍 ServiceAccount created successfully');

      // Tạo OAuth2 client với scope FCM và clock skew tolerance
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      print('🔍 Creating OAuth2 client with scopes: $scopes');

      final authClient = await auth.clientViaServiceAccount(
        accountCredentials,
        scopes,
      );

      print('🔍 OAuth2 client created successfully');

      // Lấy access token
      final accessToken = authClient.credentials.accessToken.data;
      authClient.close();

      print(
        '✅ Đã lấy access token thành công: ${accessToken.substring(0, 20)}...',
      );
      return accessToken;
    } catch (e) {
      print('❌ Chi tiết lỗi getAccessToken: $e');
      print('❌ Error type: ${e.runtimeType}');

      // Additional debug for JWT errors
      if (e.toString().contains('Invalid JWT Signature')) {
        print('🔍 JWT Signature error - có thể do:');
        print('   - Private key format không đúng');
        print('   - Clock skew (thời gian hệ thống không đồng bộ)');
        print('   - Service account bị disabled');
        print('🔧 Thử tạo lại service account key mới từ Firebase Console');
      }

      return null;
    }
  }

  /// Gửi FCM thông qua Firebase Admin API v1
  static Future<bool> sendNotificationWithAdminSDK({
    required String toUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('📤 Gửi FCM Admin API notification đến user: $toUserId');

      // 1. Lấy FCM token của người nhận
      final recipientToken = await getUserToken(toUserId);
      if (recipientToken == null || recipientToken.isEmpty) {
        print('❌ Không tìm thấy FCM token cho user: $toUserId');
        return false;
      }

      // 2. Lấy access token
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        print('❌ Không thể lấy access token');
        return false;
      }

      // 3. Tạo payload cho Firebase Admin API v1
      final payload = {
        'message': {
          'token': recipientToken,
          'notification': {'title': title, 'body': body},
          'data': {
            'type': 'friend_notification',
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            ...?data,
          },
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': 'friend_notifications',
              'sound': 'default',
            },
          },
          'apns': {
            'headers': {'apns-priority': '10'},
            'payload': {
              'aps': {
                'alert': {'title': title, 'body': body},
                'sound': 'default',
                'badge': 1,
              },
            },
          },
        },
      };

      print('📋 FCM Admin API Payload:');
      print('   Title: $title');
      print('   Body: $body');
      print('   To Token: ${recipientToken.substring(0, 20)}...');

      // 4. Gửi HTTP request đến Firebase Admin API
      final response = await http.post(
        Uri.parse(_fcmSendUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(payload),
      );

      print('📡 FCM Admin API Response Status: ${response.statusCode}');
      print('📡 FCM Admin API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ FCM Admin API notification sent successfully!');
        return true;
      } else {
        print(
          '❌ FCM Admin API Error: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Exception khi gửi FCM Admin API: $e');
      return false;
    }
  }

  /// Gửi FCM thông qua Legacy API (sử dụng Server Key)
  static Future<bool> sendNotificationLegacy({
    required String toUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('📤 Gửi FCM notification đến user: $toUserId');

      // 1. Lấy FCM token của người nhận
      final recipientToken = await getUserToken(toUserId);
      if (recipientToken == null || recipientToken.isEmpty) {
        print('❌ Không tìm thấy FCM token cho user: $toUserId');
        return false;
      }

      // 2. Server Key từ Firebase Console (Legacy Cloud Messaging API)
      // TODO: Lấy Server Key từ Firebase Console > Project Settings > Cloud Messaging
      const serverKey =
          'AAAA_YOUR_SERVER_KEY_HERE'; // Cần thay thế bằng key thực tế

      // 3. Tạo payload cho FCM legacy API
      final payload = {
        'to': recipientToken,
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
          'badge': 1,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'data': {
          'type': 'friend_notification',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          ...?data,
        },
        'priority': 'high',
        'content_available': true,
      };

      print('📋 FCM Payload:');
      print('   Title: $title');
      print('   Body: $body');
      print('   To Token: ${recipientToken.substring(0, 20)}...');

      // 4. Gửi HTTP request đến FCM Legacy API
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: json.encode(payload),
      );

      print('📡 FCM Response Status: ${response.statusCode}');
      print('📡 FCM Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == 1) {
          print('✅ FCM notification sent successfully!');
          return true;
        } else {
          print('❌ FCM failed: ${responseData['results']?[0]?['error']}');
          return false;
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Exception khi gửi FCM: $e');
      return false;
    }
  }

  /// Gửi thông báo push đến user cụ thể
  static Future<bool> sendNotificationToUser({
    required String toUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Sử dụng Firebase Admin SDK API v1
    return await sendNotificationWithAdminSDK(
      toUserId: toUserId,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Khởi tạo FCM permissions và listeners
  static Future<void> initializeFCM() async {
    try {
      print('🚀 Đang khởi tạo FCM...');

      // Khởi tạo local notification trước
      await NotificationLocalNotificationDataSource.initialize();
      print('✅ Local notification initialized');

      // Request notification permission
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: true,
        announcement: true,
      );

      print('📱 FCM Permission Status: ${settings.authorizationStatus}');

      // Lưu token khi user đăng nhập
      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null) {
          await saveTokenToFirestore(user.uid);
        }
      });

      // Refresh token khi có thay đổi
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
                'fcmToken': newToken,
                'lastTokenUpdate': FieldValue.serverTimestamp(),
              });
          print('🔄 FCM Token refreshed cho user: ${user.uid}');
        }
      });

      // Xử lý foreground messages - Hiển thị notification khi app đang mở
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📱 Foreground FCM Message received:');
        print('   Title: ${message.notification?.title}');
        print('   Body: ${message.notification?.body}');
        print('   Data: ${message.data}');

        // Hiển thị local notification khi app đang foreground
        _showForegroundNotification(message);
      });

      // Xử lý khi user tap vào notification (app đang background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📱 Notification tapped (from background):');
        print('   Data: ${message.data}');
        _handleNotificationTap(message);
      });

      // Xử lý khi app được mở từ notification (app đã đóng hoàn toàn)
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        print('📱 App opened from notification:');
        print('   Data: ${initialMessage.data}');
        _handleNotificationTap(initialMessage);
      }

      print('✅ FCM initialized successfully');
    } catch (e) {
      print('❌ Lỗi khởi tạo FCM: $e');
    }
  }

  /// Hiển thị notification khi app đang foreground
  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      print('🔔 Hiển thị foreground notification...');

      // Lưu notification vào database local trước
      try {
        final notificationRepository = sl<NotificationRepository>();
        final notification = NotificationEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: message.notification?.title ?? 'Thông báo',
          body: message.notification?.body ?? '',
          type: message.data['action'] ?? 'unknown',
          data: message.data,
          createdAt: DateTime.now(),
          isRead: false,
        );
        await notificationRepository.saveNotification(notification);
        print('✅ Đã lưu notification vào database local');

        // Trigger refresh notifications ở UI nếu có thể
        try {
          final notificationCubit = sl<NotificationCubit>();
          notificationCubit.refreshNotifications();
          print('🔄 Đã refresh notifications UI');
        } catch (e) {
          print('⚠️  Không thể refresh UI (có thể chưa init): $e');
        }
      } catch (e) {
        print('❌ Lỗi lưu notification vào database: $e');
      }

      // Tạo ID 32-bit từ timestamp
      final notificationId =
          (DateTime.now().millisecondsSinceEpoch % 2147483647).toInt();

      // Sử dụng NotificationLocalNotificationDataSource để hiển thị notification
      await NotificationLocalNotificationDataSource.showNotification(
        id: notificationId,
        title: message.notification?.title ?? 'Thông báo',
        body: message.notification?.body ?? '',
        payload: message.data.isNotEmpty ? json.encode(message.data) : null,
      );

      print(
        '✅ Foreground notification hiển thị thành công với ID: $notificationId',
      );
    } catch (e) {
      print('❌ Lỗi hiển thị foreground notification: $e');
    }
  }

  /// Xử lý khi user tap vào notification
  static void _handleNotificationTap(RemoteMessage message) {
    try {
      final data = message.data;
      print('👆 User tapped notification with action: ${data['action']}');

      // Sử dụng NotificationNavigationService để navigate
      NotificationNavigationService.handleNotificationTap(data);
    } catch (e) {
      print('❌ Lỗi xử lý notification tap: $e');
    }
  }
}
