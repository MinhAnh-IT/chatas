import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
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
    // TODO: Cần setup dependency injection cho background context
    // Hiện tại chưa thể lưu được do GetIt chưa được init trong background
    print(
      '📝 Background notification received: ${message.notification?.title}',
    );
    print('📝 Background notification data: ${message.data}');
  } catch (e) {
    print('❌ Lỗi xử lý background notification: $e');
  }
}
