import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chatas/features/chat_message/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:chatas/features/chat_message/domain/repositories/chat_message_repository.dart';

/// Mock implementation for testing.
class MockChatMessageRepository extends Mock implements ChatMessageRepository {}

void main() {
  group('MarkMessagesAsReadUseCase Tests', () {
    late MarkMessagesAsReadUseCase useCase;
    late MockChatMessageRepository mockRepository;

    setUp(() {
      mockRepository = MockChatMessageRepository();
      useCase = MarkMessagesAsReadUseCase(mockRepository);
    });

    group('call', () {
      test(
        'should call repository markMessagesAsRead with correct parameters',
        () async {
          // arrange
          const chatThreadId = 'thread_123';
          const userId = 'user_456';

          when(
            () => mockRepository.markMessagesAsRead(any(), any()),
          ).thenAnswer((_) async {});

          // act
          await useCase.call(chatThreadId: chatThreadId, userId: userId);

          // assert
          verify(
            () => mockRepository.markMessagesAsRead(chatThreadId, userId),
          ).called(1);
        },
      );

      test('should handle repository success correctly', () async {
        // arrange
        const chatThreadId = 'thread_123';
        const userId = 'user_456';

        when(
          () => mockRepository.markMessagesAsRead(any(), any()),
        ).thenAnswer((_) async {});

        // act
        await useCase.call(chatThreadId: chatThreadId, userId: userId);

        // assert
        verify(
          () => mockRepository.markMessagesAsRead(chatThreadId, userId),
        ).called(1);
      });

      test('should propagate repository exceptions', () async {
        // arrange
        const chatThreadId = 'thread_123';
        const userId = 'user_456';
        final exception = Exception('Repository error');

        when(
          () => mockRepository.markMessagesAsRead(any(), any()),
        ).thenThrow(exception);

        // act & assert
        expect(
          () => useCase.call(chatThreadId: chatThreadId, userId: userId),
          throwsA(exception),
        );

        verify(
          () => mockRepository.markMessagesAsRead(chatThreadId, userId),
        ).called(1);
      });

      test('should handle empty chatThreadId', () async {
        // arrange
        const chatThreadId = '';
        const userId = 'user_456';

        when(
          () => mockRepository.markMessagesAsRead(any(), any()),
        ).thenAnswer((_) async {});

        // act
        await useCase.call(chatThreadId: chatThreadId, userId: userId);

        // assert
        verify(
          () => mockRepository.markMessagesAsRead(chatThreadId, userId),
        ).called(1);
      });

      test('should handle empty userId', () async {
        // arrange
        const chatThreadId = 'thread_123';
        const userId = '';

        when(
          () => mockRepository.markMessagesAsRead(any(), any()),
        ).thenAnswer((_) async {});

        // act
        await useCase.call(chatThreadId: chatThreadId, userId: userId);

        // assert
        verify(
          () => mockRepository.markMessagesAsRead(chatThreadId, userId),
        ).called(1);
      });

      test('should handle special characters in IDs', () async {
        // arrange
        const chatThreadId = 'thread_123-special@chars.com';
        const userId = 'user_456_àáâãäåæç';

        when(
          () => mockRepository.markMessagesAsRead(any(), any()),
        ).thenAnswer((_) async {});

        // act
        await useCase.call(chatThreadId: chatThreadId, userId: userId);

        // assert
        verify(
          () => mockRepository.markMessagesAsRead(chatThreadId, userId),
        ).called(1);
      });

      test('should handle very long IDs', () async {
        // arrange
        final longChatThreadId = 'thread_${'a' * 1000}';
        final longUserId = 'user_${'b' * 1000}';

        when(
          () => mockRepository.markMessagesAsRead(any(), any()),
        ).thenAnswer((_) async {});

        // act
        await useCase.call(chatThreadId: longChatThreadId, userId: longUserId);

        // assert
        verify(
          () => mockRepository.markMessagesAsRead(longChatThreadId, longUserId),
        ).called(1);
      });

      test('should be called multiple times without interference', () async {
        // arrange
        const chatThreadId1 = 'thread_123';
        const userId1 = 'user_456';
        const chatThreadId2 = 'thread_789';
        const userId2 = 'user_012';

        when(
          () => mockRepository.markMessagesAsRead(any(), any()),
        ).thenAnswer((_) async {});

        // act
        await useCase.call(chatThreadId: chatThreadId1, userId: userId1);
        await useCase.call(chatThreadId: chatThreadId2, userId: userId2);

        // assert
        verify(
          () => mockRepository.markMessagesAsRead(chatThreadId1, userId1),
        ).called(1);
        verify(
          () => mockRepository.markMessagesAsRead(chatThreadId2, userId2),
        ).called(1);
      });

      test('should handle concurrent calls correctly', () async {
        // arrange
        const chatThreadId = 'thread_123';
        const userId = 'user_456';

        when(() => mockRepository.markMessagesAsRead(any(), any())).thenAnswer((
          _,
        ) async {
          await Future.delayed(const Duration(milliseconds: 100));
        });

        // act
        final futures = List.generate(
          5,
          (_) => useCase.call(chatThreadId: chatThreadId, userId: userId),
        );

        await Future.wait(futures);

        // assert
        verify(
          () => mockRepository.markMessagesAsRead(chatThreadId, userId),
        ).called(5);
      });
    });
  });
}
