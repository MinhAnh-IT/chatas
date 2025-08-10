import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/usecases/get_chat_threads_stream_usecase.dart';

class FakeChatThreadRepository implements ChatThreadRepository {
  final List<ChatThread> threads;
  Exception? shouldThrow;

  FakeChatThreadRepository(this.threads, {this.shouldThrow});

  @override
  Stream<List<ChatThread>> getChatThreadsStream(String currentUserId) {
    if (shouldThrow != null) {
      return Stream.error(shouldThrow!);
    }
    // Filter threads by current user membership
    final userThreads = threads
        .where((thread) => thread.members.contains(currentUserId))
        .toList();
    return Stream.value(userThreads);
  }

  // Minimal implementations for required methods
  @override
  Future<List<ChatThread>> getChatThreads(String currentUserId) async => [];

  @override
  Future<List<ChatThread>> getAllChatThreads(String currentUserId) async => [];

  @override
  Future<List<ChatThread>> getArchivedChatThreads(String currentUserId) async =>
      [];

  @override
  Future<void> createChatThread(ChatThread chatThread) async {}

  @override
  Future<ChatThread?> getChatThreadById(String threadId) async => null;

  @override
  Future<void> updateChatThreadMembers(
    String threadId,
    List<String> members,
  ) async {}

  @override
  Future<void> updateChatThreadName(String threadId, String name) async {}

  @override
  Future<void> updateChatThreadAvatar(
    String threadId,
    String avatarUrl,
  ) async {}

  @override
  Future<void> updateChatThreadDescription(
    String threadId,
    String description,
  ) async {}

  @override
  Future<void> updateLastMessage(
    String threadId,
    String message,
    DateTime timestamp,
  ) async {}

  @override
  Future<void> incrementUnreadCount(String threadId, String userId) async {}

  @override
  Future<void> resetUnreadCount(String threadId, String userId) async {}

  @override
  Future<void> deleteChatThread(String threadId) async {}

  @override
  Future<void> hideChatThread(String threadId, String userId) async {}

  @override
  Future<void> unhideChatThread(String threadId, String userId) async {}

  @override
  Future<void> updateLastRecreatedAt(
    String threadId,
    DateTime timestamp,
  ) async {}

  @override
  Future<void> resetThreadForUser(String threadId, String userId) async {}

  @override
  Future<void> markThreadDeletedForUser(
    String threadId,
    String userId,
    DateTime cutoff,
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
    String user1,
    String user2, {
    String? threadName,
    String? avatarUrl,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateVisibilityCutoff(
    String threadId,
    String userId,
    DateTime cutoff,
  ) async {}

  @override
  Future<List<ChatThread>> searchChatThreads(
    String query,
    String currentUserId,
  ) async => [];
}

void main() {
  group('GetChatThreadsStreamUseCase', () {
    late GetChatThreadsStreamUseCase useCase;
    late FakeChatThreadRepository repository;

    final testThreads = [
      ChatThread(
        id: 'thread1',
        name: 'Thread 1',
        lastMessage: 'Hello',
        lastMessageTime: DateTime.now(),
        avatarUrl: '',
        members: ['user1', 'user2'],
        isGroup: false,
        unreadCounts: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ChatThread(
        id: 'thread2',
        name: 'Thread 2',
        lastMessage: 'Hi there',
        lastMessageTime: DateTime.now(),
        avatarUrl: '',
        members: ['user2', 'user3'],
        isGroup: false,
        unreadCounts: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ChatThread(
        id: 'thread3',
        name: 'Group Thread',
        lastMessage: 'Group message',
        lastMessageTime: DateTime.now(),
        avatarUrl: '',
        members: ['user1', 'user2', 'user3'],
        isGroup: true,
        unreadCounts: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    setUp(() {
      repository = FakeChatThreadRepository(testThreads);
      useCase = GetChatThreadsStreamUseCase(repository);
    });

    test('should return stream of chat threads for current user', () async {
      // arrange
      const currentUserId = 'user1';

      // act
      final stream = useCase(currentUserId);
      final result = await stream.first;

      // assert
      expect(result, isA<List<ChatThread>>());
      expect(result.length, equals(2));
      expect(result[0].id, equals('thread1'));
      expect(result[1].id, equals('thread3'));

      // Verify all returned threads contain the current user
      for (final thread in result) {
        expect(thread.members.contains(currentUserId), isTrue);
      }
    });

    test('should return empty stream when user has no threads', () async {
      // arrange
      const currentUserId = 'user_not_in_any_thread';

      // act
      final stream = useCase(currentUserId);
      final result = await stream.first;

      // assert
      expect(result, isA<List<ChatThread>>());
      expect(result, isEmpty);
    });

    test('should return only threads containing the user', () async {
      // arrange
      const currentUserId = 'user2';

      // act
      final stream = useCase(currentUserId);
      final result = await stream.first;

      // assert
      expect(result, isA<List<ChatThread>>());
      expect(result.length, equals(3)); // user2 is in all threads

      // Verify all returned threads contain user2
      for (final thread in result) {
        expect(thread.members.contains(currentUserId), isTrue);
      }
    });

    test('should propagate errors from repository', () async {
      // arrange
      const currentUserId = 'user1';
      final exception = Exception('Network error');
      repository.shouldThrow = exception;

      // act
      final stream = useCase(currentUserId);

      // assert
      expect(stream, emitsError(exception));
    });

    test('should return different data when repository data changes', () async {
      // arrange
      const currentUserId = 'user1';
      final initialRepository = FakeChatThreadRepository([testThreads.first]);
      final initialUseCase = GetChatThreadsStreamUseCase(initialRepository);

      // act
      final initialStream = initialUseCase(currentUserId);
      final initialResult = await initialStream.first;

      // Simulate repository with different data
      final updatedRepository = FakeChatThreadRepository(testThreads);
      final updatedUseCase = GetChatThreadsStreamUseCase(updatedRepository);

      final updatedStream = updatedUseCase(currentUserId);
      final updatedResult = await updatedStream.first;

      // assert
      expect(initialResult.length, equals(1));
      expect(updatedResult.length, equals(2));
    });
  });
}
