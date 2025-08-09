import 'package:chatas/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/friends/injection/friends_injection.dart';
import 'features/auth/online_status_exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependencies
  FriendsDependencyInjection.init();

  // Initialize online status service
  OnlineStatusService.instance.initialize();

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
