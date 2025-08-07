import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/features/chat_thread/domain/usecases/delete_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

class FakeChatThreadRepository implements ChatThreadRepository {
  final List<String> deletedThreadIds = [];
  bool shouldThrowError = false;

  @override
  Future<void> deleteChatThread(String threadId) async {
    if (shouldThrowError) {
      throw Exception('Failed to delete chat thread');
    }
    deletedThreadIds.add(threadId);
  }

  @override
  Future<List<ChatThread>> getChatThreads() {
    throw UnimplementedError();
  }

  @override
  Future<void> addChatThread(ChatThread chatThread) {
    throw UnimplementedError();
  }
}

void main() {
  group('DeleteChatThreadUseCase Tests', () {
    late DeleteChatThreadUseCase useCase;
    late FakeChatThreadRepository repository;

    setUp(() {
      repository = FakeChatThreadRepository();
      useCase = DeleteChatThreadUseCase(repository);
    });

    group('call method', () {
      test('should call repository deleteChatThread with correct thread ID', () async {
        // arrange
        const threadId = 'test_thread_id';

        // act
        await useCase(threadId);

        // assert
        expect(repository.deletedThreadIds, contains(threadId));
      });

      test('should throw ArgumentError when thread ID is empty', () async {
        // arrange
        const emptyThreadId = '';

        // act & assert
        expect(
          () => useCase(emptyThreadId),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should propagate repository exceptions', () async {
        // arrange
        repository.shouldThrowError = true;
        const threadId = 'test_thread_id';

        // act & assert
        expect(
          () => useCase(threadId),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle multiple thread deletions', () async {
        // arrange
        const threadIds = ['thread1', 'thread2', 'thread3'];

        // act
        for (final threadId in threadIds) {
          await useCase(threadId);
        }

        // assert
        expect(repository.deletedThreadIds, equals(threadIds));
      });
    });

    group('constructor', () {
      test('should create instance with repository', () {
        // arrange & act
        final useCase = DeleteChatThreadUseCase(repository);

        // assert
        expect(useCase, isNotNull);
      });
    });
  });
}
