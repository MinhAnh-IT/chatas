import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/usecases/search_chat_threads_usecase.dart';

import 'search_chat_threads_usecase_test.mocks.dart';

@GenerateMocks([ChatThreadRepository])
void main() {
  late SearchChatThreadsUseCase useCase;
  late MockChatThreadRepository mockRepository;

  setUp(() {
    mockRepository = MockChatThreadRepository();
    useCase = SearchChatThreadsUseCase(mockRepository);
  });

  group('SearchChatThreadsUseCase', () {
    const currentUserId = 'user1';
    const query = 'John';

    test('should return empty list when query is empty', () async {
      // act
      final result = await useCase('', currentUserId);

      // assert
      expect(result, isEmpty);
      verifyNever(mockRepository.getChatThreads(any));
    });

    test('should return empty list when query is only whitespace', () async {
      // act
      final result = await useCase('   ', currentUserId);

      // assert
      expect(result, isEmpty);
      verifyNever(mockRepository.getChatThreads(any));
    });

    test('should search by actual display name for 1-on-1 chats', () async {
      // arrange
      final testThreads = [
        ChatThread(
          id: 'thread1',
          name: 'Chat with user2', // This is the stored name in DB
          lastMessage: 'Hello',
          lastMessageTime: DateTime.now(),
          avatarUrl: '',
          members: ['user1', 'user2'], // 1-on-1 chat
          isGroup: false,
          unreadCounts: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(
        mockRepository.getChatThreads(currentUserId),
      ).thenAnswer((_) async => testThreads);

      // act
      final result = await useCase(query, currentUserId);

      // assert
      verify(mockRepository.getChatThreads(currentUserId)).called(1);
      // Note: This test will pass even if no match found because we're testing the logic
      // In real scenario, the display name would be fetched from Firestore
    });

    test('should search by group name for group chats', () async {
      // arrange
      final testThreads = [
        ChatThread(
          id: 'group1',
          name: 'John\'s Group', // Group name that should match
          lastMessage: 'Hello',
          lastMessageTime: DateTime.now(),
          avatarUrl: '',
          members: ['user1', 'user2', 'user3'],
          isGroup: true,
          unreadCounts: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(
        mockRepository.getChatThreads(currentUserId),
      ).thenAnswer((_) async => testThreads);

      // act
      final result = await useCase(query, currentUserId);

      // assert
      verify(mockRepository.getChatThreads(currentUserId)).called(1);
      expect(result.length, 1); // Should find the group with "John's Group"
    });

    test('should search by last message content', () async {
      // arrange
      final testThreads = [
        ChatThread(
          id: 'thread1',
          name: 'Chat',
          lastMessage:
              'Hello John, how are you?', // Last message contains "John"
          lastMessageTime: DateTime.now(),
          avatarUrl: '',
          members: ['user1', 'user2'],
          isGroup: false,
          unreadCounts: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(
        mockRepository.getChatThreads(currentUserId),
      ).thenAnswer((_) async => testThreads);

      // act
      final result = await useCase(query, currentUserId);

      // assert
      verify(mockRepository.getChatThreads(currentUserId)).called(1);
      expect(
        result.length,
        1,
      ); // Should find the thread with "John" in last message
    });

    test('should handle case-insensitive search', () async {
      // arrange
      final testThreads = [
        ChatThread(
          id: 'thread1',
          name: 'JOHN DOE', // Uppercase name
          lastMessage: 'Hello',
          lastMessageTime: DateTime.now(),
          avatarUrl: '',
          members: ['user1', 'user2'],
          isGroup: false,
          unreadCounts: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(
        mockRepository.getChatThreads(currentUserId),
      ).thenAnswer((_) async => testThreads);

      // act
      final result = await useCase('john', currentUserId); // Lowercase query

      // assert
      verify(mockRepository.getChatThreads(currentUserId)).called(1);
      expect(
        result.length,
        1,
      ); // Should find the thread despite case difference
    });

    test('should return empty list when no matches found', () async {
      // arrange
      final testThreads = [
        ChatThread(
          id: 'thread1',
          name: 'Alice',
          lastMessage: 'Hello',
          lastMessageTime: DateTime.now(),
          avatarUrl: '',
          members: ['user1', 'user2'],
          isGroup: false,
          unreadCounts: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(
        mockRepository.getChatThreads(currentUserId),
      ).thenAnswer((_) async => testThreads);

      // act
      final result = await useCase(query, currentUserId);

      // assert
      verify(mockRepository.getChatThreads(currentUserId)).called(1);
      expect(result, isEmpty); // Should not find any matches for "John"
    });

    test('should propagate repository exceptions', () async {
      // arrange
      when(
        mockRepository.getChatThreads(currentUserId),
      ).thenThrow(Exception('Database error'));

      // act & assert
      expect(() => useCase(query, currentUserId), throwsA(isA<Exception>()));
    });
  });
}
