import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chatas/features/chat_message/domain/repositories/chat_message_repository.dart';
import 'package:chatas/features/chat_message/domain/usecases/remove_reaction_usecase.dart';
import 'package:chatas/features/chat_message/constants/chat_message_page_constants.dart';

/// Mock implementation of ChatMessageRepository for testing.
class MockChatMessageRepository extends Mock implements ChatMessageRepository {}

void main() {
  group('RemoveReactionUseCase Tests', () {
    late RemoveReactionUseCase useCase;
    late MockChatMessageRepository mockRepository;

    setUp(() {
      mockRepository = MockChatMessageRepository();
      useCase = RemoveReactionUseCase(repository: mockRepository);
    });

    group('call method', () {
      test('calls repository removeReaction with temporaryUserId', () async {
        // Arrange
        const messageId = 'test_message_id';
        const providedUserId = 'provided_user_id';

        when(
          () => mockRepository.removeReaction(any(), any()),
        ).thenAnswer((_) async {});

        // Act
        await useCase.call(messageId: messageId, userId: providedUserId);

        // Assert
        verify(
          () => mockRepository.removeReaction(
            messageId,
            ChatMessagePageConstants.temporaryUserId,
          ),
        ).called(1);
      });

      test(
        'ignores provided userId and uses temporaryUserId for consistency',
        () async {
          // Arrange
          const messageId = 'test_message_id';
          const providedUserId = 'different_user_id';

          when(
            () => mockRepository.removeReaction(any(), any()),
          ).thenAnswer((_) async {});

          // Act
          await useCase.call(messageId: messageId, userId: providedUserId);

          // Assert
          // Should use temporaryUserId, not the provided userId
          verify(
            () => mockRepository.removeReaction(
              messageId,
              ChatMessagePageConstants.temporaryUserId,
            ),
          ).called(1);

          // Verify it does NOT use the provided userId
          verifyNever(
            () => mockRepository.removeReaction(messageId, providedUserId),
          );
        },
      );

      test('propagates repository exceptions', () async {
        // Arrange
        const messageId = 'test_message_id';
        const userId = 'user_id';
        final exception = Exception('Repository error');

        when(
          () => mockRepository.removeReaction(any(), any()),
        ).thenThrow(exception);

        // Act & Assert
        expect(
          () => useCase.call(messageId: messageId, userId: userId),
          throwsA(exception),
        );
      });

      test('handles empty message ID', () async {
        // Arrange
        const messageId = '';
        const userId = 'user_id';

        when(
          () => mockRepository.removeReaction(any(), any()),
        ).thenAnswer((_) async {});

        // Act
        await useCase.call(messageId: messageId, userId: userId);

        // Assert
        verify(
          () => mockRepository.removeReaction(
            messageId,
            ChatMessagePageConstants.temporaryUserId,
          ),
        ).called(1);
      });

      test('handles empty provided userId', () async {
        // Arrange
        const messageId = 'test_message_id';
        const userId = '';

        when(
          () => mockRepository.removeReaction(any(), any()),
        ).thenAnswer((_) async {});

        // Act
        await useCase.call(messageId: messageId, userId: userId);

        // Assert
        // Should still use temporaryUserId regardless of empty provided userId
        verify(
          () => mockRepository.removeReaction(
            messageId,
            ChatMessagePageConstants.temporaryUserId,
          ),
        ).called(1);
      });
    });

    group('constructor', () {
      test('creates instance with repository', () {
        // Act
        final useCase = RemoveReactionUseCase(repository: mockRepository);

        // Assert
        expect(useCase, isNotNull);
      });
    });
  });
}
