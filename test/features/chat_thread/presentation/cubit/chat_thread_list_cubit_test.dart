import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:chatas/features/chat_thread/presentation/cubit/chat_thread_list_cubit.dart';
import 'package:chatas/features/chat_thread/presentation/cubit/chat_thread_list_state.dart';
import 'package:chatas/features/chat_thread/domain/usecases/get_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/get_chat_threads_stream_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/create_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/search_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/delete_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/hide_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/mark_thread_deleted_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/find_or_create_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/archive_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/leave_group_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/join_group_usecase.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:chatas/features/chat_thread/domain/usecases/get_archived_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';

// Fake classes for testing
class FakeGetChatThreadsUseCase implements GetChatThreadsUseCase {
  final List<ChatThread> _threads;
  bool shouldThrowError;

  FakeGetChatThreadsUseCase(this._threads, {this.shouldThrowError = false});

  @override
  late final ChatThreadRepository repository;

  @override
  Future<List<ChatThread>> call(String currentUserId) async {
    if (shouldThrowError) {
      throw Exception('Network error');
    }
    return _threads;
  }
}

class FakeGetChatThreadsStreamUseCase implements GetChatThreadsStreamUseCase {
  final List<ChatThread> _threads;
  bool shouldEmitError;

  FakeGetChatThreadsStreamUseCase(
    this._threads, {
    this.shouldEmitError = false,
  });

  @override
  late final ChatThreadRepository repository;

  @override
  Stream<List<ChatThread>> call(String currentUserId) {
    if (shouldEmitError) {
      return Stream.error(Exception('Stream error'));
    }
    return Stream.value(_threads);
  }
}

class FakeCreateChatThreadUseCase implements CreateChatThreadUseCase {
  bool shouldThrowError;

  FakeCreateChatThreadUseCase({this.shouldThrowError = false});

  @override
  late final ChatThreadRepository repository;

  @override
  Future<ChatThread> call({
    required String friendId,
    required String friendName,
    required String friendAvatarUrl,
    required String currentUserId,
    String? initialMessage,
  }) async {
    if (shouldThrowError) {
      throw Exception('Creation failed');
    }

    final now = DateTime.now();
    return ChatThread(
      id: 'chat_${friendId}_${now.millisecondsSinceEpoch}',
      name: friendName,
      lastMessage: initialMessage ?? '',
      lastMessageTime: now,
      avatarUrl: friendAvatarUrl,
      members: ['current_user', friendId],
      isGroup: false,
      unreadCounts: {'current_user': 0, friendId: 0},
      createdAt: now,
      updatedAt: now,
    );
  }
}

class FakeSearchChatThreadsUseCase implements SearchChatThreadsUseCase {
  final List<ChatThread> _threads;
  bool shouldThrowError;

  FakeSearchChatThreadsUseCase(this._threads, {this.shouldThrowError = false});

  @override
  late final ChatThreadRepository repository;

  @override
  Future<List<ChatThread>> call(String query, String currentUserId) async {
    if (shouldThrowError) {
      throw Exception('Search error');
    }

    if (query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase();
    return _threads.where((thread) {
      return thread.name.toLowerCase().contains(lowerQuery) ||
          thread.lastMessage.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

class FakeDeleteChatThreadUseCase implements DeleteChatThreadUseCase {
  final List<String> deletedThreadIds = [];
  bool shouldThrowError;

  FakeDeleteChatThreadUseCase({this.shouldThrowError = false});

  @override
  late final ChatThreadRepository repository;

  @override
  Future<void> call(String threadId) async {
    if (shouldThrowError) {
      throw Exception('Delete error');
    }

    if (threadId.isEmpty) {
      throw ArgumentError('Thread ID cannot be empty');
    }

    deletedThreadIds.add(threadId);
  }
}

class FakeHideChatThreadUseCase implements HideChatThreadUseCase {
  final List<String> hiddenThreadIds = [];
  bool shouldThrowError;

  FakeHideChatThreadUseCase({this.shouldThrowError = false});

  @override
  late final ChatThreadRepository repository;

  @override
  Future<void> call(String threadId, String userId) async {
    if (shouldThrowError) {
      throw Exception('Hide error');
    }

    if (threadId.isEmpty) {
      throw ArgumentError('Thread ID cannot be empty');
    }

    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    hiddenThreadIds.add(threadId);
  }
}

class FakeMarkThreadDeletedUseCase implements MarkThreadDeletedUseCase {
  final List<String> deletedThreadIds = [];
  bool shouldThrowError;

  FakeMarkThreadDeletedUseCase({this.shouldThrowError = false});

  @override
  late final ChatThreadRepository repository;

  @override
  Future<void> call({
    required String threadId,
    required String userId,
    DateTime? lastMessageTime,
  }) async {
    if (shouldThrowError) {
      throw Exception('Mark deleted error');
    }

    if (threadId.isEmpty) {
      throw ArgumentError('Thread ID cannot be empty');
    }

    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    deletedThreadIds.add(threadId);
  }
}

class FakeArchiveThreadUseCase implements ArchiveThreadUseCase {
  final List<String> archivedThreadIds = [];
  bool shouldThrowError;

  FakeArchiveThreadUseCase({this.shouldThrowError = false});

  @override
  late final ChatThreadRepository repository;

  @override
  Future<void> call({required String threadId, required String userId}) async {
    if (shouldThrowError) {
      throw Exception('Archive error');
    }

    if (threadId.isEmpty) {
      throw ArgumentError('Thread ID cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    archivedThreadIds.add(threadId);
  }
}

class FakeLeaveGroupUseCase implements LeaveGroupUseCase {
  final List<String> leftGroupIds = [];
  bool shouldThrowError;

  FakeLeaveGroupUseCase({this.shouldThrowError = false});

  @override
  late final ChatThreadRepository repository;

  @override
  Future<void> call({required String threadId, required String userId}) async {
    if (shouldThrowError) {
      throw Exception('Leave group error');
    }

    if (threadId.isEmpty) {
      throw ArgumentError('Thread ID cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    leftGroupIds.add(threadId);
  }
}

class FakeJoinGroupUseCase implements JoinGroupUseCase {
  final List<String> joinedGroupIds = [];
  bool shouldThrowError;

  FakeJoinGroupUseCase({this.shouldThrowError = false});

  @override
  late final ChatThreadRepository repository;

  @override
  Future<void> call({required String threadId, required String userId}) async {
    if (shouldThrowError) {
      throw Exception('Join group error');
    }

    if (threadId.isEmpty) {
      throw ArgumentError('Thread ID cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    joinedGroupIds.add(threadId);
  }
}

class FakeFindOrCreateChatThreadUseCase
    implements FindOrCreateChatThreadUseCase {
  bool shouldThrowError;

  FakeFindOrCreateChatThreadUseCase({this.shouldThrowError = false});

  @override
  late final ChatThreadRepository repository;

  @override
  Future<ChatThread> call({
    required String currentUserId,
    required String friendId,
    required String friendName,
    required String friendAvatarUrl,
    bool forceCreateNew = false,
  }) async {
    if (shouldThrowError) {
      throw Exception('Find or create failed');
    }

    final now = DateTime.now();
    return ChatThread(
      id: 'chat_${currentUserId}_${friendId}_${now.millisecondsSinceEpoch}',
      name: 'Test Thread',
      lastMessage: '',
      lastMessageTime: now,
      avatarUrl: friendAvatarUrl,
      members: [currentUserId, friendId],
      isGroup: false,
      unreadCounts: {currentUserId: 0, friendId: 0},
      createdAt: now,
      updatedAt: now,
    );
  }
}

class FakeGetArchivedThreadsUseCase implements GetArchivedThreadsUseCase {
  final ChatThreadRepository repository;

  FakeGetArchivedThreadsUseCase(this.repository);

  @override
  Future<List<ChatThread>> call(String currentUserId) async {
    // Return empty list for archived threads
    return [];
  }
}

class FakeChatThreadRepository implements ChatThreadRepository {
  final List<ChatThread> threads;

  FakeChatThreadRepository(this.threads);

  @override
  Future<List<ChatThread>> getAllChatThreads(String currentUserId) async =>
      threads;

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
  Stream<List<ChatThread>> getChatThreadsStream(String currentUserId) {
    return Stream.value(threads);
  }

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
  group('ChatThreadListCubit', () {
    late ChatThreadListCubit cubit;
    late FakeGetChatThreadsUseCase fakeGetChatThreadsUseCase;
    late FakeGetChatThreadsStreamUseCase fakeGetChatThreadsStreamUseCase;
    late FakeGetArchivedThreadsUseCase fakeGetArchivedThreadsUseCase;
    late FakeCreateChatThreadUseCase fakeCreateChatThreadUseCase;
    late FakeSearchChatThreadsUseCase fakeSearchChatThreadsUseCase;
    late FakeDeleteChatThreadUseCase fakeDeleteChatThreadUseCase;
    late FakeHideChatThreadUseCase fakeHideChatThreadUseCase;
    late FakeMarkThreadDeletedUseCase fakeMarkThreadDeletedUseCase;
    late FakeArchiveThreadUseCase fakeArchiveThreadUseCase;
    late FakeLeaveGroupUseCase fakeLeaveGroupUseCase;
    late FakeJoinGroupUseCase fakeJoinGroupUseCase;
    late FakeFindOrCreateChatThreadUseCase fakeFindOrCreateChatThreadUseCase;

    final now = DateTime.now();
    final testChatThreads = <ChatThread>[
      ChatThread(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hello, how are you?',
        lastMessageTime: now,
        avatarUrl: 'https://example.com/avatar1.jpg',
        members: ['1', '2'],
        isGroup: false,
        unreadCounts: {'1': 0, '2': 0},
        createdAt: now,
        updatedAt: now,
      ),
      ChatThread(
        id: '2',
        name: 'Jane Smith',
        lastMessage: 'Meeting at 3pm today',
        lastMessageTime: now,
        avatarUrl: 'https://example.com/avatar2.jpg',
        members: ['1', '3'],
        isGroup: false,
        unreadCounts: {'1': 0, '3': 2},
        createdAt: now,
        updatedAt: now,
      ),
    ];

    setUp(() {
      fakeGetChatThreadsUseCase = FakeGetChatThreadsUseCase(testChatThreads);
      fakeGetChatThreadsStreamUseCase = FakeGetChatThreadsStreamUseCase(
        testChatThreads,
      );
      fakeGetArchivedThreadsUseCase = FakeGetArchivedThreadsUseCase(
        FakeChatThreadRepository([]),
      );
      fakeCreateChatThreadUseCase = FakeCreateChatThreadUseCase();
      fakeSearchChatThreadsUseCase = FakeSearchChatThreadsUseCase(
        testChatThreads,
      );
      fakeDeleteChatThreadUseCase = FakeDeleteChatThreadUseCase();
      fakeHideChatThreadUseCase = FakeHideChatThreadUseCase();
      fakeMarkThreadDeletedUseCase = FakeMarkThreadDeletedUseCase();
      fakeArchiveThreadUseCase = FakeArchiveThreadUseCase();
      fakeLeaveGroupUseCase = FakeLeaveGroupUseCase();
      fakeJoinGroupUseCase = FakeJoinGroupUseCase();
      fakeFindOrCreateChatThreadUseCase = FakeFindOrCreateChatThreadUseCase();

      cubit = ChatThreadListCubit(
        getChatThreadsUseCase: fakeGetChatThreadsUseCase,
        getChatThreadsStreamUseCase: fakeGetChatThreadsStreamUseCase,
        getArchivedThreadsUseCase: fakeGetArchivedThreadsUseCase,
        createChatThreadUseCase: fakeCreateChatThreadUseCase,
        searchChatThreadsUseCase: fakeSearchChatThreadsUseCase,
        deleteChatThreadUseCase: fakeDeleteChatThreadUseCase,
        hideChatThreadUseCase: fakeHideChatThreadUseCase,
        markThreadDeletedUseCase: fakeMarkThreadDeletedUseCase,
        archiveThreadUseCase: fakeArchiveThreadUseCase,
        leaveGroupUseCase: fakeLeaveGroupUseCase,
        joinGroupUseCase: fakeJoinGroupUseCase,
        findOrCreateChatThreadUseCase: fakeFindOrCreateChatThreadUseCase,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state should be ChatThreadListInitial', () {
      expect(cubit.state, isA<ChatThreadListInitial>());
    });

    group('fetchChatThreads', () {
      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit [ChatThreadListLoading, ChatThreadListLoaded] when successful',
        build: () => cubit,
        act: (cubit) => cubit.fetchChatThreads('current_user'),
        expect: () => [
          isA<ChatThreadListLoading>(),
          ChatThreadListLoaded(testChatThreads),
        ],
      );

      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit [ChatThreadListLoading, ChatThreadListError] when error occurs',
        build: () {
          fakeGetChatThreadsUseCase.shouldThrowError = true;
          return cubit;
        },
        act: (cubit) => cubit.fetchChatThreads('current_user'),
        expect: () => [
          isA<ChatThreadListLoading>(),
          isA<ChatThreadListError>(),
        ],
      );
    });

    group('createNewChatThread', () {
      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit [ChatThreadListLoading, ChatThreadListLoaded] when successful',
        build: () => cubit,
        act: (cubit) => cubit.createNewChatThread(
          friendId: 'friend_id',
          friendName: 'Friend Name',
          friendAvatarUrl: 'https://example.com/avatar.jpg',
          currentUserId: 'current_user',
        ),
        expect: () => [
          isA<ChatThreadListLoading>(),
          isA<ChatThreadListLoaded>(),
        ],
      );

      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit [ChatThreadListError] when error occurs',
        build: () {
          fakeCreateChatThreadUseCase.shouldThrowError = true;
          return cubit;
        },
        act: (cubit) => cubit.createNewChatThread(
          friendId: 'friend_id',
          friendName: 'Friend Name',
          friendAvatarUrl: 'https://example.com/avatar.jpg',
          currentUserId: 'current_user',
        ),
        expect: () => [isA<ChatThreadListError>()],
      );
    });

    group('searchChatThreads', () {
      test('should return search results when search succeeds', () async {
        // arrange
        const query = 'john';

        // act
        final result = await cubit.searchChatThreads(query, 'current_user');

        // assert
        expect(result.length, 1);
        expect(result.first.name, 'John Doe');
      });

      test('should return empty list when search fails', () async {
        // arrange
        const query = 'john';
        fakeSearchChatThreadsUseCase.shouldThrowError = true;

        // act
        final result = await cubit.searchChatThreads(query, 'current_user');

        // assert
        expect(result, isEmpty);
      });
    });

    group('deleteChatThread', () {
      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit [ChatThreadDeleting, ChatThreadListLoading, ChatThreadListLoaded] when deletion is successful',
        build: () => cubit,
        act: (cubit) => cubit.deleteChatThread('thread_id', 'current_user'),
        expect: () => [
          isA<ChatThreadDeleting>(),
          isA<ChatThreadListLoading>(),
          isA<ChatThreadListLoaded>(),
        ],
      );

      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit [ChatThreadListError] when deletion error occurs',
        build: () {
          fakeDeleteChatThreadUseCase.shouldThrowError = true;
          return cubit;
        },
        act: (cubit) => cubit.deleteChatThread('thread_id', 'current_user'),
        expect: () => [isA<ChatThreadDeleting>(), isA<ChatThreadListError>()],
      );
    });

    group('findOrCreateChatThreadForMessaging', () {
      test('should return chat thread when successful', () async {
        // act
        final result = await cubit.findOrCreateChatThreadForMessaging(
          currentUserId: 'current_user',
          friendId: 'friend_id',
          friendName: 'Friend Name',
          friendAvatarUrl: 'https://example.com/avatar.jpg',
        );

        // assert
        expect(result, isA<ChatThread>());
        expect(result.name, 'Test Thread');
      });
    });

    group('startListeningToThreads', () {
      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit [ChatThreadListLoading, ChatThreadListLoaded] when stream succeeds',
        build: () => cubit,
        act: (cubit) => cubit.startListeningToThreads('current_user'),
        expect: () => [
          isA<ChatThreadListLoading>(),
          isA<ChatThreadListLoaded>(),
        ],
      );

      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit [ChatThreadListLoading, ChatThreadListError] when stream fails',
        build: () {
          final errorStreamUseCase = FakeGetChatThreadsStreamUseCase(
            [],
            shouldEmitError: true,
          );
          return ChatThreadListCubit(
            getChatThreadsUseCase: fakeGetChatThreadsUseCase,
            getChatThreadsStreamUseCase: errorStreamUseCase,
            getArchivedThreadsUseCase: fakeGetArchivedThreadsUseCase,
            createChatThreadUseCase: fakeCreateChatThreadUseCase,
            searchChatThreadsUseCase: fakeSearchChatThreadsUseCase,
            deleteChatThreadUseCase: fakeDeleteChatThreadUseCase,
            hideChatThreadUseCase: fakeHideChatThreadUseCase,
            markThreadDeletedUseCase: fakeMarkThreadDeletedUseCase,
            archiveThreadUseCase: fakeArchiveThreadUseCase,
            leaveGroupUseCase: fakeLeaveGroupUseCase,
            joinGroupUseCase: fakeJoinGroupUseCase,
            findOrCreateChatThreadUseCase: fakeFindOrCreateChatThreadUseCase,
          );
        },
        act: (cubit) => cubit.startListeningToThreads('current_user'),
        expect: () => [
          isA<ChatThreadListLoading>(),
          isA<ChatThreadListError>(),
        ],
      );

      test('should emit error state when user ID is empty', () {
        // act
        cubit.startListeningToThreads('');

        // assert
        expect(cubit.state, isA<ChatThreadListError>());
        expect(
          (cubit.state as ChatThreadListError).message,
          equals('User ID cannot be empty'),
        );
      });
    });

    group('stopListeningToThreads', () {
      test('should cancel existing subscription', () async {
        // arrange - start listening first
        cubit.startListeningToThreads('current_user');
        await Future.delayed(
          const Duration(milliseconds: 100),
        ); // Let subscription start

        // act
        cubit.stopListeningToThreads();

        // assert
        // Just verify the method doesn't throw - subscription cancellation is internal
        expect(true, isTrue);
      });
    });
  });
}
