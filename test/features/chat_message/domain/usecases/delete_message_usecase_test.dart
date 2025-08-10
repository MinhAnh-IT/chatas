import 'package:chatas/features/chat_message/domain/repositories/chat_message_repository.dart';
import 'package:chatas/features/chat_message/domain/usecases/delete_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'delete_message_usecase_test.mocks.dart';

@GenerateMocks([ChatMessageRepository])
void main() {
  late DeleteMessageUseCase useCase;
  late MockChatMessageRepository mockRepository;

  setUp(() {
    mockRepository = MockChatMessageRepository();
    useCase = DeleteMessageUseCase(repository: mockRepository);
  });

  group('DeleteMessageUseCase', () {
    const messageId = 'test_message_id';
    const userId = 'test_user_id';

    test(
      'should call repository deleteMessageWithValidation with correct parameters',
      () async {
        // arrange
        when(
          mockRepository.deleteMessageWithValidation(
            messageId: anyNamed('messageId'),
            userId: anyNamed('userId'),
          ),
        ).thenAnswer((_) async {});

        // act
        await useCase(messageId: messageId, userId: userId);

        // assert
        verify(
          mockRepository.deleteMessageWithValidation(
            messageId: messageId,
            userId: userId,
          ),
        ).called(1);
      },
    );

    test('should propagate repository exceptions', () async {
      // arrange
      const errorMessage = 'You can only delete your own messages';
      when(
        mockRepository.deleteMessageWithValidation(
          messageId: anyNamed('messageId'),
          userId: anyNamed('userId'),
        ),
      ).thenThrow(Exception(errorMessage));

      // act & assert
      expect(
        () => useCase(messageId: messageId, userId: userId),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle permission denied exceptions', () async {
      // arrange
      when(
        mockRepository.deleteMessageWithValidation(
          messageId: anyNamed('messageId'),
          userId: anyNamed('userId'),
        ),
      ).thenThrow(Exception('You can only delete your own messages'));

      // act & assert
      expect(
        () => useCase(messageId: messageId, userId: userId),
        throwsA(
          allOf([
            isA<Exception>(),
            predicate((e) => e.toString().contains('delete your own messages')),
          ]),
        ),
      );
    });

    test('should handle message not found exceptions', () async {
      // arrange
      when(
        mockRepository.deleteMessageWithValidation(
          messageId: anyNamed('messageId'),
          userId: anyNamed('userId'),
        ),
      ).thenThrow(Exception('Message not found'));

      // act & assert
      expect(
        () => useCase(messageId: messageId, userId: userId),
        throwsA(
          allOf([
            isA<Exception>(),
            predicate((e) => e.toString().contains('Message not found')),
          ]),
        ),
      );
    });
  });
}
