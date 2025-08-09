import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chatas/features/chat_thread/domain/usecases/create_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

import 'create_chat_thread_usecase_test.mocks.dart';

@GenerateMocks([ChatThreadRepository])
void main() {
  group('CreateChatThreadUseCase', () {
    late CreateChatThreadUseCase useCase;
    late MockChatThreadRepository mockRepository;

    setUp(() {
      mockRepository = MockChatThreadRepository();
      useCase = CreateChatThreadUseCase(mockRepository);
    });

    test('should create chat thread successfully', () async {
      // arrange
      when(mockRepository.createChatThread(any)).thenAnswer((_) async {});

      // act
      final result = await useCase(
        currentUserId: 'user1',
        friendId: 'user2',
        friendName: 'Test Friend',
        friendAvatarUrl: 'https://example.com/avatar.jpg',
      );

      // assert
      expect(result, isA<ChatThread>());
      expect(result.name, 'Test Friend');
      expect(result.avatarUrl, 'https://example.com/avatar.jpg');
      expect(result.members, containsAll(['user1', 'user2']));
      expect(result.isGroup, false);
      expect(result.lastMessage, 'Đoạn chat mới được tạo');
      verify(mockRepository.createChatThread(any)).called(1);
    });

    test('should create chat thread with initial message', () async {
      // arrange
      when(mockRepository.createChatThread(any)).thenAnswer((_) async {});

      // act
      final result = await useCase(
        currentUserId: 'user1',
        friendId: 'user2',
        friendName: 'Test Friend',
        friendAvatarUrl: 'https://example.com/avatar.jpg',
        initialMessage: 'Hello there!',
      );

      // assert
      expect(result, isA<ChatThread>());
      expect(result.lastMessage, 'Hello there!');
      verify(mockRepository.createChatThread(any)).called(1);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(
        mockRepository.createChatThread(any),
      ).thenThrow(Exception('Failed to create chat thread'));

      // act & assert
      expect(
        () => useCase(
          currentUserId: 'user1',
          friendId: 'user2',
          friendName: 'Test Friend',
          friendAvatarUrl: 'https://example.com/avatar.jpg',
        ),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.createChatThread(any)).called(1);
    });

    test('should generate thread ID with correct format', () async {
      // arrange
      when(mockRepository.createChatThread(any)).thenAnswer((_) async {});

      // act
      final result = await useCase(
        currentUserId: 'user1',
        friendId: 'user2',
        friendName: 'Test Friend',
        friendAvatarUrl: 'https://example.com/avatar.jpg',
      );

      // assert
      expect(result.id, startsWith('chat_user2_'));
      expect(result.id, matches(r'^chat_user2_\d+$'));
    });

    test('should set correct properties for individual chat', () async {
      // arrange
      when(mockRepository.createChatThread(any)).thenAnswer((_) async {});

      // act
      final result = await useCase(
        currentUserId: 'user1',
        friendId: 'user2',
        friendName: 'Test Friend',
        friendAvatarUrl: 'https://example.com/avatar.jpg',
      );

      // assert
      expect(result.isGroup, false);
      expect(result.groupAdminId, isNull);
      expect(result.groupDescription, isNull);
      expect(result.members, hasLength(2));
      expect(result.unreadCounts, isEmpty);
    });
  });
}
