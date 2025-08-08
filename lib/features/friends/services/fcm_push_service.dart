import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import '../../notifications/data/datasources/notification_local_notification_datasource.dart';
import 'notification_navigation_service.dart';

class FCMPushService {
  // Firebase Admin SDK credentials từ file JSON
  static const String _projectId = 'chatas-9469d';
  static const String _fcmSendUrl =
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

  // Service Account credentials từ file JSON
  static const Map<String, dynamic> _serviceAccountCredentials = {
    "type": "service_account",
    "project_id": "chatas-9469d",
    "private_key_id": "8df8e4c4ee414681b21f05465e0eb79e28a9d3b5",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCnIJiQOG3cUsZj\nIhcF54b1pLe74QevnAauejqZR1rQ0SbSzYlDF+8EoJDXTYRLnHi6Bq0X95rf+LYF\nn8CATfAVoC8Y2kK7V42l65ueXO0klHd4UgQjc/rxlwBr8KlHjTDW4i8+HK7IruQD\nk+SWhTyT3RTy1Cl/b8MJVkUfIoC+/JmKHAA9UgNoWt9RGJ2L0wphYXia2mAo9LpC\n6fdCT8oiiW2+4NGxkcZ7ywvGvtEvF0KxQ2CVxoLNioALFOs3DZ7M1habYaS55bD5\n8IM+wHXBtfL/ur2F6lxUrEv3NPnKa1WaxYEH5CkjXSPZSjyOC2naCH0s3cPwGrWn\neKYYXxHzAgMBAAECggEADzuv3DlgfhwHXCLP0Wh0izBL1PKiZjXFACNA8xanZvAh\nZ0Z3s+dbEGNoQE+e9ttYv6/7F/uoILEFOkcA31D7SKVUlaHTQkstLInoocsbjGGB\n8DQdj3OzVFDsp2oEq/JpGLT+FF296qnSO6c/xx520o1squN+stBniRLVcwyMipvK\npDGgJT4YzFcoWeQcAv9l1vVayolc3Pxfoz21jVM4Osi8Rrp5ivTGxM36gwxFn3Xc\nWq2SEkRZe3xzKkQzTa49IVN4tir3SxyunkZp7zmaVVfBJowq4k+m/CqGB1ZZCf/n\ndlvkn+G+n3kCJOq1+j7bRAShF3g4M4bqAZhKagLPQQKBgQDlY0Cq1P2E/bCd8lmJ\nVZlBo4/2W7pyG8sotTzVTO5qRUQ7dD0dYOcbV1pUPLaYB6mhZ/UhHXkA40UbGFFa\n1MmpJvQooss2WhJWUE1azcvtLEtBCMJtxKw1ucihoJxhhpkyX6Dt6Tfi3GJrFva2\nUJVJImslJPfaVDI+aXxAVSpjwQKBgQC6hDp7D+hozGvezKF4O6afsQ93wGSh3Cr6\nPt7rL+jyaPtwU7xQP9p8coNjeeJ7NN1Bm9l0bOgOiFOjL/JRHLVdUFD3vHl7zmqa\ntnMr+IzBXsAQg3ApP+xj8I7YWZ9qB6dOAuwMY+8LO9/Co/2PU9FjmW1XK2QSt/7F\nWMIXc6fSswKBgCWj7b6aiKdEAbFJTUvt0eIldsAUOTn0OZgKdVsC7rRdfV7MKiMh\n/YpNATOFaujziPBFYMH4VhzBLlvN17ux4w1wqOvqGrJmgU/MiYT29BmNBSQ8zbq5\nZRDD1ZpAAqk2LvlHG98uP89oHnY4JG+yNWz0yuQjdtBKtJvtL0hXMUeBAoGAcPfR\nq+OwsnjOBP4P9pC6lRJa+f8PdHGznioiPnSgNOKdGCW/cyOZo7KAHeoe4Nzd/fT1\nOm0UCGlNrxNFQxeOSdxxjfsb4X7eVqKXE1TRe/V1gwr5DiLnfIihHCz8Pu4vyTI/\n4ilNCZLULkHBO+RaeGbfMOLZE/VZXBIsTKQCS70CgYEAu92jfOfDc1Lxfw1nA3Hd\nz7EPux+hmjKF2kPtsu3iUjtHWFPPKtiUg799/lipxgq3hOJbsc35zhs+xKRPCULh\nvirdo/9T5HkG2rXmBrPtGACMke3cjz2m6YB8GL99VB0h6xD5lnIU/11K9SwkHeXM\nsbKme2D95KvgkY/bNXXqknA=\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-fbsvc@chatas-9469d.iam.gserviceaccount.com",
    "client_id": "107755447294071557970",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40chatas-9469d.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };

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
      // Tạo service account credentials từ JSON
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(_serviceAccountCredentials);
      
      // Tạo OAuth2 client với scope FCM
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final authClient = await auth.clientViaServiceAccount(accountCredentials, scopes);
      
      // Lấy access token
      final accessToken = authClient.credentials.accessToken.data;
      authClient.close();
      
      print('✅ Đã lấy access token thành công');
      return accessToken;
    } catch (e) {
      print('❌ Lỗi lấy access token: $e');
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
          'notification': {
            'title': title,
            'body': body,
          },
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
            'headers': {
              'apns-priority': '10',
            },
            'payload': {
              'aps': {
                'alert': {
                  'title': title,
                  'body': body,
                },
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
        print('❌ FCM Admin API Error: ${response.statusCode} - ${response.body}');
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
      const serverKey = 'AAAA_YOUR_SERVER_KEY_HERE'; // Cần thay thế bằng key thực tế
      
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
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
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
      
      // Tạo ID 32-bit từ timestamp
      final notificationId = (DateTime.now().millisecondsSinceEpoch % 2147483647).toInt();
      
      // Sử dụng NotificationLocalNotificationDataSource để hiển thị notification
      await NotificationLocalNotificationDataSource.showNotification(
        id: notificationId,
        title: message.notification?.title ?? 'Thông báo',
        body: message.notification?.body ?? '',
        payload: message.data.isNotEmpty ? json.encode(message.data) : null,
      );
      
      print('✅ Foreground notification hiển thị thành công với ID: $notificationId');
      
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
