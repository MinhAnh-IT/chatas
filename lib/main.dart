import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/chat_thread/presentation/pages/chat_thread_list_page.dart';
import 'features/friends/injection/friends_injection.dart';
import 'features/friends/presentation/pages/friends_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependencies
  FriendsDependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FriendsListPage(currentUserId: 'test_user_id'),
      routes: {
        '/friends': (context) =>
            const FriendsListPage(currentUserId: 'test_user_id'),
        '/chat': (context) => const ChatThreadListPage(),
      },
    );
  }
}
