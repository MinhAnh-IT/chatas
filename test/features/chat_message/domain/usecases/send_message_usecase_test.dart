import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/domain/repositories/chat_message_repository.dart';
import 'package:chatas/features/chat_message/domain/usecases/send_message_usecase.dart';
import 'package:chatas/features/chat_message/constants/chat_message_page_constants.dart';

/// Mock implementation of ChatMessageRepository for testing.
class MockChatMessageRepository extends Mock implements ChatMessageRepository {}

void main() {
  group('SendMessageUseCase Tests', () {
    late SendMessageUseCase useCase;
    late MockChatMessageRepository mockRepository;

    setUp(() {
      mockRepository = MockChatMessageRepository();
      useCase = SendMessageUseCase(mockRepository);
    });

    setUpAll(() {
      registerFallbackValue(
        ChatMessage(
          id: 'fallback',
          chatThreadId: 'fallback',
          senderId: 'fallback',
          senderName: 'fallback',
          senderAvatarUrl: 'fallback',
          content: 'fallback',
          sentAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    });

    group('call method', () {
      test('creates and sends message with required parameters', () async {
        // Arrange
        const chatThreadId = 'thread_123';
        const content = 'Test message content';

        when(() => mockRepository.sendMessage(any())).thenAnswer((_) async {});

        // Act
        await useCase.call(chatThreadId: chatThreadId, content: content);

        // Assert
        final captured = verify(
          () => mockRepository.sendMessage(captureAny()),
        ).captured;
        final sentMessage = captured.first as ChatMessage;

        expect(sentMessage.chatThreadId, equals(chatThreadId));
        expect(sentMessage.content, equals(content));
        expect(
          sentMessage.senderId,
          equals(ChatMessagePageConstants.temporaryUserId),
        );
        expect(
          sentMessage.senderName,
          equals(ChatMessagePageConstants.temporaryUserName),
        );
        expect(
          sentMessage.senderAvatarUrl,
          equals(ChatMessagePageConstants.temporaryAvatarUrl),
        );
        expect(sentMessage.type, equals(MessageType.text));
        expect(sentMessage.status, equals(MessageStatus.sending));
        expect(sentMessage.replyToMessageId, isNull);
      });

      test('generates unique message ID based on timestamp', () async {
        // Arrange
        const chatThreadId = 'thread_123';
        const content = 'Test message';

        when(() => mockRepository.sendMessage(any())).thenAnswer((_) async {});

        // Act
        await useCase.call(chatThreadId: chatThreadId, content: content);

        await Future.delayed(
          const Duration(milliseconds: 1),
        ); // Ensure different timestamp

        await useCase.call(chatThreadId: chatThreadId, content: content);

        // Assert
        final captured = verify(
          () => mockRepository.sendMessage(captureAny()),
        ).captured;
        final message1 = captured[0] as ChatMessage;
        final message2 = captured[1] as ChatMessage;

        expect(message1.id, isNot(equals(message2.id)));
        expect(message1.id, startsWith('msg_'));
        expect(message2.id, startsWith('msg_'));
      });

      test('uses custom message type when provided', () async {
        // Arrange
        const chatThreadId = 'thread_123';
        const content = 'Image message';
        const messageType = MessageType.image;

        when(() => mockRepository.sendMessage(any())).thenAnswer((_) async {});

        // Act
        await useCase.call(
          chatThreadId: chatThreadId,
          content: content,
          type: messageType,
        );

        // Assert
        final captured = verify(
          () => mockRepository.sendMessage(captureAny()),
        ).captured;
        final sentMessage = captured.first as ChatMessage;

        expect(sentMessage.type, equals(MessageType.image));
      });

      test('includes replyToMessageId when provided', () async {
        // Arrange
        const chatThreadId = 'thread_123';
        const content = 'Reply message';
        const replyToMessageId = 'original_message_123';

        when(() => mockRepository.sendMessage(any())).thenAnswer((_) async {});

        // Act
        await useCase.call(
          chatThreadId: chatThreadId,
          content: content,
          replyToMessageId: replyToMessageId,
        );

        // Assert
        final captured = verify(
          () => mockRepository.sendMessage(captureAny()),
        ).captured;
        final sentMessage = captured.first as ChatMessage;

        expect(sentMessage.replyToMessageId, equals(replyToMessageId));
      });

      test('sets timestamps correctly', () async {
        // Arrange
        const chatThreadId = 'thread_123';
        const content = 'Test message';
        final beforeTime = DateTime.now();

        when(() => mockRepository.sendMessage(any())).thenAnswer((_) async {});

        // Act
        await useCase.call(chatThreadId: chatThreadId, content: content);

        final afterTime = DateTime.now();

        // Assert
        final captured = verify(
          () => mockRepository.sendMessage(captureAny()),
        ).captured;
        final sentMessage = captured.first as ChatMessage;

        expect(
          sentMessage.sentAt.isAfter(beforeTime) ||
              sentMessage.sentAt.isAtSameMomentAs(beforeTime),
          isTrue,
        );
        expect(
          sentMessage.sentAt.isBefore(afterTime) ||
              sentMessage.sentAt.isAtSameMomentAs(afterTime),
          isTrue,
        );
        expect(sentMessage.createdAt, equals(sentMessage.sentAt));
        expect(sentMessage.updatedAt, equals(sentMessage.sentAt));
      });

      test('propagates repository exceptions', () async {
        // Arrange
        const chatThreadId = 'thread_123';
        const content = 'Test message';
        final exception = Exception('Repository error');

        when(() => mockRepository.sendMessage(any())).thenThrow(exception);

        // Act & Assert
        expect(
          () => useCase.call(chatThreadId: chatThreadId, content: content),
          throwsA(exception),
        );
      });

      test('handles empty content', () async {
        // Arrange
        const chatThreadId = 'thread_123';
        const content = '';

        when(() => mockRepository.sendMessage(any())).thenAnswer((_) async {});

        // Act
        await useCase.call(chatThreadId: chatThreadId, content: content);

        // Assert
        final captured = verify(
          () => mockRepository.sendMessage(captureAny()),
        ).captured;
        final sentMessage = captured.first as ChatMessage;

        expect(sentMessage.content, equals(''));
      });

      test('handles all message types', () async {
        // Arrange
        const chatThreadId = 'thread_123';
        const content = 'Test message';

        when(() => mockRepository.sendMessage(any())).thenAnswer((_) async {});

        // Act & Assert
        for (final messageType in MessageType.values) {
          await useCase.call(
            chatThreadId: chatThreadId,
            content: content,
            type: messageType,
          );

          final captured = verify(
            () => mockRepository.sendMessage(captureAny()),
          ).captured;
          final sentMessage = captured.last as ChatMessage;

          expect(sentMessage.type, equals(messageType));
        }
      });
    });

    group('constructor', () {
      test('creates instance with repository', () {
        // Act
        final useCase = SendMessageUseCase(mockRepository);

        // Assert
        expect(useCase.repository, equals(mockRepository));
      });
    });
  });
}
