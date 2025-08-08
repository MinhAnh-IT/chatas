import '../entities/notification.dart';

abstract class NotificationRepository {
  /// Khởi tạo Firebase Messaging và yêu cầu quyền thông báo
  Future<void> initialize();

  /// Lấy FCM token để gửi thông báo
  Future<String?> getFCMToken();

  /// Lắng nghe thông báo khi app đang mở
  Stream<NotificationEntity> onForegroundMessage();

  /// Lắng nghe thông báo khi app đang mở từ background
  Stream<NotificationEntity> onBackgroundMessage();

  /// Xử lý thông báo khi app được mở từ terminated state
  Future<NotificationEntity?> getInitialMessage();

  /// Gửi thông báo local
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
  });

  /// Lưu thông báo vào database local
  Future<void> saveNotification(NotificationEntity notification);

  /// Lấy danh sách thông báo từ database local
  Future<List<NotificationEntity>> getNotifications();

  /// Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String notificationId);

  /// Xóa thông báo
  Future<void> deleteNotification(String notificationId);

  /// Xóa tất cả thông báo
  Future<void> clearAllNotifications();

  /// Đếm số thông báo chưa đọc
  Future<int> getUnreadCount();

  /// Cập nhật FCM token lên server (nếu có backend)
  Future<void> updateFCMTokenOnServer(String token);
}
