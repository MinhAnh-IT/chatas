import '../repositories/notification_repository.dart';

class GetUnreadNotificationsCount {
  final NotificationRepository repository;

  GetUnreadNotificationsCount(this.repository);

  Future<int> call() async {
    return await repository.getUnreadCount();
  }
}
