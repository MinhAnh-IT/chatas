import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/usecases/get_chat_threads_usecase.dart';

import 'get_chat_threads_usecase_test.mocks.dart';

// Generate mock classes
@GenerateMocks([ChatThreadRepository])
void main() {
  group('GetChatThreadsUseCase', () {
    late GetChatThreadsUseCase useCase;
    late MockChatThreadRepository mockRepository;

    setUp(() {
      mockRepository = MockChatThreadRepository();
      useCase = GetChatThreadsUseCase(mockRepository);
    });

    group('call', () {
      final tChatThreads = [
        ChatThread(
          id: '1',
          name: 'John Doe',
          lastMessage: 'Hello there!',
          lastMessageTime: DateTime(2024, 1, 1, 10, 30),
          avatarUrl: 'https://example.com/avatar1.png',
          members: const ['user1', 'user2'],
          isGroup: false,
          unreadCount: 5,
          createdAt: DateTime(2024, 1, 1, 9, 0),
          updatedAt: DateTime(2024, 1, 1, 10, 30),
        ),
        ChatThread(
          id: '2',
          name: 'Jane Smith',
          lastMessage: 'Hi! How are you?',
          lastMessageTime: DateTime(2024, 1, 1, 11, 0),
          avatarUrl: 'https://example.com/avatar2.png',
          members: const ['user1', 'user3'],
          isGroup: false,
          unreadCount: 2,
          createdAt: DateTime(2024, 1, 1, 8, 0),
          updatedAt: DateTime(2024, 1, 1, 11, 0),
        ),
      ];

      test('should return list of chat threads when repository call is successful', () async {
        // Arrange
        when(mockRepository.getChatThreads())
            .thenAnswer((_) async => tChatThreads);

        // Act
        final result = await useCase();

        // Assert
        expect(result, equals(tChatThreads));
        expect(result, isA<List<ChatThread>>());
        expect(result.length, 2);
        verify(mockRepository.getChatThreads()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return empty list when repository returns empty list', () async {
        // Arrange
        when(mockRepository.getChatThreads())
            .thenAnswer((_) async => <ChatThread>[]);

        // Act
        final result = await useCase();

        // Assert
        expect(result, equals(<ChatThread>[]));
        expect(result, isEmpty);
        verify(mockRepository.getChatThreads()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should throw exception when repository throws exception', () async {
        // Arrange
        const errorMessage = 'Network connection failed';
        when(mockRepository.getChatThreads())
            .thenThrow(Exception(errorMessage));

        // Act & Assert
        expect(
          () => useCase(),
          throwsA(isA<Exception>()),
        );
        verify(mockRepository.getChatThreads()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should throw specific exception type when repository throws specific exception', () async {
        // Arrange
        when(mockRepository.getChatThreads())
            .thenThrow(const FormatException('Invalid data format'));

        // Act & Assert
        expect(
          () => useCase(),
          throwsA(isA<FormatException>()),
        );
        verify(mockRepository.getChatThreads()).called(1);
      });

      test('should call repository exactly once', () async {
        // Arrange
        when(mockRepository.getChatThreads())
            .thenAnswer((_) async => tChatThreads);

        // Act
        await useCase();

        // Assert
        verify(mockRepository.getChatThreads()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should preserve order of chat threads from repository', () async {
        // Arrange
        final orderedThreads = [
          ChatThread(
            id: 'first',
            name: 'First Thread',
            lastMessage: 'First message',
            lastMessageTime: DateTime(2024, 1, 1, 9, 0),
            avatarUrl: 'https://example.com/first.png',
            members: const ['user1'],
            isGroup: false,
            unreadCount: 0,
            createdAt: DateTime(2024, 1, 1, 8, 0),
            updatedAt: DateTime(2024, 1, 1, 9, 0),
          ),
          ChatThread(
            id: 'second',
            name: 'Second Thread',
            lastMessage: 'Second message',
            lastMessageTime: DateTime(2024, 1, 1, 10, 0),
            avatarUrl: 'https://example.com/second.png',
            members: const ['user2'],
            isGroup: false,
            unreadCount: 1,
            createdAt: DateTime(2024, 1, 1, 8, 30),
            updatedAt: DateTime(2024, 1, 1, 10, 0),
          ),
        ];
        when(mockRepository.getChatThreads())
            .thenAnswer((_) async => orderedThreads);

        // Act
        final result = await useCase();

        // Assert
        expect(result.first.id, 'first');
        expect(result.last.id, 'second');
        expect(result, equals(orderedThreads));
      });
    });
  });
}
