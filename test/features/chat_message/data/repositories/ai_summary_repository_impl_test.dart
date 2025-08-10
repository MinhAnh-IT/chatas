import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chatas/features/chat_message/data/repositories/ai_summary_repository_impl.dart';
import 'package:chatas/features/chat_message/data/datasources/ai/ai_summary_remote_data_source.dart';

/// Mock implementation for testing.
class MockAISummaryRemoteDataSource extends Mock
    implements AISummaryRemoteDataSource {}

void main() {
  group('AISummaryRepositoryImpl Tests', () {
    late AISummaryRepositoryImpl repository;
    late MockAISummaryRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockAISummaryRemoteDataSource();
      repository = AISummaryRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    group('summarizeMessages', () {
      test('should return summary when remote data source succeeds', () async {
        // arrange
        const messages = ['Hello there', 'How are you?', 'Fine, thanks!'];
        const expectedSummary = 'A friendly greeting conversation';

        when(
          () => mockRemoteDataSource.summarizeMessages(any()),
        ).thenAnswer((_) async => expectedSummary);

        // act
        final result = await repository.summarizeMessages(messages);

        // assert
        expect(result, expectedSummary);
        verify(
          () => mockRemoteDataSource.summarizeMessages(messages),
        ).called(1);
      });

      test('should throw exception when messages list is empty', () async {
        // arrange
        const messages = <String>[];

        // act & assert
        expect(
          () => repository.summarizeMessages(messages),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No messages provided for summarization'),
            ),
          ),
        );

        verifyNever(() => mockRemoteDataSource.summarizeMessages(any()));
      });

      test('should propagate remote data source exceptions', () async {
        // arrange
        const messages = ['Hello there', 'How are you?'];
        final exception = Exception('Network error');

        when(
          () => mockRemoteDataSource.summarizeMessages(any()),
        ).thenThrow(exception);

        // act & assert
        expect(
          () => repository.summarizeMessages(messages),
          throwsA(exception),
        );

        verify(
          () => mockRemoteDataSource.summarizeMessages(messages),
        ).called(1);
      });

      test('should handle single message correctly', () async {
        // arrange
        const messages = ['Hello there'];
        const expectedSummary = 'Single greeting message';

        when(
          () => mockRemoteDataSource.summarizeMessages(any()),
        ).thenAnswer((_) async => expectedSummary);

        // act
        final result = await repository.summarizeMessages(messages);

        // assert
        expect(result, expectedSummary);
        verify(
          () => mockRemoteDataSource.summarizeMessages(messages),
        ).called(1);
      });

      test('should handle large message list correctly', () async {
        // arrange
        final messages = List.generate(100, (i) => 'Message $i');
        const expectedSummary = 'Summary of 100 messages';

        when(
          () => mockRemoteDataSource.summarizeMessages(any()),
        ).thenAnswer((_) async => expectedSummary);

        // act
        final result = await repository.summarizeMessages(messages);

        // assert
        expect(result, expectedSummary);
        verify(
          () => mockRemoteDataSource.summarizeMessages(messages),
        ).called(1);
      });

      test('should handle special characters in messages', () async {
        // arrange
        const messages = ['Hello! 😊', 'How are you? 🤔', 'Fine, thanks! 👍'];
        const expectedSummary = 'Conversation with emojis';

        when(
          () => mockRemoteDataSource.summarizeMessages(any()),
        ).thenAnswer((_) async => expectedSummary);

        // act
        final result = await repository.summarizeMessages(messages);

        // assert
        expect(result, expectedSummary);
        verify(
          () => mockRemoteDataSource.summarizeMessages(messages),
        ).called(1);
      });

      test(
        'should handle timeout exceptions from remote data source',
        () async {
          // arrange
          const messages = ['Hello there', 'How are you?'];
          final timeoutException = Exception('Request timeout');

          when(
            () => mockRemoteDataSource.summarizeMessages(any()),
          ).thenThrow(timeoutException);

          // act & assert
          expect(
            () => repository.summarizeMessages(messages),
            throwsA(timeoutException),
          );

          verify(
            () => mockRemoteDataSource.summarizeMessages(messages),
          ).called(1);
        },
      );
    });
  });
}
