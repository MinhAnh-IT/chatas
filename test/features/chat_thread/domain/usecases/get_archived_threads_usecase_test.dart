import 'package:flutter_test/flutter_test.dart';

import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/domain/usecases/get_archived_threads_usecase.dart';

class FakeChatThreadRepository implements ChatThreadRepository {
  bool getArchivedChatThreadsCalled = false;
  String? lastCurrentUserId;
  List<ChatThread> returnValue = [];
  Exception? shouldThrow;

  @override
  Future<List<ChatThread>> getArchivedChatThreads(String currentUserId) async {
    if (shouldThrow != null) throw shouldThrow!;
    getArchivedChatThreadsCalled = true;
    lastCurrentUserId = currentUserId;
    return returnValue;
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
  Future<void> archiveThreadForUser(String threadId, String userId) async {}

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
  group('GetArchivedThreadsUseCase', () {
    late GetArchivedThreadsUseCase useCase;
    late FakeChatThreadRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeChatThreadRepository();
      useCase = GetArchivedThreadsUseCase(fakeRepository);
    });

    test(
      'should call repository getArchivedChatThreads with correct parameters',
      () async {
        // arrange
        const currentUserId = 'user_123';
        final expectedThreads = [
          ChatThread(
            id: 'archived_1',
            name: 'Archived Thread 1',
            lastMessage: 'Last message 1',
            lastMessageTime: DateTime(2024, 1, 1, 12, 0),
            avatarUrl: '',
            members: ['user_123', 'user_456'],
            isGroup: false,
            unreadCounts: {},
            createdAt: DateTime(2024, 1, 1, 10, 0),
            updatedAt: DateTime(2024, 1, 1, 12, 0),
            hiddenFor: ['user_123'],
          ),
          ChatThread(
            id: 'archived_2',
            name: 'Archived Thread 2',
            lastMessage: 'Last message 2',
            lastMessageTime: DateTime(2024, 1, 1, 11, 0),
            avatarUrl: '',
            members: ['user_123', 'user_789'],
            isGroup: true,
            unreadCounts: {},
            createdAt: DateTime(2024, 1, 1, 9, 0),
            updatedAt: DateTime(2024, 1, 1, 11, 0),
            hiddenFor: ['user_123'],
          ),
        ];
        fakeRepository.returnValue = expectedThreads;

        // act
        final result = await useCase.call(currentUserId);

        // assert
        expect(fakeRepository.getArchivedChatThreadsCalled, isTrue);
        expect(fakeRepository.lastCurrentUserId, equals(currentUserId));
        expect(result, equals(expectedThreads));
      },
    );

    test('should throw exception when currentUserId is empty', () async {
      // arrange
      const currentUserId = '';

      // act & assert
      expect(
        () async => await useCase.call(currentUserId),
        throwsA(isA<ArgumentError>()),
      );

      expect(fakeRepository.getArchivedChatThreadsCalled, isFalse);
    });

    test('should propagate repository exceptions', () async {
      // arrange
      const currentUserId = 'user_123';
      final exception = Exception('Repository error');
      fakeRepository.shouldThrow = exception;

      // act & assert
      expect(
        () async => await useCase.call(currentUserId),
        throwsA(equals(exception)),
      );
    });

    test('should return empty list when no archived threads', () async {
      // arrange
      const currentUserId = 'user_123';
      fakeRepository.returnValue = [];

      // act
      final result = await useCase.call(currentUserId);

      // assert
      expect(result, isEmpty);
      expect(fakeRepository.getArchivedChatThreadsCalled, isTrue);
      expect(fakeRepository.lastCurrentUserId, equals(currentUserId));
    });
  });
}
