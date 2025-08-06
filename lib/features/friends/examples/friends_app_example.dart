import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../friends_injection.dart';
import '../presentation/pages/friends_page.dart';
import '../presentation/cubit/friends_cubit.dart';
import '../presentation/cubit/friend_requests_cubit.dart';

class FriendsAppExample extends StatelessWidget {
  final String currentUserId;

  const FriendsAppExample({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friends Feature Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<FriendsCubit>(
            create: (_) => FriendsDependencyInjection.createFriendsCubit(),
          ),
          BlocProvider<FriendRequestsCubit>(
            create: (_) =>
                FriendsDependencyInjection.createFriendRequestsCubit(),
          ),
        ],
        child: FriendsPage(userId: currentUserId),
      ),
    );
  }
}

// Usage Example:
/*
void main() {
  runApp(
    FriendsAppExample(
      currentUserId: 'user123', // Replace with actual user ID
    ),
  );
}

Or to integrate into existing app:

// In your main app
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... your app configuration
      routes: {
        '/friends': (context) => MultiBlocProvider(
          providers: [
            BlocProvider<FriendsCubit>(
              create: (_) => FriendsDependencyInjection.createFriendsCubit(),
            ),
            BlocProvider<FriendRequestsCubit>(
              create: (_) => FriendsDependencyInjection.createFriendRequestsCubit(),
            ),
          ],
          child: FriendsPage(
            userId: getCurrentUserId(), // Your method to get current user ID
          ),
        ),
        // ... other routes
      },
    );
  }
}
*/
