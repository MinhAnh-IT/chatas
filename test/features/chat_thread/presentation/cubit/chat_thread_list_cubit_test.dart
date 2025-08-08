import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:chatas/features/chat_thread/presentation/cubit/chat_thread_list_cubit.dart';
import 'package:chatas/features/chat_thread/presentation/cubit/chat_thread_list_state.dart';
import 'package:chatas/features/chat_thread/domain/usecases/get_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/create_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/search_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/delete_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/find_or_create_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
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
      unreadCount: 0,
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
      unreadCount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }
}

void main() {
  group('ChatThreadListCubit', () {
    late ChatThreadListCubit cubit;
    late FakeGetChatThreadsUseCase fakeGetChatThreadsUseCase;
    late FakeCreateChatThreadUseCase fakeCreateChatThreadUseCase;
    late FakeSearchChatThreadsUseCase fakeSearchChatThreadsUseCase;
    late FakeDeleteChatThreadUseCase fakeDeleteChatThreadUseCase;
    late FakeFindOrCreateChatThreadUseCase fakeFindOrCreateChatThreadUseCase;

    final now = DateTime.now();
    final testChatThreads = [
      ChatThread(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hello, how are you?',
        lastMessageTime: now,
        avatarUrl: 'https://example.com/avatar1.jpg',
        members: ['1', '2'],
        isGroup: false,
        unreadCount: 0,
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
        unreadCount: 2,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    setUp(() {
      fakeGetChatThreadsUseCase = FakeGetChatThreadsUseCase(testChatThreads);
      fakeCreateChatThreadUseCase = FakeCreateChatThreadUseCase();
      fakeSearchChatThreadsUseCase = FakeSearchChatThreadsUseCase(
        testChatThreads,
      );
      fakeDeleteChatThreadUseCase = FakeDeleteChatThreadUseCase();
      fakeFindOrCreateChatThreadUseCase = FakeFindOrCreateChatThreadUseCase();

      cubit = ChatThreadListCubit(
        getChatThreadsUseCase: fakeGetChatThreadsUseCase,
        createChatThreadUseCase: fakeCreateChatThreadUseCase,
        searchChatThreadsUseCase: fakeSearchChatThreadsUseCase,
        deleteChatThreadUseCase: fakeDeleteChatThreadUseCase,
        findOrCreateChatThreadUseCase: fakeFindOrCreateChatThreadUseCase,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state should be ChatThreadListInitial', () {
      expect(cubit.state, equals(ChatThreadListInitial()));
    });

    group('fetchChatThreads', () {
      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit [Loading, Loaded] when fetchChatThreads succeeds',
        build: () => cubit,
        act: (cubit) => cubit.fetchChatThreads('test_user'),
        expect: () => [
          ChatThreadListLoading(),
          ChatThreadListLoaded(testChatThreads),
        ],
      );

      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit [Loading, Error] when fetchChatThreads fails',
        build: () {
          fakeGetChatThreadsUseCase.shouldThrowError = true;
          return cubit;
        },
        act: (cubit) => cubit.fetchChatThreads('test_user'),
        expect: () => [
          ChatThreadListLoading(),
          ChatThreadListError('Exception: Network error'),
        ],
      );
    });

    group('searchChatThreads', () {
      test('should return search results when search succeeds', () async {
        // arrange
        const query = 'john';

        // act
        final result = await cubit.searchChatThreads(query, 'test_user');

        // assert
        expect(result.length, 1);
        expect(result.first.name, 'John Doe');
      });

      test('should return empty list when search fails', () async {
        // arrange
        const query = 'john';
        fakeSearchChatThreadsUseCase.shouldThrowError = true;

        // act
        final result = await cubit.searchChatThreads(query, 'test_user');

        // assert
        expect(result, isEmpty);
      });

      test('should return empty list for empty query', () async {
        // arrange
        const query = '';

        // act
        final result = await cubit.searchChatThreads(query, 'test_user');

        // assert
        expect(result, isEmpty);
      });
    });

    group('createNewChatThread', () {
      const friendId = 'friend123';
      const friendName = 'Friend Name';
      const friendAvatarUrl = 'https://example.com/friend.jpg';
      const initialMessage = 'Hello!';

      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should create thread and refresh list when creation succeeds',
        build: () => cubit,
        act: (cubit) => cubit.createNewChatThread(
          friendId: friendId,
          friendName: friendName,
          friendAvatarUrl: friendAvatarUrl,
          currentUserId: 'test_user',
          initialMessage: initialMessage,
        ),
        expect: () => [
          ChatThreadListLoading(),
          ChatThreadListLoaded(testChatThreads),
        ],
      );

      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit error when thread creation fails',
        build: () {
          fakeCreateChatThreadUseCase.shouldThrowError = true;
          return cubit;
        },
        act: (cubit) => cubit.createNewChatThread(
          friendId: friendId,
          friendName: friendName,
          friendAvatarUrl: friendAvatarUrl,
          currentUserId: 'test_user',
          initialMessage: initialMessage,
        ),
        expect: () => [
          ChatThreadListError(
            'Failed to create chat: Exception: Creation failed',
          ),
        ],
      );
    });

    group('deleteChatThread', () {
      const threadId = 'test_thread_id';

      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit [Deleting, Loading, Loaded] when deletion succeeds',
        build: () => cubit,
        act: (cubit) => cubit.deleteChatThread(threadId, 'test_user'),
        expect: () => [
          const ChatThreadDeleting(threadId),
          ChatThreadListLoading(),
          ChatThreadListLoaded(testChatThreads),
        ],
      );

      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit error when thread ID is empty',
        build: () => cubit,
        act: (cubit) => cubit.deleteChatThread('', 'test_user'),
        expect: () => [const ChatThreadListError('Invalid thread ID')],
      );

      blocTest<ChatThreadListCubit, ChatThreadListState>(
        'should emit error when deletion fails',
        build: () {
          fakeDeleteChatThreadUseCase.shouldThrowError = true;
          return cubit;
        },
        act: (cubit) => cubit.deleteChatThread(threadId, 'test_user'),
        expect: () => [
          const ChatThreadDeleting(threadId),
          ChatThreadListError('Failed to delete chat: Exception: Delete error'),
        ],
      );

      test('should call delete use case with correct thread ID', () async {
        // act
        await cubit.deleteChatThread(threadId, 'test_user');

        // assert
        expect(
          fakeDeleteChatThreadUseCase.deletedThreadIds,
          contains(threadId),
        );
      });
    });
  });
}
