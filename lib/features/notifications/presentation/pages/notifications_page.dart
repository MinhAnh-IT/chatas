import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_route_constants.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/services/online_status_service.dart';
import '../../domain/entities/notification.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/notification_item.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load notifications when page opens
    context.read<NotificationCubit>().loadNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh notifications when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationCubit>().refreshNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Thông báo',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Quay lại',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouteConstants.homePath);
            }
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Tùy chọn',
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  context.read<NotificationCubit>().refreshNotifications();
                  break;
                case 'mark_all_read':
                  _showMarkAllReadDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) =>
                const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 12.0),
                        Text('Làm mới'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_read_outlined),
                        SizedBox(width: 12.0),
                        Text('Đánh dấu tất cả đã đọc'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          OnlineStatusService.instance.onUserActivity();
        },
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đã xảy ra lỗi',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        OnlineStatusService.instance.onUserActivity();
                        context.read<NotificationCubit>().loadNotifications();
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có thông báo nào',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Các thông báo sẽ xuất hiện ở đây',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  OnlineStatusService.instance.onUserActivity();
                  await context
                      .read<NotificationCubit>()
                      .refreshNotifications();
                },
                child: ListView.builder(
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return NotificationItem(
                      notification: notification,
                      onTap: () => _onNotificationTap(notification),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: 2, // Notifications tab is index 2
        onTap: (index) {
          switch (index) {
            case 0:
              // Chuyển đến trang Chat
              context.go('/');
              break;
            case 1:
              // Chuyển đến trang Bạn bè
              context.go(AppRouteConstants.friendsPath);
              break;
            case 2:
              // Đã ở trang Thông báo (hiện tại)
              break;
            case 3:
              // Chuyển đến trang Profile
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }

  void _onNotificationTap(NotificationEntity notification) {
    OnlineStatusService.instance.onUserActivity();
    // Mark as read if not already read
    if (!notification.isRead) {
      context.read<NotificationCubit>().markNotificationAsRead(notification.id);
    }

    // Handle navigation based on notification type
    switch (notification.type) {
      case 'friend_request':
        _navigateToFriendRequests(notification);
        break;
      case 'friend_accepted':
        _navigateToFriendProfile(notification);
        break;
      case 'new_message':
        _navigateToChat(notification);
        break;
      default:
        // Handle general notifications
        _showNotificationDetails(notification);
        break;
    }
  }

  void _navigateToFriendRequests(NotificationEntity notification) {
    // TODO: Navigate to friend requests page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to friend requests...')),
    );
  }

  void _navigateToFriendProfile(NotificationEntity notification) {
    // TODO: Navigate to friend profile
    final friendId = notification.data['friendId'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to friend profile: $friendId')),
    );
  }

  void _navigateToChat(NotificationEntity notification) {
    // Extract chat thread ID from notification data
    final chatThreadId = notification.data['chatThreadId'] as String?;
    final senderName = notification.data['senderName'] as String?;

    if (chatThreadId != null && senderName != null) {
      // Navigate to chat message page
      context.go(
        '/chat_message/$chatThreadId',
        extra: {
          'otherUserName': senderName,
          'otherUserId': notification.data['senderId'],
        },
      );
    } else {
      // Show error if data is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở cuộc trò chuyện. Dữ liệu không hợp lệ.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showNotificationDetails(NotificationEntity notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showMarkAllReadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh dấu tất cả đã đọc'),
        content: const Text(
          'Bạn có chắc chắn muốn đánh dấu tất cả thông báo là đã đọc?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement mark all as read
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã đánh dấu tất cả thông báo là đã đọc'),
                ),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
