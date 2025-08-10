import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chatas/features/auth/domain/entities/user.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/domain/usecases/ai_summary_usecase.dart';
import 'package:chatas/shared/services/offline_summary_service.dart';

/// Mock implementation for testing.
class MockAISummaryUseCase extends Mock implements AISummaryUseCase {}

void main() {
  group('OfflineSummaryService Tests', () {
    late OfflineSummaryService service;
    late MockAISummaryUseCase mockAISummaryUseCase;

    setUp(() {
      mockAISummaryUseCase = MockAISummaryUseCase();
      service = OfflineSummaryService(aiSummaryUseCase: mockAISummaryUseCase);
    });

    group('wasUserOffline', () {
      test(
        'should return true when user was inactive for more than 5 minutes',
        () {
          final now = DateTime(2024, 1, 1, 12, 0, 0);
          final lastActive = DateTime(2024, 1, 1, 11, 54, 0); // 6 minutes ago

          final user = User(
            userId: 'test_user',
            isOnline: false,
            lastActive: lastActive,
            fullName: 'Test User',
            username: 'testuser',
            email: 'test@example.com',
            gender: 'male',
            birthDate: DateTime(1990, 1, 1),
            avatarUrl: 'https://example.com/avatar.jpg',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          );

          final result = service.wasUserOffline(user, now);
          expect(result, isTrue);
        },
      );

      test(
        'should return false when user was inactive for less than 5 minutes',
        () {
          final now = DateTime(2024, 1, 1, 12, 0, 0);
          final lastActive = DateTime(2024, 1, 1, 11, 56, 0); // 4 minutes ago

          final user = User(
            userId: 'test_user',
            isOnline: true,
            lastActive: lastActive,
            fullName: 'Test User',
            username: 'testuser',
            email: 'test@example.com',
            gender: 'male',
            birthDate: DateTime(1990, 1, 1),
            avatarUrl: 'https://example.com/avatar.jpg',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          );

          final result = service.wasUserOffline(user, now);
          expect(result, isFalse);
        },
      );

      test('should use current time when no time is provided', () {
        final lastActive = DateTime.now().subtract(const Duration(minutes: 10));

        final user = User(
          userId: 'test_user',
          isOnline: false,
          lastActive: lastActive,
          fullName: 'Test User',
          username: 'testuser',
          email: 'test@example.com',
          gender: 'male',
          birthDate: DateTime(1990, 1, 1),
          avatarUrl: 'https://example.com/avatar.jpg',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final result = service.wasUserOffline(user);
        expect(result, isTrue);
      });
    });

    group('getOfflineDuration', () {
      test('should return correct duration when user was offline', () {
        final now = DateTime(2024, 1, 1, 12, 0, 0);
        final lastActive = DateTime(2024, 1, 1, 11, 30, 0); // 30 minutes ago

        final user = User(
          userId: 'test_user',
          isOnline: false,
          lastActive: lastActive,
          fullName: 'Test User',
          username: 'testuser',
          email: 'test@example.com',
          gender: 'male',
          birthDate: DateTime(1990, 1, 1),
          avatarUrl: 'https://example.com/avatar.jpg',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final result = service.getOfflineDuration(user, now);
        expect(result, const Duration(minutes: 30));
      });
    });

    group('getOfflineMessages', () {
      test('should return messages sent after lastActive time', () {
        final lastActive = DateTime(2024, 1, 1, 12, 0, 0);
        final messages = [
          ChatMessage(
            id: '1',
            chatThreadId: 'thread1',
            senderId: 'user1',
            senderName: 'User 1',
            senderAvatarUrl: 'https://example.com/avatar1.jpg',
            content: 'Message 1',
            sentAt: DateTime(2024, 1, 1, 11, 59, 0), // Before lastActive
            createdAt: DateTime(2024, 1, 1, 11, 59, 0),
            updatedAt: DateTime(2024, 1, 1, 11, 59, 0),
          ),
          ChatMessage(
            id: '2',
            chatThreadId: 'thread1',
            senderId: 'user2',
            senderName: 'User 2',
            senderAvatarUrl: 'https://example.com/avatar2.jpg',
            content: 'Message 2',
            sentAt: DateTime(2024, 1, 1, 12, 1, 0), // After lastActive
            createdAt: DateTime(2024, 1, 1, 12, 1, 0),
            updatedAt: DateTime(2024, 1, 1, 12, 1, 0),
          ),
          ChatMessage(
            id: '3',
            chatThreadId: 'thread1',
            senderId: 'user3',
            senderName: 'User 3',
            senderAvatarUrl: 'https://example.com/avatar3.jpg',
            content: 'Message 3',
            sentAt: DateTime(2024, 1, 1, 12, 5, 0), // After lastActive
            createdAt: DateTime(2024, 1, 1, 12, 5, 0),
            updatedAt: DateTime(2024, 1, 1, 12, 5, 0),
          ),
        ];

        final result = service.getOfflineMessages(messages, lastActive);
        expect(result.length, 2);
        expect(result[0].id, '2');
        expect(result[1].id, '3');
      });

      test('should return empty list when no messages after lastActive', () {
        final lastActive = DateTime(2024, 1, 1, 12, 0, 0);
        final messages = [
          ChatMessage(
            id: '1',
            chatThreadId: 'thread1',
            senderId: 'user1',
            senderName: 'User 1',
            senderAvatarUrl: 'https://example.com/avatar1.jpg',
            content: 'Message 1',
            sentAt: DateTime(2024, 1, 1, 11, 59, 0), // Before lastActive
            createdAt: DateTime(2024, 1, 1, 11, 59, 0),
            updatedAt: DateTime(2024, 1, 1, 11, 59, 0),
          ),
        ];

        final result = service.getOfflineMessages(messages, lastActive);
        expect(result, isEmpty);
      });
    });

    group('extractMessageContent', () {
      test(
        'should extract and format text content with sender names and sort by time',
        () {
          final messages = [
            ChatMessage(
              id: '2',
              chatThreadId: 'thread1',
              senderId: 'user2',
              senderName: 'Bob',
              senderAvatarUrl: 'https://example.com/avatar2.jpg',
              content: 'How are you?',
              type: MessageType.text,
              sentAt: DateTime(2024, 1, 1, 12, 2, 0), // Later message
              createdAt: DateTime(2024, 1, 1, 12, 2, 0),
              updatedAt: DateTime(2024, 1, 1, 12, 2, 0),
            ),
            ChatMessage(
              id: '1',
              chatThreadId: 'thread1',
              senderId: 'user1',
              senderName: 'Alice',
              senderAvatarUrl: 'https://example.com/avatar1.jpg',
              content: 'Hello there',
              type: MessageType.text,
              sentAt: DateTime(2024, 1, 1, 12, 0, 0), // Earlier message
              createdAt: DateTime(2024, 1, 1, 12, 0, 0),
              updatedAt: DateTime(2024, 1, 1, 12, 0, 0),
            ),
            ChatMessage(
              id: '3',
              chatThreadId: 'thread1',
              senderId: 'user2',
              senderName: 'Bob',
              senderAvatarUrl: 'https://example.com/avatar2.jpg',
              content: 'Image message',
              type: MessageType.image,
              sentAt: DateTime(2024, 1, 1, 12, 1, 0),
              createdAt: DateTime(2024, 1, 1, 12, 1, 0),
              updatedAt: DateTime(2024, 1, 1, 12, 1, 0),
            ),
            ChatMessage(
              id: '4',
              chatThreadId: 'thread1',
              senderId: 'user3',
              senderName: 'Charlie',
              senderAvatarUrl: 'https://example.com/avatar3.jpg',
              content: '', // Empty content
              type: MessageType.text,
              sentAt: DateTime(2024, 1, 1, 12, 3, 0),
              createdAt: DateTime(2024, 1, 1, 12, 3, 0),
              updatedAt: DateTime(2024, 1, 1, 12, 3, 0),
            ),
          ];

          final result = service.extractMessageContent(messages);
          expect(result.length, 2);
          // Should be sorted by sentAt (oldest first) and formatted with sender names
          expect(result[0], equals('Alice: Hello there'));
          expect(result[1], equals('Bob: How are you?'));
        },
      );

      test('should handle empty list of messages', () {
        final result = service.extractMessageContent([]);
        expect(result, isEmpty);
      });

      test('should handle messages with same timestamp', () {
        final sameTime = DateTime(2024, 1, 1, 12, 0, 0);
        final messages = [
          ChatMessage(
            id: '2',
            chatThreadId: 'thread1',
            senderId: 'user2',
            senderName: 'Bob',
            senderAvatarUrl: 'https://example.com/avatar2.jpg',
            content: 'Second message',
            type: MessageType.text,
            sentAt: sameTime,
            createdAt: sameTime,
            updatedAt: sameTime,
          ),
          ChatMessage(
            id: '1',
            chatThreadId: 'thread1',
            senderId: 'user1',
            senderName: 'Alice',
            senderAvatarUrl: 'https://example.com/avatar1.jpg',
            content: 'First message',
            type: MessageType.text,
            sentAt: sameTime,
            createdAt: sameTime,
            updatedAt: sameTime,
          ),
        ];

        final result = service.extractMessageContent(messages);
        expect(result.length, 2);
        // When timestamps are same, order may vary but both should be present
        expect(result, contains('Alice: First message'));
        expect(result, contains('Bob: Second message'));
      });
    });

    group('summarizeOfflineMessages', () {
      test('should call AI summary use case with extracted content', () async {
        final messages = [
          ChatMessage(
            id: '1',
            chatThreadId: 'thread1',
            senderId: 'user1',
            senderName: 'User 1',
            senderAvatarUrl: 'https://example.com/avatar1.jpg',
            content: 'Hello there',
            type: MessageType.text,
            sentAt: DateTime(2024, 1, 1, 12, 0, 0),
            createdAt: DateTime(2024, 1, 1, 12, 0, 0),
            updatedAt: DateTime(2024, 1, 1, 12, 0, 0),
          ),
          ChatMessage(
            id: '2',
            chatThreadId: 'thread1',
            senderId: 'user2',
            senderName: 'User 2',
            senderAvatarUrl: 'https://example.com/avatar2.jpg',
            content: 'How are you?',
            type: MessageType.text,
            sentAt: DateTime(2024, 1, 1, 12, 1, 0),
            createdAt: DateTime(2024, 1, 1, 12, 1, 0),
            updatedAt: DateTime(2024, 1, 1, 12, 1, 0),
          ),
        ];

        const expectedSummary = 'Summary of the conversation';
        when(
          () => mockAISummaryUseCase.call(any()),
        ).thenAnswer((_) async => expectedSummary);

        final result = await service.summarizeOfflineMessages(messages);

        expect(result, expectedSummary);
        verify(
          () => mockAISummaryUseCase.call([
            'User 1: Hello there',
            'User 2: How are you?',
          ]),
        ).called(1);
      });

      test('should throw exception when no text content found', () async {
        final messages = [
          ChatMessage(
            id: '1',
            chatThreadId: 'thread1',
            senderId: 'user1',
            senderName: 'User 1',
            senderAvatarUrl: 'https://example.com/avatar1.jpg',
            content: '', // Empty content
            type: MessageType.text,
            sentAt: DateTime(2024, 1, 1, 12, 0, 0),
            createdAt: DateTime(2024, 1, 1, 12, 0, 0),
            updatedAt: DateTime(2024, 1, 1, 12, 0, 0),
          ),
        ];

        expect(
          () => service.summarizeOfflineMessages(messages),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('hasNewMessagesToSummarize', () {
      test(
        'should return true when there are new text messages to summarize',
        () {
          final lastActive = DateTime(2024, 1, 1, 12, 0, 0);
          final messages = [
            ChatMessage(
              id: '1',
              chatThreadId: 'thread1',
              senderId: 'user1',
              senderName: 'User 1',
              senderAvatarUrl: 'https://example.com/avatar1.jpg',
              content: 'New message',
              type: MessageType.text,
              sentAt: DateTime(2024, 1, 1, 12, 1, 0), // After lastActive
              createdAt: DateTime(2024, 1, 1, 12, 1, 0),
              updatedAt: DateTime(2024, 1, 1, 12, 1, 0),
            ),
          ];

          final result = service.hasNewMessagesToSummarize(
            messages,
            lastActive,
          );
          expect(result, isTrue);
        },
      );

      test(
        'should return false when there are no new text messages to summarize',
        () {
          final lastActive = DateTime(2024, 1, 1, 12, 0, 0);
          final messages = [
            ChatMessage(
              id: '1',
              chatThreadId: 'thread1',
              senderId: 'user1',
              senderName: 'User 1',
              senderAvatarUrl: 'https://example.com/avatar1.jpg',
              content: 'New message',
              type: MessageType.image, // Not text type
              sentAt: DateTime(2024, 1, 1, 12, 1, 0), // After lastActive
              createdAt: DateTime(2024, 1, 1, 12, 1, 0),
              updatedAt: DateTime(2024, 1, 1, 12, 1, 0),
            ),
          ];

          final result = service.hasNewMessagesToSummarize(
            messages,
            lastActive,
          );
          expect(result, isFalse);
        },
      );
    });
  });
}
