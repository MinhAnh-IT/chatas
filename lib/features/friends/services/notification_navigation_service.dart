import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_route_constants.dart';

class NotificationNavigationService {
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate based on notification action
  static void handleNotificationTap(Map<String, dynamic> data) {
    try {
      final action = data['action'] as String?;
      print('👆 Handling notification tap with action: $action');

      final context = navigatorKey.currentContext;
      if (context == null) {
        print('❌ No context available for navigation');
        return;
      }

      switch (action) {
        case 'friend_request':
          print('🔀 Navigating to friend requests page');
          context.pushNamed(AppRouteConstants.friendRequestsPathName);
          break;
        case 'friend_accepted':
          print('🔀 Navigating to friends list page');
          context.pushNamed(AppRouteConstants.friendsPathName);
          break;
        case 'friend_rejected':
          print('🔀 Navigating to friend requests page');
          context.pushNamed(AppRouteConstants.friendRequestsPathName);
          break;
        default:
          print('🔀 Navigating to notifications page');
          context.pushNamed(AppRouteConstants.notificationsPathName);
      }
    } catch (e) {
      print('❌ Error handling notification navigation: $e');
    }
  }
}
