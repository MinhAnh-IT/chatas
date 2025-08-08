import '../repositories/notification_repository.dart';

class InitializeNotifications {
  final NotificationRepository repository;

  InitializeNotifications(this.repository);

  Future<void> call() async {
    await repository.initialize();

    // Lấy và cập nhật FCM token
    final token = await repository.getFCMToken();
    if (token != null) {
      await repository.updateFCMTokenOnServer(token);
    }
  }
}
