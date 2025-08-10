import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chatas/features/notifications/domain/usecases/get_notifications.dart';
import 'package:chatas/features/notifications/domain/repositories/notification_repository.dart';
import 'package:chatas/features/notifications/domain/entities/notification.dart';

/// Mock implementation for testing.
class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  group('GetNotifications Tests', () {
    late GetNotifications useCase;
    late MockNotificationRepository mockRepository;

    setUp(() {
      mockRepository = MockNotificationRepository();
      useCase = GetNotifications(mockRepository);
    });

    group('call', () {
      test(
        'should return list of notifications when repository succeeds',
        () async {
          // arrange
          final expectedNotifications = [
            NotificationEntity(
              id: 'notif_1',
              title: 'Test Notification 1',
              body: 'This is a test notification',
              type: 'friend_request',
              data: const {'fromUserId': 'user_123'},
              isRead: false,
              createdAt: DateTime.now(),
            ),
            NotificationEntity(
              id: 'notif_2',
              title: 'Test Notification 2',
              body: 'Another test notification',
              type: 'friend_accepted',
              data: const {'fromUserId': 'user_456'},
              isRead: true,
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            ),
          ];

          when(
            () => mockRepository.getNotifications(),
          ).thenAnswer((_) async => expectedNotifications);

          // act
          final result = await useCase.call();

          // assert
          expect(result, expectedNotifications);
          expect(result.length, 2);
          expect(result.first.id, 'notif_1');
          verify(() => mockRepository.getNotifications()).called(1);
        },
      );

      test('should return empty list when no notifications exist', () async {
        // arrange
        final expectedNotifications = <NotificationEntity>[];

        when(
          () => mockRepository.getNotifications(),
        ).thenAnswer((_) async => expectedNotifications);

        // act
        final result = await useCase.call();

        // assert
        expect(result, isEmpty);
        verify(() => mockRepository.getNotifications()).called(1);
      });

      test('should propagate repository exceptions', () async {
        // arrange
        final exception = Exception('Repository error');

        when(() => mockRepository.getNotifications()).thenThrow(exception);

        // act & assert
        expect(() => useCase.call(), throwsA(exception));

        verify(() => mockRepository.getNotifications()).called(1);
      });

      test('should return notifications with different types', () async {
        // arrange
        final expectedNotifications = [
          NotificationEntity(
            id: 'notif_friend_request',
            title: 'Friend Request',
            body: 'Someone sent you a friend request',
            type: 'friend_request',
            data: const {'fromUserId': 'user_123'},
            isRead: false,
            createdAt: DateTime.now(),
          ),
          NotificationEntity(
            id: 'notif_friend_accepted',
            title: 'Friend Accepted',
            body: 'Your friend request was accepted',
            type: 'friend_accepted',
            data: const {'fromUserId': 'user_456'},
            isRead: false,
            createdAt: DateTime.now(),
          ),
          NotificationEntity(
            id: 'notif_message',
            title: 'New Message',
            body: 'You have a new message',
            type: 'new_message',
            data: const {'fromUserId': 'user_789', 'messageId': 'msg_123'},
            isRead: false,
            createdAt: DateTime.now(),
          ),
        ];

        when(
          () => mockRepository.getNotifications(),
        ).thenAnswer((_) async => expectedNotifications);

        // act
        final result = await useCase.call();

        // assert
        expect(result.length, 3);
        expect(result.map((n) => n.type).toSet(), {
          'friend_request',
          'friend_accepted',
          'new_message',
        });
        verify(() => mockRepository.getNotifications()).called(1);
      });

      test('should handle mixed read/unread notifications', () async {
        // arrange
        final expectedNotifications = [
          NotificationEntity(
            id: 'notif_unread',
            title: 'Unread Notification',
            body: 'This is unread',
            type: 'friend_request',
            data: const {'fromUserId': 'user_123'},
            isRead: false,
            createdAt: DateTime.now(),
          ),
          NotificationEntity(
            id: 'notif_read',
            title: 'Read Notification',
            body: 'This is read',
            type: 'friend_accepted',
            data: const {'fromUserId': 'user_456'},
            isRead: true,
            createdAt: DateTime.now(),
          ),
        ];

        when(
          () => mockRepository.getNotifications(),
        ).thenAnswer((_) async => expectedNotifications);

        // act
        final result = await useCase.call();

        // assert
        expect(result.length, 2);
        expect(result.where((n) => !n.isRead).length, 1);
        expect(result.where((n) => n.isRead).length, 1);
        verify(() => mockRepository.getNotifications()).called(1);
      });

      test('should handle notifications with additional data', () async {
        // arrange
        final expectedNotifications = [
          NotificationEntity(
            id: 'notif_with_image',
            title: 'Notification with Image',
            body: 'This notification has an image',
            type: 'general',
            data: const {'customField': 'customValue'},
            isRead: false,
            createdAt: DateTime.now(),
            imageUrl: 'https://example.com/image.jpg',
            actionUrl: 'https://example.com/action',
          ),
        ];

        when(
          () => mockRepository.getNotifications(),
        ).thenAnswer((_) async => expectedNotifications);

        // act
        final result = await useCase.call();

        // assert
        expect(result.length, 1);
        expect(result.first.imageUrl, 'https://example.com/image.jpg');
        expect(result.first.actionUrl, 'https://example.com/action');
        expect(result.first.data['customField'], 'customValue');
        verify(() => mockRepository.getNotifications()).called(1);
      });

      test('should handle multiple consecutive calls', () async {
        // arrange
        final expectedNotifications = [
          NotificationEntity(
            id: 'notif_1',
            title: 'Test Notification',
            body: 'Test body',
            type: 'general',
            data: const {},
            isRead: false,
            createdAt: DateTime.now(),
          ),
        ];

        when(
          () => mockRepository.getNotifications(),
        ).thenAnswer((_) async => expectedNotifications);

        // act
        final result1 = await useCase.call();
        final result2 = await useCase.call();

        // assert
        expect(result1, expectedNotifications);
        expect(result2, expectedNotifications);
        verify(() => mockRepository.getNotifications()).called(2);
      });
    });
  });
}
