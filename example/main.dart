import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/features/friends/injection/friends_injection.dart';
import '../lib/features/friends/examples/friends_app_example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Friends Dependencies
  FriendsDependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friends Feature Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const FriendsAppExample(
        currentUserId: 'demo_user_123', // Replace with actual user ID
      ),
    );
  }
}

// Alternative usage with existing app structure:
/*
class ExistingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/friends': (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => FriendsCubit(
                getFriendsUseCase: FriendsDependencyInjection.getFriendsUseCase,
                removeFriendUseCase: FriendsDependencyInjection.removeFriendUseCase,
                updateOnlineStatusUseCase: // Add proper use case
              ),
            ),
            BlocProvider(
              create: (_) => FriendRequestsCubit(
                sendFriendRequestUseCase: FriendsDependencyInjection.sendFriendRequestUseCase,
                acceptFriendRequestUseCase: FriendsDependencyInjection.acceptFriendRequestUseCase,
                rejectFriendRequestUseCase: FriendsDependencyInjection.rejectFriendRequestUseCase,
                cancelFriendRequestUseCase: FriendsDependencyInjection.cancelFriendRequestUseCase,
                getReceivedRequestsUseCase: FriendsDependencyInjection.getReceivedRequestsUseCase,
                getSentRequestsUseCase: FriendsDependencyInjection.getSentRequestsUseCase,
              ),
            ),
          ],
          child: FriendsPage(
            userId: getCurrentUserId(), // Your method to get current user
          ),
        ),
      },
    );
  }
}
*/
