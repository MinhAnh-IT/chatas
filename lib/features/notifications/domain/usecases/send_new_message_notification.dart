import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Use case để gửi thông báo tin nhắn mới
class SendNewMessageNotification {
  final NotificationRepository repository;

  const SendNewMessageNotification(this.repository);

  /// Gửi thông báo khi có tin nhắn mới
  ///
  /// Parameters:
  /// - [senderName]: Tên người gửi tin nhắn
  /// - [senderId]: ID người gửi tin nhắn
  /// - [receiverId]: ID người nhận tin nhắn
  /// - [chatThreadId]: ID của cuộc trò chuyện
  /// - [messageContent]: Nội dung tin nhắn (rút gọn nếu quá dài)
  /// - [isGroupChat]: Có phải tin nhắn nhóm không
  /// - [groupName]: Tên nhóm (nếu là tin nhắn nhóm)
  Future<void> call({
    required String senderName,
    required String senderId,
    required String receiverId,
    required String chatThreadId,
    required String messageContent,
    bool isGroupChat = false,
    String? groupName,
  }) async {
    try {
      // Tạo notification entity
      final notification = NotificationEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _buildNotificationTitle(
          senderName: senderName,
          isGroupChat: isGroupChat,
          groupName: groupName,
        ),
        body: _buildNotificationBody(messageContent),
        type: NotificationType.newMessage.value,
        data: {
          'action': 'new_message',
          'senderId': senderId,
          'receiverId': receiverId,
          'chatThreadId': chatThreadId,
          'senderName': senderName,
          'isGroupChat': isGroupChat.toString(),
          if (groupName != null) 'groupName': groupName,
        },
        createdAt: DateTime.now(),
        isRead: false,
      );

      // Gửi notification
      await repository.sendNotificationToUser(
        userId: receiverId,
        notification: notification,
      );

      print('✅ Đã gửi thông báo tin nhắn mới cho user: $receiverId');
      print('   Từ: $senderName');
      print('   Nội dung: ${_buildNotificationBody(messageContent)}');
    } catch (e) {
      print('❌ Lỗi gửi thông báo tin nhắn mới: $e');
      throw Exception('Failed to send new message notification: $e');
    }
  }

  /// Tạo title cho notification
  String _buildNotificationTitle({
    required String senderName,
    required bool isGroupChat,
    String? groupName,
  }) {
    if (isGroupChat && groupName != null) {
      return '$senderName trong $groupName';
    } else {
      return senderName;
    }
  }

  /// Tạo body cho notification (rút gọn nội dung nếu cần)
  String _buildNotificationBody(String messageContent) {
    const int maxLength = 100;

    if (messageContent.length <= maxLength) {
      return messageContent;
    }

    return '${messageContent.substring(0, maxLength)}...';
  }
}
