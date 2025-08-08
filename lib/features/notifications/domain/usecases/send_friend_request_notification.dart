import '../repositories/notification_repository.dart';

class SendFriendRequestNotification {
  final NotificationRepository repository;

  SendFriendRequestNotification(this.repository);

  Future<void> call({
    required String friendName,
    required String friendId,
  }) async {
    await repository.showLocalNotification(
      title: 'Lời mời kết bạn mới',
      body: '$friendName đã gửi lời mời kết bạn cho bạn',
      data: {
        'type': 'friend_request',
        'friendId': friendId,
        'friendName': friendName,
        'action': 'view_friend_request',
      },
    );
  }
}
