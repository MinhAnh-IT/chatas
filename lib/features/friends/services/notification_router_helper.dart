import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../notifications/presentation/cubit/notification_cubit.dart';
import '../../notifications/presentation/pages/notifications_page.dart';
import '../../notifications/notification_injection.dart' as notification_di;

class NotificationRouterHelper {
  /// Tạo route cho notifications page
  static Widget buildNotificationsPage(BuildContext context) {
    return BlocProvider(
      create: (context) => notification_di.sl<NotificationCubit>()..initialize(),
      child: const NotificationsPage(),
    );
  }

  /// Xử lý navigation từ notification data
  static void handleNotificationNavigation(
    BuildContext context,
    Map<String, dynamic> notificationData,
  ) {
    final action = notificationData['action'] as String?;

    switch (action) {
      case 'view_friend_request':
        _navigateToFriendRequests(context, notificationData);
        break;
      case 'view_friend_profile':
        _navigateToFriendProfile(context, notificationData);
        break;
      case 'open_chat':
        _navigateToChat(context, notificationData);
        break;
      case 'view_friend_suggestions':
        _navigateToFriendSearch(context);
        break;
      default:
        // Default navigation to notifications list
        _navigateToNotifications(context);
        break;
    }
  }

  static void _navigateToFriendRequests(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    // TODO: Navigate to friend requests page
    // Navigator.pushNamed(context, '/friend-requests');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to friend requests...')),
    );
  }

  static void _navigateToFriendProfile(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final friendId = data['friendId'] ?? data['accepterId'];
    // TODO: Navigate to friend profile
    // Navigator.pushNamed(context, '/profile/$friendId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to profile: $friendId')),
    );
  }

  static void _navigateToChat(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final senderId = data['senderId'];
    // TODO: Navigate to chat
    // final chatId = data['chatId'];
    // Navigator.pushNamed(context, '/chat/$chatId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening chat with: $senderId')),
    );
  }

  static void _navigateToFriendSearch(BuildContext context) {
    // TODO: Navigate to friend search
    // Navigator.pushNamed(context, '/friend-search');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to friend search...')),
    );
  }

  static void _navigateToNotifications(BuildContext context) {
    // TODO: Navigate to notifications list
    // Navigator.pushNamed(context, '/notifications');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to notifications...')),
    );
  }
}
