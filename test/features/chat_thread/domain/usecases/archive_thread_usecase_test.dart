import 'package:flutter_test/flutter_test.dart';

import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/domain/usecases/archive_thread_usecase.dart';

class FakeChatThreadRepository implements ChatThreadRepository {
  bool archiveThreadForUserCalled = false;
  String? lastThreadId;
  String? lastUserId;
  Exception? shouldThrow;

  @override
  Future<void> archiveThreadForUser(String threadId, String userId) async {
    if (shouldThrow != null) throw shouldThrow!;
    archiveThreadForUserCalled = true;
    lastThreadId = threadId;
    lastUserId = userId;
  }

  // Minimal implementations for required methods
  @override
  Future<List<ChatThread>> getAllChatThreads(String currentUserId) async => [];

  @override
  Future<void> createChatThread(ChatThread chatThread) async {}

  @override
  Future<void> updateChatThreadMembers(
    String chatThreadId,
    List<String> members,
  ) async {}

  @override
  Future<void> updateChatThreadName(String chatThreadId, String name) async {}

  @override
  Future<void> updateLastMessage(
    String chatThreadId,
    String message,
    DateTime timestamp,
  ) async {}

  @override
  Future<void> incrementUnreadCount(String chatThreadId, String userId) async {}

  @override
  Future<void> resetUnreadCount(String chatThreadId, String userId) async {}

  @override
  Future<ChatThread?> getChatThreadById(String chatThreadId) async => null;

  @override
  Future<void> markThreadDeletedForUser(
    String threadId,
    String userId,
    DateTime cutoffTime,
  ) async {}

  @override
  Future<void> reviveThreadForUser(String threadId, String userId) async {}

  @override
  Future<void> leaveGroup(String threadId, String userId) async {}

  @override
  Future<void> joinGroup(String threadId, String userId) async {}

  @override
  Future<ChatThread> findOrCreate1v1Thread(
    String currentUserId,
    String friendId, {
    String? avatarUrl,
    String? threadName,
  }) async {
    return ChatThread(
      id: 'temp_${currentUserId}_$friendId',
      name: threadName ?? 'Test Thread',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      avatarUrl: avatarUrl ?? '',
      members: [currentUserId, friendId],
      isGroup: false,
      unreadCounts: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateChatThreadDescription(
    String threadId,
    String description,
  ) async {}

  @override
  Future<void> updateVisibilityCutoff(
    String threadId,
    String userId,
    DateTime cutoffTime,
  ) async {}

  @override
  Future<List<ChatThread>> getArchivedChatThreads(String currentUserId) async =>
      [];

  @override
  Future<void> deleteChatThread(String chatThreadId) async {}

  @override
  Future<List<ChatThread>> getChatThreads(String currentUserId) async => [];

  @override
  Future<void> hideChatThread(String chatThreadId, String userId) async {}

  @override
  Future<void> resetThreadForUser(String chatThreadId, String userId) async {}

  @override
  Future<List<ChatThread>> searchChatThreads(
    String currentUserId,
    String query,
  ) async => [];

  @override
  Future<void> unhideChatThread(String chatThreadId, String userId) async {}

  @override
  Future<void> updateChatThreadAvatar(
    String chatThreadId,
    String avatarUrl,
  ) async {}

  @override
  Future<void> updateLastRecreatedAt(
    String chatThreadId,
    DateTime timestamp,
  ) async {}
}

void main() {
  group('ArchiveThreadUseCase', () {
    late ArchiveThreadUseCase useCase;
    late FakeChatThreadRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeChatThreadRepository();
      useCase = ArchiveThreadUseCase(fakeRepository);
    });

    test(
      'should call repository archiveThreadForUser with correct parameters',
      () async {
        // arrange
        const threadId = 'thread_123';
        const userId = 'user_123';

        // act
        await useCase.call(threadId: threadId, userId: userId);

        // assert
        expect(fakeRepository.archiveThreadForUserCalled, isTrue);
        expect(fakeRepository.lastThreadId, equals(threadId));
        expect(fakeRepository.lastUserId, equals(userId));
      },
    );

    test('should throw exception when threadId is empty', () async {
      // arrange
      const threadId = '';
      const userId = 'user_123';

      // act & assert
      expect(
        () async => await useCase.call(threadId: threadId, userId: userId),
        throwsA(isA<ArgumentError>()),
      );

      expect(fakeRepository.archiveThreadForUserCalled, isFalse);
    });

    test('should throw exception when userId is empty', () async {
      // arrange
      const threadId = 'thread_123';
      const userId = '';

      // act & assert
      expect(
        () async => await useCase.call(threadId: threadId, userId: userId),
        throwsA(isA<ArgumentError>()),
      );

      expect(fakeRepository.archiveThreadForUserCalled, isFalse);
    });

    test('should propagate repository exceptions', () async {
      // arrange
      const threadId = 'thread_123';
      const userId = 'user_123';
      final exception = Exception('Repository error');
      fakeRepository.shouldThrow = exception;

      // act & assert
      expect(
        () async => await useCase.call(threadId: threadId, userId: userId),
        throwsA(equals(exception)),
      );
    });
  });
}
