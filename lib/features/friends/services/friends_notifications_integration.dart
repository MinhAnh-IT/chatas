import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../notifications/presentation/cubit/notification_cubit.dart';
import '../../notifications/presentation/cubit/notification_state.dart';
import '../../notifications/presentation/widgets/notification_badge.dart';
import '../../notifications/notification_injection.dart' as notification_di;
import '../injection/friends_injection.dart';
import 'notification_router_helper.dart';

/// Widget demo để show cách tích hợp notification vào Friends feature
class FriendsWithNotificationsWidget extends StatelessWidget {
  final String currentUserId;

  const FriendsWithNotificationsWidget({
    super.key,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Notification Cubit
        BlocProvider(
          create: (context) =>
              notification_di.sl<NotificationCubit>()..initialize(),
        ),
        // Friends Cubits
        BlocProvider(
          create: (context) =>
              FriendsDependencyInjection.createFriendSearchCubit(),
        ),
        BlocProvider(
          create: (context) =>
              FriendsDependencyInjection.createFriendRequestCubit(
                currentUserId,
              ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bạn bè'),
          actions: [
            // Notification icon với badge
            NotificationIcon(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationRouterHelper.buildNotificationsPage(
                          context,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
        body: const Column(
          children: [
            // Notification listener
            _NotificationListener(),
            // Friends content
            Expanded(child: Center(child: Text('Friends Content Here'))),
          ],
        ),
      ),
    );
  }
}

/// Widget để lắng nghe notification và xử lý navigation
class _NotificationListener extends StatefulWidget {
  const _NotificationListener();

  @override
  State<_NotificationListener> createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<_NotificationListener> {
  @override
  void initState() {
    super.initState();
    // Lắng nghe notification events
    _listenToNotifications();
  }

  void _listenToNotifications() {
    // Lắng nghe khi có notification mới được tap
    // Trong thực tế, bạn có thể implement event bus hoặc stream
    // để listen notification tap events từ system
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listener: (context, state) {
        if (state is NotificationReceived) {
          // Hiển thị snackbar khi có notification mới
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${state.notification.title}: ${state.notification.body}',
              ),
              action: SnackBarAction(
                label: 'Xem',
                onPressed: () {
                  NotificationRouterHelper.handleNotificationNavigation(
                    context,
                    state.notification.data,
                  );
                },
              ),
            ),
          );
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}

/// Extension methods để dễ sử dụng notification trong friends feature
extension FriendsNotificationExtension on BuildContext {
  /// Gửi notification lời mời kết bạn
  Future<void> sendFriendRequestNotification({
    required String fromUserName,
    required String fromUserId,
  }) async {
    final notificationService =
        FriendsDependencyInjection.friendNotificationService;
    await notificationService.sendFriendRequestNotification(
      fromUserName: fromUserName,
      fromUserId: fromUserId,
    );
  }

  /// Gửi notification chấp nhận kết bạn
  Future<void> sendFriendAcceptedNotification({
    required String accepterName,
    required String accepterId,
  }) async {
    final notificationService =
        FriendsDependencyInjection.friendNotificationService;
    await notificationService.sendFriendAcceptedNotification(
      accepterName: accepterName,
      accepterId: accepterId,
    );
  }

  /// Navigate đến notifications page
  void navigateToNotifications() {
    Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) =>
            NotificationRouterHelper.buildNotificationsPage(context),
      ),
    );
  }
}
