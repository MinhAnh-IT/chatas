import 'package:firebase_messaging/firebase_messaging.dart';

/// Handler cho background messages từ FCM
/// Phải là top-level function để Firebase có thể gọi được
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Khởi tạo Firebase ở đây nếu cần thiết
  // await Firebase.initializeApp();
  
  print('Handling a background message: ${message.messageId}');
  
  // Xử lý thông báo background ở đây
  // Có thể lưu vào local database hoặc hiển thị local notification
  
  // Ví dụ: Lưu thông báo vào local storage
  // final localDataSource = NotificationLocalDataSource();
  // final notificationModel = NotificationModel.fromFirebaseMessage({
  //   'notification': {
  //     'title': message.notification?.title,
  //     'body': message.notification?.body,
  //     'imageUrl': message.notification?.android?.imageUrl ?? 
  //                message.notification?.apple?.imageUrl,
  //   },
  //   'data': message.data,
  // });
  // await localDataSource.insertNotification(notificationModel);
}
