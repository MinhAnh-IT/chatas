import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chatas/features/chat_message/domain/usecases/get_messages_stream_usecase.dart';
import 'package:chatas/features/chat_message/domain/repositories/chat_message_repository.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/data/models/chat_message_model.dart';

import 'get_messages_stream_usecase_test.mocks.dart';

@GenerateMocks([ChatMessageRepository])
void main() {
  group('GetMessagesStreamUseCase', () {
    late GetMessagesStreamUseCase useCase;
    late MockChatMessageRepository mockRepository;

    setUp(() {
      mockRepository = MockChatMessageRepository();
      useCase = GetMessagesStreamUseCase(mockRepository);
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

    test('should get messages stream from repository', () async {
      // arrange
      when(
        mockRepository.messagesStream('thread_456'),
      ).thenAnswer((_) => Stream.value([tChatMessage]));

      // act
      final result = useCase('thread_456');

      // assert
      expect(result, emits([tChatMessage]));
      verify(mockRepository.messagesStream('thread_456')).called(1);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(
        mockRepository.messagesStream('thread_456'),
      ).thenThrow(Exception('Failed to get messages stream'));

      // act & assert
      expect(() => useCase('thread_456'), throwsA(isA<Exception>()));
      verify(mockRepository.messagesStream('thread_456')).called(1);
    });

    test('should return empty list stream when no messages exist', () async {
      // arrange
      when(
        mockRepository.messagesStream('thread_456'),
      ).thenAnswer((_) => Stream.value(<ChatMessage>[]));

      // act
      final result = useCase('thread_456');

      // assert
      expect(result, emits(isEmpty));
      verify(mockRepository.messagesStream('thread_456')).called(1);
    });

    test('should handle multiple messages in stream', () async {
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
        mockRepository.messagesStream('thread_456'),
      ).thenAnswer((_) => Stream.value([message1, message2]));

      // act
      final result = useCase('thread_456');

      // assert
      expect(result, emits([message1, message2]));
      verify(mockRepository.messagesStream('thread_456')).called(1);
    });

    test('should handle multiple stream emissions', () async {
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

      when(mockRepository.messagesStream('thread_456')).thenAnswer(
        (_) => Stream.fromIterable([
          [message1],
          [message1, message2],
        ]),
      );

      // act
      final result = useCase('thread_456');

      // assert
      expect(
        result,
        emitsInOrder([
          [message1],
          [message1, message2],
        ]),
      );
      verify(mockRepository.messagesStream('thread_456')).called(1);
    });
  });
}
