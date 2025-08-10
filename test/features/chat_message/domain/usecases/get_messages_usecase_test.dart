import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chatas/features/chat_message/domain/usecases/get_messages_usecase.dart';
import 'package:chatas/features/chat_message/domain/repositories/chat_message_repository.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/data/models/chat_message_model.dart';

import 'get_messages_usecase_test.mocks.dart';

@GenerateMocks([ChatMessageRepository])
void main() {
  group('GetMessagesUseCase', () {
    late GetMessagesUseCase useCase;
    late MockChatMessageRepository mockRepository;

    setUp(() {
      mockRepository = MockChatMessageRepository();
      useCase = GetMessagesUseCase(repository: mockRepository);
    });

    final tDateTime = DateTime(2024, 1, 1, 12, 0);
    final tChatMessageModel = ChatMessageModel(
      id: 'msg_123',
      chatThreadId: 'thread_456',
      senderId: 'user_789',
      senderName: 'Test User',
      senderAvatarUrl: 'https://example.com/avatar.jpg',
      content: 'Hello world!',
      type: 'text',
      status: 'sent',
      sentAt: tDateTime,
      isDeleted: false,
      reactions: const {},
      replyToMessageId: null,
      createdAt: tDateTime,
      updatedAt: tDateTime,
    );

    final tChatMessage = tChatMessageModel.toEntity();

    test('should get messages from repository', () async {
      // arrange
      when(
        mockRepository.getMessages('thread_456', 'user_123'),
      ).thenAnswer((_) async => [tChatMessage]);

      // act
      final result = await useCase('thread_456', 'user_123');

      // assert
      expect(result, [tChatMessage]);
      verify(mockRepository.getMessages('thread_456', 'user_123')).called(1);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(
        mockRepository.getMessages('thread_456', 'user_123'),
      ).thenThrow(Exception('Failed to get messages'));

      // act & assert
      expect(
        () => useCase('thread_456', 'user_123'),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.getMessages('thread_456', 'user_123')).called(1);
    });

    test('should return empty list when no messages exist', () async {
      // arrange
      when(
        mockRepository.getMessages('thread_456', 'user_123'),
      ).thenAnswer((_) async => <ChatMessage>[]);

      // act
      final result = await useCase('thread_456', 'user_123');

      // assert
      expect(result, isEmpty);
      verify(mockRepository.getMessages('thread_456', 'user_123')).called(1);
    });

    test('should handle multiple messages', () async {
      // arrange
      final message1 = tChatMessage;
      final message2 = ChatMessageModel(
        id: 'msg_124',
        chatThreadId: 'thread_456',
        senderId: 'user_790',
        senderName: 'Test User 2',
        senderAvatarUrl: 'https://example.com/avatar2.jpg',
        content: 'Hello again!',
        type: 'text',
        status: 'sent',
        sentAt: tDateTime,
        isDeleted: false,
        reactions: const {},
        replyToMessageId: null,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      ).toEntity();

      when(
        mockRepository.getMessages('thread_456', 'user_123'),
      ).thenAnswer((_) async => [message1, message2]);

      // act
      final result = await useCase('thread_456', 'user_123');

      // assert
      expect(result, hasLength(2));
      expect(result[0], message1);
      expect(result[1], message2);
      verify(mockRepository.getMessages('thread_456', 'user_123')).called(1);
    });
  });
}
