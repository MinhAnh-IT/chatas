import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/domain/repositories/chat_message_repository.dart';
import 'package:chatas/features/chat_message/domain/usecases/add_reaction_usecase.dart';
import 'package:chatas/features/chat_message/constants/chat_message_page_constants.dart';

/// Mock implementation of ChatMessageRepository for testing.
class MockChatMessageRepository extends Mock implements ChatMessageRepository {}

void main() {
  setUpAll(() {
    // Register fallback value for ReactionType enum
    registerFallbackValue(ReactionType.like);
  });
  group('AddReactionUseCase Tests', () {
    late AddReactionUseCase useCase;
    late MockChatMessageRepository mockRepository;

    setUp(() {
      mockRepository = MockChatMessageRepository();
      useCase = AddReactionUseCase(mockRepository);
    });

    group('call method', () {
      test('calls repository addReaction with correct parameters', () async {
        // Arrange
        const messageId = 'test_message_id';
        const reactionType = ReactionType.like;

        when(
          () => mockRepository.addReaction(any(), any(), any()),
        ).thenAnswer((_) async {});

        // Act
        await useCase.call(messageId: messageId, reaction: reactionType, userId: 'test_user');

        // Assert
        verify(
          () => mockRepository.addReaction(
            messageId,
            'test_user',
            reactionType,
          ),
        ).called(1);
      });

      test('uses temporaryUserId for current user ID', () async {
        // Arrange
        const messageId = 'test_message_id';
        const reactionType = ReactionType.love;

        when(
          () => mockRepository.addReaction(any(), any(), any()),
        ).thenAnswer((_) async {});

        // Act
        await useCase.call(messageId: messageId, reaction: reactionType, userId: 'test_user');

        // Assert
        verify(
          () => mockRepository.addReaction(
            messageId,
            'test_user',
            reactionType,
          ),
        ).called(1);
      });

      test('propagates repository exceptions', () async {
        // Arrange
        const messageId = 'test_message_id';
        const reactionType = ReactionType.sad;
        final exception = Exception('Repository error');

        when(
          () => mockRepository.addReaction(any(), any(), any()),
        ).thenThrow(exception);

        // Act & Assert
        expect(
          () => useCase.call(messageId: messageId, reaction: reactionType, userId: 'test_user'),
          throwsA(exception),
        );
      });

      test('works with all reaction types', () async {
        // Arrange
        const messageId = 'test_message_id';

        when(
          () => mockRepository.addReaction(any(), any(), any()),
        ).thenAnswer((_) async {});

        // Act & Assert
        for (final reactionType in ReactionType.values) {
          await useCase.call(messageId: messageId, reaction: reactionType, userId: 'test_user');

          verify(
            () => mockRepository.addReaction(
              messageId,
              'test_user',
              reactionType,
            ),
          ).called(1);
        }
      });

      test('handles empty message ID', () async {
        // Arrange
        const messageId = '';
        const reactionType = ReactionType.angry;

        when(
          () => mockRepository.addReaction(any(), any(), any()),
        ).thenAnswer((_) async {});

        // Act
        await useCase.call(messageId: messageId, reaction: reactionType, userId: 'test_user');

        // Assert
        verify(
          () => mockRepository.addReaction(
            messageId,
            'test_user',
            reactionType,
          ),
        ).called(1);
      });
    });

    group('constructor', () {
      test('creates instance with repository', () {
        // Act
        final useCase = AddReactionUseCase(mockRepository);

        // Assert
        expect(useCase.repository, equals(mockRepository));
      });
    });
  });
}
