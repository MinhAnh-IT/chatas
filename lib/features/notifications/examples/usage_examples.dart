// Ví dụ cách sử dụng notifications trong Friends feature

// 1. Khởi tạo notifications trong main app
/*
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/notifications/presentation/cubit/notification_cubit.dart';
import 'features/notifications/notification_injection.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<NotificationCubit>()..initialize(),
        ),
        // Other providers...
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
*/

// 2. Sử dụng trong Friends feature
/*
import '../notifications/presentation/cubit/notification_cubit.dart';

class FriendsService {
  final NotificationCubit notificationCubit;
  
  FriendsService(this.notificationCubit);
  
  Future<void> sendFriendRequest(String friendId, String friendName) async {
    // Logic gửi lời mời kết bạn...
    
    // Gửi thông báo
    await notificationCubit.sendFriendRequest(
      friendName: friendName,
      friendId: friendId,
    );
  }
  
  Future<void> acceptFriendRequest(String friendId, String friendName) async {
    // Logic chấp nhận lời mời kết bạn...
    
    // Gửi thông báo
    await notificationCubit.sendFriendAccepted(
      friendName: friendName,
      friendId: friendId,
    );
  }
}
*/

// 3. Thêm notification icon vào AppBar
/*
import '../notifications/presentation/widgets/notification_badge.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatAs'),
        actions: [
          NotificationIcon(
            onTap: () {
              // Navigate to notifications page
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      // Body...
    );
  }
}
*/

// 4. Routing configuration
/*
import 'features/notifications/presentation/pages/notifications_page.dart';

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    // Other routes...
  ],
);
*/
