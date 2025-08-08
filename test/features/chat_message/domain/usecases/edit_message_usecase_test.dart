import 'package:chatas/features/chat_message/domain/repositories/chat_message_repository.dart';
import 'package:chatas/features/chat_message/domain/usecases/edit_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'edit_message_usecase_test.mocks.dart';

@GenerateMocks([ChatMessageRepository])
void main() {
  late EditMessageUseCase useCase;
  late MockChatMessageRepository mockRepository;

  setUp(() {
    mockRepository = MockChatMessageRepository();
    useCase = EditMessageUseCase(repository: mockRepository);
  });

  group('EditMessageUseCase', () {
    const messageId = 'test_message_id';
    const newContent = 'Updated message content';
    const userId = 'test_user_id';

    test('should call repository editMessage with correct parameters', () async {
      // arrange
      when(mockRepository.editMessage(
        messageId: anyNamed('messageId'),
        newContent: anyNamed('newContent'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async {});

      // act
      await useCase(
        messageId: messageId,
        newContent: newContent,
        userId: userId,
      );

      // assert
      verify(mockRepository.editMessage(
        messageId: messageId,
        newContent: newContent,
        userId: userId,
      )).called(1);
    });

    test('should throw exception when content is empty', () async {
      // act & assert
      expect(
        () => useCase(
          messageId: messageId,
          newContent: '',
          userId: userId,
        ),
        throwsA(isA<Exception>()),
      );

      // verify repository method was not called
      verifyNever(mockRepository.editMessage(
        messageId: anyNamed('messageId'),
        newContent: anyNamed('newContent'),
        userId: anyNamed('userId'),
      ));
    });

    test('should throw exception when content is only whitespace', () async {
      // act & assert
      expect(
        () => useCase(
          messageId: messageId,
          newContent: '   ',
          userId: userId,
        ),
        throwsA(isA<Exception>()),
      );

      // verify repository method was not called
      verifyNever(mockRepository.editMessage(
        messageId: anyNamed('messageId'),
        newContent: anyNamed('newContent'),
        userId: anyNamed('userId'),
      ));
    });

    test('should trim whitespace from content before calling repository', () async {
      // arrange
      const contentWithWhitespace = '  Updated content  ';
      const expectedTrimmedContent = 'Updated content';
      
      when(mockRepository.editMessage(
        messageId: anyNamed('messageId'),
        newContent: anyNamed('newContent'),
        userId: anyNamed('userId'),
      )).thenAnswer((_) async {});

      // act
      await useCase(
        messageId: messageId,
        newContent: contentWithWhitespace,
        userId: userId,
      );

      // assert
      verify(mockRepository.editMessage(
        messageId: messageId,
        newContent: expectedTrimmedContent,
        userId: userId,
      )).called(1);
    });

    test('should propagate repository exceptions', () async {
      // arrange
      const errorMessage = 'Repository error';
      when(mockRepository.editMessage(
        messageId: anyNamed('messageId'),
        newContent: anyNamed('newContent'),
        userId: anyNamed('userId'),
      )).thenThrow(Exception(errorMessage));

      // act & assert
      expect(
        () => useCase(
          messageId: messageId,
          newContent: newContent,
          userId: userId,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
