import '../repositories/notification_repository.dart';

class SendFriendAcceptedNotification {
  final NotificationRepository repository;

  SendFriendAcceptedNotification(this.repository);

  Future<void> call({
    required String friendName,
    required String friendId,
  }) async {
    await repository.showLocalNotification(
      title: 'Kết bạn thành công',
      body: '$friendName đã chấp nhận lời mời kết bạn của bạn',
      data: {
        'type': 'friend_accepted',
        'friendId': friendId,
        'friendName': friendName,
        'action': 'view_friend_profile',
      },
    );
  }
}
