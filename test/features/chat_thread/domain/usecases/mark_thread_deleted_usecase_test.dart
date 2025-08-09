import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chatas/features/chat_thread/domain/usecases/mark_thread_deleted_usecase.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';

import 'mark_thread_deleted_usecase_test.mocks.dart';

@GenerateMocks([ChatThreadRepository])
void main() {
  group('MarkThreadDeletedUseCase', () {
    late MarkThreadDeletedUseCase useCase;
    late MockChatThreadRepository mockRepository;

    setUp(() {
      mockRepository = MockChatThreadRepository();
      useCase = MarkThreadDeletedUseCase(mockRepository);
    });

    test('should mark thread as deleted for user with current time as cutoff', () async {
      // Arrange
      const threadId = 'test_thread_123';
      const userId = 'user_456';
      final beforeCall = DateTime.now();

      when(mockRepository.markThreadDeletedForUser(any, any, any))
          .thenAnswer((_) async {});

      // Act
      await useCase(
        threadId: threadId,
        userId: userId,
      );

      // Assert
      verify(mockRepository.markThreadDeletedForUser(
        threadId,
        userId,
        argThat(isA<DateTime>()),
      )).called(1);
    });

    test('should mark thread as deleted with lastMessageTime as cutoff when provided', () async {
      // Arrange
      const threadId = 'test_thread_123';
      const userId = 'user_456';
      final lastMessageTime = DateTime.now().add(const Duration(hours: 1));

      when(mockRepository.markThreadDeletedForUser(any, any, any))
          .thenAnswer((_) async {});

      // Act
      await useCase(
        threadId: threadId,
        userId: userId,
        lastMessageTime: lastMessageTime,
      );

      // Assert
      verify(mockRepository.markThreadDeletedForUser(
        threadId,
        userId,
        lastMessageTime,
      )).called(1);
    });

    test('should throw ArgumentError when threadId is empty', () async {
      // Arrange
      const userId = 'user_456';

      // Act & Assert
      expect(
        () => useCase(threadId: '', userId: userId),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(mockRepository.markThreadDeletedForUser(any, any, any));
    });

    test('should throw ArgumentError when userId is empty', () async {
      // Arrange
      const threadId = 'test_thread_123';

      // Act & Assert
      expect(
        () => useCase(threadId: threadId, userId: ''),
        throwsA(isA<ArgumentError>()),
      );

      verifyNever(mockRepository.markThreadDeletedForUser(any, any, any));
    });

    test('should propagate repository errors', () async {
      // Arrange
      const threadId = 'test_thread_123';
      const userId = 'user_456';
      const errorMessage = 'Database error';

      when(mockRepository.markThreadDeletedForUser(any, any, any))
          .thenThrow(Exception(errorMessage));

      // Act & Assert
      expect(
        () => useCase(threadId: threadId, userId: userId),
        throwsA(isA<Exception>()),
      );
    });
  });
}
