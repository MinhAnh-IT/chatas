import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chatas/features/chat_thread/domain/usecases/send_first_message_usecase.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/domain/repositories/chat_message_repository.dart';

import 'send_first_message_usecase_test.mocks.dart';

@GenerateMocks([ChatThreadRepository, ChatMessageRepository])
void main() {
  group('SendFirstMessageUseCase', () {
    late SendFirstMessageUseCase useCase;
    late MockChatThreadRepository mockChatThreadRepository;
    late MockChatMessageRepository mockChatMessageRepository;

    setUp(() {
      mockChatThreadRepository = MockChatThreadRepository();
      mockChatMessageRepository = MockChatMessageRepository();
      useCase = SendFirstMessageUseCase(
        chatThreadRepository: mockChatThreadRepository,
        chatMessageRepository: mockChatMessageRepository,
      );
    });

    test('should unhide existing thread and set lastRecreatedAt when recreating chat', () async {
      // Arrange
      final now = DateTime.now();
      final hiddenThread = ChatThread(
        id: 'original_thread_123', // This is the original hidden thread ID
        name: 'User A',
        lastMessage: 'Old message',
        lastMessageTime: now.subtract(Duration(hours: 1)),
        avatarUrl: 'avatar_a.jpg',
        members: ['userA', 'userB'], // Sorted members for 1-1 chat
        isGroup: false,
        unreadCounts: {},
        createdAt: now.subtract(Duration(days: 1)),
        updatedAt: now.subtract(Duration(hours: 1)),
        lastRecreatedAt: now, // This indicates recreation scenario
        hiddenFor: ['userB'], // Hidden for userB
      );

      final message = ChatMessage(
        id: 'msg_123',
        chatThreadId: 'original_thread_123',
        senderId: 'userB',
        senderName: 'User B',
        senderAvatarUrl: 'avatar_b.jpg',
        content: 'Hello A!',
        sentAt: now,
        createdAt: now,
        updatedAt: now,
      );

      when(mockChatThreadRepository.reviveThreadForUser('original_thread_123', 'userB'))
          .thenAnswer((_) async => {});
      when(mockChatThreadRepository.updateVisibilityCutoff('original_thread_123', 'userB', now))
          .thenAnswer((_) async => {});
      when(mockChatThreadRepository.resetUnreadCount('original_thread_123', 'userB'))
          .thenAnswer((_) async => {});
      when(mockChatMessageRepository.sendMessage(any))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(
        chatThread: hiddenThread,
        message: message,
      );

      // Assert
      expect(result, 'original_thread_123');
      verify(mockChatThreadRepository.reviveThreadForUser('original_thread_123', 'userB')).called(1);
      verify(mockChatThreadRepository.updateVisibilityCutoff('original_thread_123', 'userB', now)).called(1);
      verify(mockChatThreadRepository.resetUnreadCount('original_thread_123', 'userB')).called(1);
      verify(mockChatMessageRepository.sendMessage(any)).called(1);
    });

    test('should create new thread when temporary thread is used', () async {
      // Arrange
      final now = DateTime.now();
      final tempThread = ChatThread(
        id: 'temp_userA_1234567890', // Temporary thread ID
        name: 'User A',
        lastMessage: '',
        lastMessageTime: now,
        avatarUrl: 'avatar_a.jpg',
        members: ['userA', 'userB'], // Sorted members for 1-1 chat
        isGroup: false,
        unreadCounts: {},
        createdAt: now,
        updatedAt: now,
        // No lastRecreatedAt - this is a completely new thread
      );

      final message = ChatMessage(
        id: 'msg_123',
        chatThreadId: 'temp_userA_1234567890',
        senderId: 'userB',
        senderName: 'User B',
        senderAvatarUrl: 'avatar_b.jpg',
        content: 'Hello A!',
        sentAt: now,
        createdAt: now,
        updatedAt: now,
      );

      when(mockChatThreadRepository.createChatThread(any))
          .thenAnswer((_) async => {});
      when(mockChatMessageRepository.sendMessage(any))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase(
        chatThread: tempThread,
        message: message,
      );

      // Assert
      expect(result, 'userA_userB'); // Should use proper 1-1 thread ID format
      verify(mockChatThreadRepository.createChatThread(any)).called(1);
      verify(mockChatMessageRepository.sendMessage(any)).called(1);
      verifyNever(mockChatThreadRepository.reviveThreadForUser(any, any));
      verifyNever(mockChatThreadRepository.updateVisibilityCutoff(any, any, any));
    });
  });
}
