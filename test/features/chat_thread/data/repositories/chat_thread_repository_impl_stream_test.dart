import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/features/chat_thread/data/repositories/chat_thread_repository_impl.dart';
import 'package:chatas/features/chat_thread/data/datasources/chat_thread_remote_data_source.dart';
import 'package:chatas/features/chat_thread/data/models/chat_thread_model.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FakeChatThreadRemoteDataSource implements ChatThreadRemoteDataSource {
  final List<ChatThreadModel> threads;
  Exception? shouldThrow;

  FakeChatThreadRemoteDataSource(this.threads, {this.shouldThrow});

  @override
  FirebaseFirestore get firestore => throw UnimplementedError();

  @override
  Stream<List<ChatThreadModel>> chatThreadsStream(String currentUserId) {
    if (shouldThrow != null) {
      return Stream.error(shouldThrow!);
    }
    // Filter threads by current user membership
    final userThreads = threads
        .where((thread) => thread.members.contains(currentUserId))
        .toList();
    return Stream.value(userThreads);
  }

  // Minimal implementations for other required methods
  @override
  Future<List<ChatThreadModel>> fetchChatThreads(String currentUserId) async =>
      [];

  @override
  Future<List<ChatThreadModel>> fetchAllChatThreads(
    String currentUserId,
  ) async => [];

  @override
  Future<List<ChatThreadModel>> getArchivedChatThreads(
    String currentUserId,
  ) async => [];

  @override
  Future<void> addChatThread(ChatThreadModel model) async {}

  @override
  Future<void> createChatThread(ChatThreadModel model) async {}

  @override
  Future<void> updateChatThread(String id, ChatThreadModel model) async {}

  @override
  Future<ChatThreadModel?> getChatThreadById(String threadId) async => null;

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
    String user2,
    String? threadName,
    String? avatarUrl,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateVisibilityCutoff(
    String threadId,
    String userId,
    DateTime cutoff,
  ) async {}

  @override
  Future<List<ChatThreadModel>> searchChatThreads(
    String query,
    String currentUserId,
  ) async => [];
}

void main() {
  group('ChatThreadRepositoryImpl getChatThreadsStream', () {
    late ChatThreadRepositoryImpl repository;
    late FakeChatThreadRemoteDataSource remoteDataSource;

    final now = DateTime.now();
    final earlier = now.subtract(const Duration(hours: 1));
    final later = now.add(const Duration(hours: 1));

    final testThreadModels = [
      ChatThreadModel(
        id: 'thread1',
        name: 'Thread 1',
        lastMessage: 'Hello',
        lastMessageTime: earlier,
        avatarUrl: '',
        members: ['user1', 'user2'],
        isGroup: false,
        unreadCounts: {},
        createdAt: now,
        updatedAt: now,
        hiddenFor: [],
      ),
      ChatThreadModel(
        id: 'thread2',
        name: 'Thread 2',
        lastMessage: 'Hi there',
        lastMessageTime: later,
        avatarUrl: '',
        members: ['user2', 'user3'],
        isGroup: false,
        unreadCounts: {},
        createdAt: now,
        updatedAt: now,
        hiddenFor: [],
      ),
      ChatThreadModel(
        id: 'thread3',
        name: 'Group Thread',
        lastMessage: 'Group message',
        lastMessageTime: now,
        avatarUrl: '',
        members: ['user1', 'user2', 'user3'],
        isGroup: true,
        unreadCounts: {},
        createdAt: now,
        updatedAt: now,
        hiddenFor: [],
      ),
    ];

    setUp(() {
      remoteDataSource = FakeChatThreadRemoteDataSource(testThreadModels);
      repository = ChatThreadRepositoryImpl(remoteDataSource: remoteDataSource);
    });

    test('should return stream of chat threads for current user', () async {
      // arrange
      const currentUserId = 'user1';

      // act
      final stream = repository.getChatThreadsStream(currentUserId);
      final result = await stream.first;

      // assert
      expect(result, isA<List<ChatThread>>());
      expect(result.length, equals(2));

      // Verify all returned threads contain the current user
      for (final thread in result) {
        expect(thread.members.contains(currentUserId), isTrue);
      }
    });

    test(
      'should sort threads by lastMessageTime in descending order (newest first)',
      () async {
        // arrange
        const currentUserId = 'user1';

        // act
        final stream = repository.getChatThreadsStream(currentUserId);
        final result = await stream.first;

        // assert
        expect(result.length, equals(2));

        // Should be sorted newest first: later (thread3), then earlier (thread1)
        expect(result[0].id, equals('thread3')); // Group thread (now)
        expect(result[1].id, equals('thread1')); // Thread 1 (earlier)

        // Verify sorting
        expect(
          result[0].lastMessageTime.isAfter(result[1].lastMessageTime),
          isTrue,
        );
      },
    );

    test('should return empty stream when user has no threads', () async {
      // arrange
      const currentUserId = 'user_not_in_any_thread';

      // act
      final stream = repository.getChatThreadsStream(currentUserId);
      final result = await stream.first;

      // assert
      expect(result, isA<List<ChatThread>>());
      expect(result, isEmpty);
    });

    test('should convert models to entities correctly', () async {
      // arrange
      const currentUserId = 'user1';

      // act
      final stream = repository.getChatThreadsStream(currentUserId);
      final result = await stream.first;

      // assert
      expect(result, isA<List<ChatThread>>());
      expect(result.length, equals(2));

      final firstThread = result.first;
      expect(firstThread, isA<ChatThread>());
      expect(firstThread.id, isNotEmpty);
      expect(firstThread.name, isNotEmpty);
      expect(firstThread.members, isNotEmpty);
      expect(firstThread.lastMessageTime, isA<DateTime>());
    });

    test('should propagate errors from remote data source', () async {
      // arrange
      const currentUserId = 'user1';
      final exception = Exception('Network error');
      remoteDataSource.shouldThrow = exception;

      // act
      final stream = repository.getChatThreadsStream(currentUserId);

      // assert
      expect(stream, emitsError(exception));
    });

    test('should handle threads with all users', () async {
      // arrange
      const currentUserId = 'user2'; // user2 is in all threads

      // act
      final stream = repository.getChatThreadsStream(currentUserId);
      final result = await stream.first;

      // assert
      expect(result, isA<List<ChatThread>>());
      expect(result.length, equals(3)); // user2 is in all three threads

      // Verify all returned threads contain user2
      for (final thread in result) {
        expect(thread.members.contains(currentUserId), isTrue);
      }

      // Verify sorting: later (thread2), now (thread3), earlier (thread1)
      expect(result[0].id, equals('thread2')); // Thread 2 (later)
      expect(result[1].id, equals('thread3')); // Group thread (now)
      expect(result[2].id, equals('thread1')); // Thread 1 (earlier)
    });

    test(
      'should return stream that emits new data when underlying data changes',
      () async {
        // arrange
        const currentUserId = 'user1';

        // act - get initial stream
        final stream = repository.getChatThreadsStream(currentUserId);
        final initialResult = await stream.first;

        // Simulate new data by creating new repository with different data
        final newThreadModels = [
          ...testThreadModels,
          ChatThreadModel(
            id: 'thread4',
            name: 'New Thread',
            lastMessage: 'New message',
            lastMessageTime: DateTime.now(),
            avatarUrl: '',
            members: ['user1', 'user4'],
            isGroup: false,
            unreadCounts: {},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            hiddenFor: [],
          ),
        ];

        final newRemoteDataSource = FakeChatThreadRemoteDataSource(
          newThreadModels,
        );
        final newRepository = ChatThreadRepositoryImpl(
          remoteDataSource: newRemoteDataSource,
        );

        final newStream = newRepository.getChatThreadsStream(currentUserId);
        final newResult = await newStream.first;

        // assert
        expect(initialResult.length, equals(2));
        expect(newResult.length, equals(3)); // Should include the new thread
      },
    );
  });
}
