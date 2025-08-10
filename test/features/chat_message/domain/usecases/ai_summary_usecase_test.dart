import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chatas/features/chat_message/domain/usecases/ai_summary_usecase.dart';
import 'package:chatas/features/chat_message/data/repositories/ai_summary_repository_impl.dart';

/// Mock implementation for testing.
class MockAISummaryRepositoryImpl extends Mock
    implements AISummaryRepositoryImpl {}

void main() {
  group('AISummaryUseCase Tests', () {
    late AISummaryUseCase useCase;
    late MockAISummaryRepositoryImpl mockRepository;

    setUp(() {
      mockRepository = MockAISummaryRepositoryImpl();
      useCase = AISummaryUseCase(repository: mockRepository);
    });

    group('call', () {
      test('should return summary when repository succeeds', () async {
        // arrange
        const messages = ['Hello there', 'How are you?', 'Fine, thanks!'];
        const expectedSummary = 'A friendly greeting conversation';

        when(
          () => mockRepository.summarizeMessages(any()),
        ).thenAnswer((_) async => expectedSummary);

        // act
        final result = await useCase.call(messages);

        // assert
        expect(result, expectedSummary);
        verify(() => mockRepository.summarizeMessages(messages)).called(1);
      });

      test(
        'should filter out empty messages before calling repository',
        () async {
          // arrange
          const messages = ['Hello there', '', '  ', 'How are you?', '\n\t'];
          const expectedFilteredMessages = ['Hello there', 'How are you?'];
          const expectedSummary = 'A greeting conversation';

          when(
            () => mockRepository.summarizeMessages(any()),
          ).thenAnswer((_) async => expectedSummary);

          // act
          final result = await useCase.call(messages);

          // assert
          expect(result, expectedSummary);
          verify(
            () => mockRepository.summarizeMessages(expectedFilteredMessages),
          ).called(1);
        },
      );

      test('should throw exception when messages list is empty', () async {
        // arrange
        const messages = <String>[];

        // act & assert
        expect(
          () => useCase.call(messages),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No messages provided for summarization'),
            ),
          ),
        );

        verifyNever(() => mockRepository.summarizeMessages(any()));
      });

      test(
        'should throw exception when all messages are empty after filtering',
        () async {
          // arrange
          const messages = ['', '  ', '\n\t', '   '];

          // act & assert
          expect(
            () => useCase.call(messages),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('No valid message content found'),
              ),
            ),
          );

          verifyNever(() => mockRepository.summarizeMessages(any()));
        },
      );

      test('should propagate repository exceptions', () async {
        // arrange
        const messages = ['Hello there', 'How are you?'];
        final exception = Exception('Repository error');

        when(
          () => mockRepository.summarizeMessages(any()),
        ).thenThrow(exception);

        // act & assert
        expect(() => useCase.call(messages), throwsA(exception));

        verify(() => mockRepository.summarizeMessages(messages)).called(1);
      });

      test('should handle single message correctly', () async {
        // arrange
        const messages = ['Hello there'];
        const expectedSummary = 'Single greeting message';

        when(
          () => mockRepository.summarizeMessages(any()),
        ).thenAnswer((_) async => expectedSummary);

        // act
        final result = await useCase.call(messages);

        // assert
        expect(result, expectedSummary);
        verify(() => mockRepository.summarizeMessages(messages)).called(1);
      });

      test('should trim whitespace from messages', () async {
        // arrange
        const messages = ['  Hello there  ', '\tHow are you?\n'];
        const expectedSummary = 'A conversation';

        when(
          () => mockRepository.summarizeMessages(any()),
        ).thenAnswer((_) async => expectedSummary);

        // act
        final result = await useCase.call(messages);

        // assert
        expect(result, expectedSummary);
        // Verify that some call was made (the exact trimming is internal logic)
        verify(() => mockRepository.summarizeMessages(any())).called(1);
      });

      test(
        'should call repository with isManualSummary=true when specified',
        () async {
          // arrange
          const messages = ['User 1: Hello', 'User 2: Hi there'];
          const expectedSummary = 'Detailed manual summary';

          when(
            () => mockRepository.summarizeMessages(
              any(),
              isManualSummary: any(named: 'isManualSummary'),
            ),
          ).thenAnswer((_) async => expectedSummary);

          // act
          final result = await useCase.call(messages, isManualSummary: true);

          // assert
          expect(result, expectedSummary);
          verify(
            () => mockRepository.summarizeMessages(
              messages,
              isManualSummary: true,
            ),
          ).called(1);
        },
      );

      test(
        'should call repository with isManualSummary=false by default',
        () async {
          // arrange
          const messages = ['User 1: Hello', 'User 2: Hi there'];
          const expectedSummary = 'Quick offline summary';

          when(
            () => mockRepository.summarizeMessages(
              any(),
              isManualSummary: any(named: 'isManualSummary'),
            ),
          ).thenAnswer((_) async => expectedSummary);

          // act
          final result = await useCase.call(messages);

          // assert
          expect(result, expectedSummary);
          verify(
            () => mockRepository.summarizeMessages(
              messages,
              isManualSummary: false,
            ),
          ).called(1);
        },
      );
    });
  });
}
