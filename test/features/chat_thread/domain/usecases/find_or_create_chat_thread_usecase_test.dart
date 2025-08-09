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

    test('should unhide and return hidden thread when found', () async {
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
      when(
        mockRepository.unhideChatThread(hiddenThread.id, currentUserId),
      ).thenAnswer((_) async {});

      // act
      final result = await useCase(
        currentUserId: currentUserId,
        friendId: friendId,
        friendName: friendName,
        friendAvatarUrl: friendAvatarUrl,
      );

      // assert
      expect(result, equals(hiddenThread));
      verify(mockRepository.getAllChatThreads(currentUserId)).called(1);
      verify(
        mockRepository.unhideChatThread(hiddenThread.id, currentUserId),
      ).called(1);
    });

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
      'should create new temporary thread when forceCreateNew is true',
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
          forceCreateNew: true, // Force create new
        );

        // assert
        expect(result.id, startsWith('temp_${friendId}_'));
        expect(result.name, equals(friendName));
        expect(result.avatarUrl, equals(friendAvatarUrl));
        expect(result.members, equals([currentUserId, friendId]));
        expect(result.isGroup, isFalse);
        // Should not call getAllChatThreads when forceCreateNew is true
        verifyNever(mockRepository.getAllChatThreads(any));
        verifyNever(mockRepository.unhideChatThread(any, any));
      },
    );

    test(
      'should create new temporary thread when forceCreateNew is true even with visible thread',
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
          forceCreateNew: true, // Force create new
        );

        // assert
        expect(result.id, startsWith('temp_${friendId}_'));
        expect(result.name, equals(friendName));
        expect(result.avatarUrl, equals(friendAvatarUrl));
        expect(result.members, equals([currentUserId, friendId]));
        expect(result.isGroup, isFalse);
        // Should not call getAllChatThreads when forceCreateNew is true
        verifyNever(mockRepository.getAllChatThreads(any));
        verifyNever(mockRepository.unhideChatThread(any, any));
      },
    );

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
  });
}
