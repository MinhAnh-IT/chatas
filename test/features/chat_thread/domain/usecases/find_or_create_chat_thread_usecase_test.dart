import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/usecases/find_or_create_chat_thread_usecase.dart';

import 'find_or_create_chat_thread_usecase_test.mocks.dart';

@GenerateMocks([ChatThreadRepository])
void main() {
  late FindOrCreateChatThreadUseCase useCase;
  late MockChatThreadRepository mockRepository;

  setUp(() {
    mockRepository = MockChatThreadRepository();
    useCase = FindOrCreateChatThreadUseCase(mockRepository);
  });

  group('FindOrCreateChatThreadUseCase', () {
    const currentUserId = 'user1';
    const friendId = 'user2';
    const friendName = 'John Doe';
    const friendAvatarUrl = 'https://example.com/avatar.jpg';

    test('should throw exception when trying to chat with yourself', () async {
      // act & assert
      expect(
        () => useCase(
          currentUserId: currentUserId,
          friendId: currentUserId, // Same as currentUserId
          friendName: friendName,
          friendAvatarUrl: friendAvatarUrl,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should return existing visible thread when found', () async {
      // arrange
      final existingThread = ChatThread(
        id: 'existing_thread',
        name: 'Existing Chat',
        lastMessage: 'Hello',
        lastMessageTime: DateTime.now(),
        avatarUrl: '',
        members: [currentUserId, friendId],
        isGroup: false,
        unreadCounts: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        mockRepository.getAllChatThreads(currentUserId),
      ).thenAnswer((_) async => [existingThread]);

      // act
      final result = await useCase(
        currentUserId: currentUserId,
        friendId: friendId,
        friendName: friendName,
        friendAvatarUrl: friendAvatarUrl,
      );

      // assert
      expect(result, equals(existingThread));
      verify(mockRepository.getAllChatThreads(currentUserId)).called(1);
      verifyNever(mockRepository.unhideChatThread(any, any));
    });

    test(
      'should return hidden thread with lastRecreatedAt when hidden thread found',
      () async {
        // arrange
        final hiddenThread = ChatThread(
          id: 'hidden_thread',
          name: 'Hidden Chat',
          lastMessage: 'Hello',
          lastMessageTime: DateTime.now(),
          avatarUrl: '',
          members: [currentUserId, friendId],
          isGroup: false,
          unreadCounts: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          hiddenFor: [currentUserId], // Hidden for current user
        );

        when(
          mockRepository.getAllChatThreads(currentUserId),
        ).thenAnswer((_) async => [hiddenThread]);

        // act
        final result = await useCase(
          currentUserId: currentUserId,
          friendId: friendId,
          friendName: friendName,
          friendAvatarUrl: friendAvatarUrl,
        );

        // assert
        expect(
          result.id,
          equals('hidden_thread'),
        ); // Should return original thread ID
        expect(
          result.lastRecreatedAt,
          isNotNull,
        ); // Should have lastRecreatedAt set
        expect(result.name, equals('Hidden Chat')); // Should keep original name
        expect(result.members, equals([currentUserId, friendId]));
        expect(result.isGroup, isFalse);
        verify(mockRepository.getAllChatThreads(currentUserId)).called(1);
        verifyNever(mockRepository.unhideChatThread(any, any));
        verifyNever(mockRepository.updateLastRecreatedAt(any, any));
        verifyNever(mockRepository.resetThreadForUser(any, any));
      },
    );

    test(
      'should return hidden thread with lastRecreatedAt when forceCreateNew is true for 1-1 chat',
      () async {
        // arrange
        final hiddenThread = ChatThread(
          id: 'hidden_thread',
          name: 'Hidden Chat',
          lastMessage: 'Hello',
          lastMessageTime: DateTime.now(),
          avatarUrl: '',
          members: [currentUserId, friendId],
          isGroup: false,
          unreadCounts: {currentUserId: 5}, // Has unread count
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          hiddenFor: [currentUserId], // Hidden for current user only
        );

        when(
          mockRepository.getAllChatThreads(currentUserId),
        ).thenAnswer((_) async => [hiddenThread]);

        // act
        final result = await useCase(
          currentUserId: currentUserId,
          friendId: friendId,
          friendName: friendName,
          friendAvatarUrl: friendAvatarUrl,
          forceCreateNew:
              true, // Should still return hidden thread but with lastRecreatedAt
        );

        // assert
        expect(
          result.id,
          equals('hidden_thread'),
        ); // Should return original thread ID
        expect(
          result.lastRecreatedAt,
          isNotNull,
        ); // Should have lastRecreatedAt set
        expect(result.name, equals('Hidden Chat')); // Should keep original name
        expect(result.members, equals([currentUserId, friendId]));
        expect(result.isGroup, isFalse);
        verify(mockRepository.getAllChatThreads(currentUserId)).called(1);
        verifyNever(mockRepository.unhideChatThread(any, any));
        verifyNever(mockRepository.updateLastRecreatedAt(any, any));
        verifyNever(mockRepository.resetThreadForUser(any, any));
      },
    );

    test(
      'should create new temporary thread when no existing thread found',
      () async {
        // arrange
        when(
          mockRepository.getAllChatThreads(currentUserId),
        ).thenAnswer((_) async => []);

        // act
        final result = await useCase(
          currentUserId: currentUserId,
          friendId: friendId,
          friendName: friendName,
          friendAvatarUrl: friendAvatarUrl,
        );

        // assert
        expect(result.id, startsWith('temp_${friendId}_'));
        expect(result.name, equals(friendName));
        expect(result.avatarUrl, equals(friendAvatarUrl));
        expect(result.members, equals([currentUserId, friendId]));
        expect(result.isGroup, isFalse);
        verify(mockRepository.getAllChatThreads(currentUserId)).called(1);
        verifyNever(mockRepository.unhideChatThread(any, any));
      },
    );

    test(
      'should return hidden thread with lastRecreatedAt when both users have hidden the thread',
      () async {
        // arrange
        final hiddenThread = ChatThread(
          id: 'hidden_thread',
          name: 'Hidden Chat',
          lastMessage: 'Hello',
          lastMessageTime: DateTime.now(),
          avatarUrl: '',
          members: [currentUserId, friendId],
          isGroup: false,
          unreadCounts: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          hiddenFor: [currentUserId, friendId], // Both users have hidden it
        );

        when(
          mockRepository.getAllChatThreads(currentUserId),
        ).thenAnswer((_) async => [hiddenThread]);

        // act
        final result = await useCase(
          currentUserId: currentUserId,
          friendId: friendId,
          friendName: friendName,
          friendAvatarUrl: friendAvatarUrl,
        );

        // assert - Now returns the hidden thread with lastRecreatedAt
        expect(result.id, equals('hidden_thread'));
        expect(result.lastRecreatedAt, isNotNull);
        expect(result.isHiddenFor(currentUserId), isTrue);
        verify(mockRepository.getAllChatThreads(currentUserId)).called(1);
      },
    );

    test(
      'should return existing visible thread when forceCreateNew is true',
      () async {
        // arrange
        final visibleThread = ChatThread(
          id: 'visible_thread',
          name: 'Visible Chat',
          lastMessage: 'Hello',
          lastMessageTime: DateTime.now(),
          avatarUrl: '',
          members: [currentUserId, friendId],
          isGroup: false,
          unreadCounts: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastRecreatedAt: null,
        );

        when(
          mockRepository.getAllChatThreads(currentUserId),
        ).thenAnswer((_) async => [visibleThread]);

        // act
        final result = await useCase(
          currentUserId: currentUserId,
          friendId: friendId,
          friendName: friendName,
          friendAvatarUrl: friendAvatarUrl,
          forceCreateNew: true, // Should still return existing visible thread
        );

        // assert
        expect(result, equals(visibleThread)); // Should return existing thread
        verify(mockRepository.getAllChatThreads(currentUserId)).called(1);
        verifyNever(mockRepository.unhideChatThread(any, any));
      },
    );

    test('should reuse hidden thread when forceCreateNew is false', () async {
      // Arrange
      final hiddenThread = ChatThread(
        id: 'existing_thread',
        name: 'John Doe',
        lastMessage: 'Hello',
        lastMessageTime: DateTime.now(),
        avatarUrl: 'avatar.jpg',
        members: ['user1', 'user2'],
        isGroup: false,
        unreadCounts: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        hiddenFor: ['user1'], // Hidden for user1 only
      );

      when(
        mockRepository.getAllChatThreads('user1'),
      ).thenAnswer((_) async => [hiddenThread]);

      // Act
      final result = await useCase(
        currentUserId: 'user1',
        friendId: 'user2',
        friendName: 'John Doe',
        friendAvatarUrl: 'avatar.jpg',
        forceCreateNew: false,
      );

      // Assert
      expect(
        result.id,
        equals('existing_thread'),
      ); // Should return original thread ID
      expect(
        result.lastRecreatedAt,
        isNotNull,
      ); // Should have lastRecreatedAt set
      expect(result.name, equals('John Doe')); // Should keep original name
      verify(mockRepository.getAllChatThreads('user1')).called(1);
      verifyNever(mockRepository.createChatThread(any));
    });

    test('should find and reuse hidden thread between two users', () async {
      // Arrange
      final hiddenThread = ChatThread(
        id: 'existing_thread_123',
        name: 'John Doe',
        lastMessage: 'Hello',
        lastMessageTime: DateTime.now(),
        avatarUrl: 'avatar.jpg',
        members: ['userA', 'userB'], // userA and userB
        isGroup: false,
        unreadCounts: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        hiddenFor: ['userB'], // Hidden for userB only
      );

      when(
        mockRepository.getAllChatThreads('userB'),
      ).thenAnswer((_) async => [hiddenThread]);

      // Act - userB tries to create chat with userA
      final result = await useCase(
        currentUserId: 'userB',
        friendId: 'userA',
        friendName: 'John Doe',
        friendAvatarUrl: 'avatar.jpg',
        forceCreateNew: false,
      );

      // Assert
      expect(
        result.id,
        equals('existing_thread_123'),
      ); // Should return original thread ID
      expect(
        result.lastRecreatedAt,
        isNotNull,
      ); // Should have lastRecreatedAt set
      expect(result.name, equals('John Doe')); // Should keep original name
      verify(mockRepository.getAllChatThreads('userB')).called(1);
      verifyNever(mockRepository.createChatThread(any));
    });

    test('should ignore group chats when searching for 1-on-1 chat', () async {
      // arrange
      final groupThread = ChatThread(
        id: 'group_thread',
        name: 'Group Chat',
        lastMessage: 'Hello',
        lastMessageTime: DateTime.now(),
        avatarUrl: '',
        members: [currentUserId, friendId, 'user3'],
        isGroup: true, // Group chat
        unreadCounts: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        mockRepository.getAllChatThreads(currentUserId),
      ).thenAnswer((_) async => [groupThread]);

      // act
      final result = await useCase(
        currentUserId: currentUserId,
        friendId: friendId,
        friendName: friendName,
        friendAvatarUrl: friendAvatarUrl,
      );

      // assert
      expect(result.id, startsWith('temp_${friendId}_'));
      expect(result.name, equals(friendName));
      verify(mockRepository.getAllChatThreads(currentUserId)).called(1);
      verifyNever(mockRepository.unhideChatThread(any, any));
    });

    test('should propagate repository exceptions', () async {
      // arrange
      when(
        mockRepository.getAllChatThreads(currentUserId),
      ).thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => useCase(
          currentUserId: currentUserId,
          friendId: friendId,
          friendName: friendName,
          friendAvatarUrl: friendAvatarUrl,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'should properly handle real scenario: B deletes chat with A, then recreates',
      () async {
        // Arrange - Simulate a hidden thread between userA and userB
        final hiddenThread = ChatThread(
          id: 'chat_userA_1234567890',
          name: 'User A',
          lastMessage: 'Hello from A',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
          avatarUrl: 'avatar_a.jpg',
          members: ['userA', 'userB'], // userA and userB
          isGroup: false,
          unreadCounts: {'userB': 0},
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          hiddenFor: ['userB'], // Hidden for userB only (B deleted the chat)
        );

        when(
          mockRepository.getAllChatThreads('userB'),
        ).thenAnswer((_) async => [hiddenThread]);

        // Act - userB tries to create chat with userA (recreate scenario)
        final result = await useCase(
          currentUserId: 'userB',
          friendId: 'userA',
          friendName: 'User A',
          friendAvatarUrl: 'avatar_a.jpg',
          forceCreateNew: false,
        );

        // Assert
        expect(
          result.id,
          equals('chat_userA_1234567890'),
        ); // Should return original thread ID
        expect(
          result.lastRecreatedAt,
          isNotNull,
        ); // Should have lastRecreatedAt set
        expect(result.name, equals('User A')); // Should keep original name
        expect(result.members, contains('userA'));
        expect(result.members, contains('userB'));
        verify(mockRepository.getAllChatThreads('userB')).called(1);
        verifyNever(mockRepository.createChatThread(any));
      },
    );

    test(
      'should find hidden thread even when friendId is in different order',
      () async {
        // Arrange - Simulate a hidden thread where members might be in different order
        final hiddenThread = ChatThread(
          id: 'chat_userA_1234567890',
          name: 'User A',
          lastMessage: 'Hello from A',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
          avatarUrl: 'avatar_a.jpg',
          members: ['userB', 'userA'], // Note: userB comes first, then userA
          isGroup: false,
          unreadCounts: {'userB': 0},
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          hiddenFor: ['userB'], // Hidden for userB only
        );

        when(
          mockRepository.getAllChatThreads('userB'),
        ).thenAnswer((_) async => [hiddenThread]);

        // Act - userB tries to create chat with userA
        final result = await useCase(
          currentUserId: 'userB',
          friendId: 'userA',
          friendName: 'User A',
          friendAvatarUrl: 'avatar_a.jpg',
          forceCreateNew: false,
        );

        // Assert
        expect(
          result.id,
          equals('chat_userA_1234567890'),
        ); // Should return original thread ID
        expect(
          result.lastRecreatedAt,
          isNotNull,
        ); // Should have lastRecreatedAt set
        expect(result.name, equals('User A')); // Should keep original name
        expect(result.members, contains('userA'));
        expect(result.members, contains('userB'));
        verify(mockRepository.getAllChatThreads('userB')).called(1);
        verifyNever(mockRepository.createChatThread(any));
      },
    );

    test(
      'should prevent duplicate threads when user hides and recreates chat',
      () async {
        // Arrange - Simulate a scenario where userB hides a chat with userA
        final hiddenThread = ChatThread(
          id: 'chat_userA_1234567890',
          name: 'User A',
          lastMessage: 'Hello from A',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
          avatarUrl: 'avatar_a.jpg',
          members: ['userA', 'userB'],
          isGroup: false,
          unreadCounts: {'userB': 0},
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
          hiddenFor: ['userB'], // Hidden for userB only
        );

        when(
          mockRepository.getAllChatThreads('userB'),
        ).thenAnswer((_) async => [hiddenThread]);

        // Act 1 - userB tries to create chat with userA (should find hidden thread)
        final result1 = await useCase(
          currentUserId: 'userB',
          friendId: 'userA',
          friendName: 'User A',
          friendAvatarUrl: 'avatar_a.jpg',
          forceCreateNew: false,
        );

        // Assert 1 - Should return original hidden thread with lastRecreatedAt
        expect(result1.id, equals('chat_userA_1234567890'));
        expect(result1.lastRecreatedAt, isNotNull);
        expect(result1.name, equals('User A'));

        // Act 2 - userB tries to create chat with userA again (should still find same hidden thread)
        final result2 = await useCase(
          currentUserId: 'userB',
          friendId: 'userA',
          friendName: 'User A',
          friendAvatarUrl: 'avatar_a.jpg',
          forceCreateNew: false,
        );

        // Assert 2 - Should return the same original hidden thread with lastRecreatedAt
        expect(result2.id, equals('chat_userA_1234567890'));
        expect(result2.lastRecreatedAt, isNotNull);
        expect(result2.name, equals('User A'));

        // Verify that getAllChatThreads was called twice (once for each attempt)
        verify(mockRepository.getAllChatThreads('userB')).called(2);
        verifyNever(mockRepository.createChatThread(any));
      },
    );
  });
}
