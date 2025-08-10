import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/get_unread_notifications_count.dart';
import '../../domain/usecases/initialize_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart';
import '../../domain/usecases/send_friend_accepted_notification.dart';
import '../../domain/usecases/send_friend_request_notification.dart';
import '../../domain/usecases/send_new_message_notification.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final InitializeNotifications initializeNotifications;
  final GetNotifications getNotifications;
  final GetUnreadNotificationsCount getUnreadCount;
  final MarkNotificationAsRead markAsRead;
  final SendFriendRequestNotification sendFriendRequestNotification;
  final SendFriendAcceptedNotification sendFriendAcceptedNotification;
  final SendNewMessageNotification sendNewMessageNotification;

  StreamSubscription? _foregroundMessageSubscription;
  StreamSubscription? _backgroundMessageSubscription;

  NotificationCubit({
    required this.initializeNotifications,
    required this.getNotifications,
    required this.getUnreadCount,
    required this.markAsRead,
    required this.sendFriendRequestNotification,
    required this.sendFriendAcceptedNotification,
    required this.sendNewMessageNotification,
  }) : super(NotificationInitial());

  Future<void> initialize() async {
    try {
      emit(NotificationLoading());

      await initializeNotifications();
      await loadNotifications();

      // Listen for real-time notifications here if needed
    } catch (e) {
      emit(
        NotificationError(
          'Failed to initialize notifications: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadNotifications() async {
    try {
      final notifications = await getNotifications();
      final unreadCount = await getUnreadCount();

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationError('Failed to load notifications: ${e.toString()}'));
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await markAsRead(notificationId);
      await loadNotifications(); // Refresh the list
    } catch (e) {
      emit(
        NotificationError(
          'Failed to mark notification as read: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> sendFriendRequest({
    required String friendName,
    required String friendId,
  }) async {
    try {
      await sendFriendRequestNotification(
        friendName: friendName,
        friendId: friendId,
      );
    } catch (e) {
      emit(
        NotificationError(
          'Failed to send friend request notification: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> sendFriendAccepted({
    required String friendName,
    required String friendId,
  }) async {
    try {
      await sendFriendAcceptedNotification(
        friendName: friendName,
        friendId: friendId,
      );
    } catch (e) {
      emit(
        NotificationError(
          'Failed to send friend accepted notification: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> sendNewMessage({
    required String senderName,
    required String senderId,
    required String receiverId,
    required String chatThreadId,
    required String messageContent,
    bool isGroupChat = false,
    String? groupName,
  }) async {
    try {
      await sendNewMessageNotification(
        senderName: senderName,
        senderId: senderId,
        receiverId: receiverId,
        chatThreadId: chatThreadId,
        messageContent: messageContent,
        isGroupChat: isGroupChat,
        groupName: groupName,
      );
    } catch (e) {
      emit(
        NotificationError(
          'Failed to send new message notification: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  @override
  Future<void> close() {
    _foregroundMessageSubscription?.cancel();
    _backgroundMessageSubscription?.cancel();
    return super.close();
  }
}
