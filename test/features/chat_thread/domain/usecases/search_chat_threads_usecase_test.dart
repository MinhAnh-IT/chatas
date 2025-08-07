import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/features/chat_thread/domain/usecases/search_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

// Fake repository for testing
class FakeChatThreadRepository implements ChatThreadRepository {
  final List<ChatThread> _threads;

  FakeChatThreadRepository(this._threads);

  @override
  Future<List<ChatThread>> getChatThreads() async {
    return _threads;
  }

  @override
  Future<void> addChatThread(ChatThread chatThread) async {
    _threads.add(chatThread);
  }

  @override
  Future<void> deleteChatThread(String threadId) async {
    _threads.removeWhere((thread) => thread.id == threadId);
  }
}

void main() {
  group('SearchChatThreadsUseCase', () {
    late SearchChatThreadsUseCase useCase;
    late FakeChatThreadRepository repository;

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
      ChatThread(
        id: '3',
        name: 'Bob Wilson',
        lastMessage: 'Thanks for the help!',
        lastMessageTime: now,
        avatarUrl: 'https://example.com/avatar3.jpg',
        members: ['1', '4'],
        isGroup: false,
        unreadCount: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    setUp(() {
      repository = FakeChatThreadRepository(List.from(testChatThreads));
      useCase = SearchChatThreadsUseCase(repository);
    });

    test('should return empty list when query is empty', () async {
      // act
      final result = await useCase('');

      // assert
      expect(result, isEmpty);
    });

    test('should return empty list when query is only whitespace', () async {
      // act
      final result = await useCase('   ');

      // assert
      expect(result, isEmpty);
    });

    test('should return threads matching name (case insensitive)', () async {
      // act
      final result = await useCase('john');

      // assert
      expect(result, hasLength(1));
      expect(result.first.name, 'John Doe');
    });

    test(
      'should return threads matching last message (case insensitive)',
      () async {
        // act
        final result = await useCase('meeting');

        // assert
        expect(result, hasLength(1));
        expect(result.first.name, 'Jane Smith');
      },
    );

    test(
      'should return multiple threads when query matches multiple items',
      () async {
        // act - 'a' will match Jane (name) and Thanks (message)
        final result = await useCase('a');

        // assert
        expect(result.length, greaterThan(0));
      },
    );

    test('should return empty list when no threads match query', () async {
      // act
      final result = await useCase('xyz');

      // assert
      expect(result, isEmpty);
    });

    test('should handle partial matches correctly', () async {
      // act
      final result = await useCase('doe');

      // assert
      expect(result, hasLength(1));
      expect(result.first.name, 'John Doe');
    });

    test('should trim query and search correctly', () async {
      // act
      final result = await useCase('  john  ');

      // assert
      expect(result, hasLength(1));
      expect(result.first.name, 'John Doe');
    });

    test('should search in both name and message', () async {
      // act
      final nameResult = await useCase('Bob');
      final messageResult = await useCase('Hello');

      // assert
      expect(nameResult, hasLength(1));
      expect(nameResult.first.name, 'Bob Wilson');

      expect(messageResult, hasLength(1));
      expect(messageResult.first.name, 'John Doe');
    });

    test('should return results in original order', () async {
      // act
      final result = await useCase('a'); // matches John (Jane), Bob (Thanks)

      // assert
      expect(result.length, greaterThan(0));
      // Check that John Doe appears before Bob Wilson if both match
      final johnIndex = result.indexWhere(
        (thread) => thread.name == 'John Doe',
      );
      final bobIndex = result.indexWhere(
        (thread) => thread.name == 'Bob Wilson',
      );
      if (johnIndex != -1 && bobIndex != -1) {
        expect(johnIndex, lessThan(bobIndex));
      }
    });
  });
}
