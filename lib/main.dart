import 'package:chatas/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'features/friends/injection/friends_injection.dart';
import 'features/friends/services/fcm_push_service.dart';
import 'features/notifications/notification_injection.dart';
import 'features/notifications/background_message_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Thiết lập background message handler cho FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize dependencies - notifications TRƯỚC friends
  setupNotificationDependencies();
  FriendsDependencyInjection.init();

  // Khởi tạo FCM Push Service
  await FCMPushService.initializeFCM();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _router = AppRouter.router;

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
