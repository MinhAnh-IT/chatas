import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/entities/notification.dart';
import '../../../firebase_options.dart';

final GetIt sl = GetIt.instance;

/// Handler cho background messages từ FCM
/// Phải là top-level function để Firebase có thể gọi được
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Khởi tạo Firebase nếu chưa được khởi tạo
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('🔔 Handling a background message: ${message.messageId}');
  print('   Title: ${message.notification?.title}');
  print('   Body: ${message.notification?.body}');
  print('   Data: ${message.data}');

  // Lưu thông báo vào local database
  try {
    // Tạo notification entity
    final notification = NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Thông báo',
      body: message.notification?.body ?? '',
      type: message.data['action'] ?? 'unknown',
      data: message.data,
      createdAt: DateTime.now(),
      isRead: false,
    );

    // TODO: Cần setup dependency injection cho background context
    // Hiện tại chưa thể lưu được do GetIt chưa được init trong background
    print('📝 Background notification saved (placeholder)');
  } catch (e) {
    print('❌ Lỗi lưu background notification: $e');
  }
}
