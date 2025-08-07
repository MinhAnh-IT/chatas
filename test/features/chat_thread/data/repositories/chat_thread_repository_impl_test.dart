import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chatas/features/chat_thread/data/repositories/chat_thread_repository_impl.dart';
import 'package:chatas/features/chat_thread/data/datasources/chat_thread_remote_data_source.dart';
import 'package:chatas/features/chat_thread/data/models/chat_thread_model.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

@GenerateMocks([ChatThreadRemoteDataSource])
import 'chat_thread_repository_impl_test.mocks.dart';

void main() {
  late ChatThreadRepositoryImpl repository;
  late MockChatThreadRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockChatThreadRemoteDataSource();
    repository = ChatThreadRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  group('ChatThreadRepositoryImpl', () {
    final tDateTime = DateTime(2024, 1, 1, 10, 30);
    final tCreatedAt = DateTime(2024, 1, 1, 9, 0);

    final tChatThreadModel = ChatThreadModel(
      id: '1',
      name: 'John Doe',
      lastMessage: 'Hello there!',
      lastMessageTime: tDateTime,
      avatarUrl: 'https://example.com/avatar.png',
      members: const ['user1', 'user2'],
      isGroup: false,
      unreadCount: 5,
      createdAt: tCreatedAt,
      updatedAt: tDateTime,
    );

    final tChatThreadEntity = ChatThread(
      id: '1',
      name: 'John Doe',
      lastMessage: 'Hello there!',
      lastMessageTime: tDateTime,
      avatarUrl: 'https://example.com/avatar.png',
      members: const ['user1', 'user2'],
      isGroup: false,
      unreadCount: 5,
      createdAt: tCreatedAt,
      updatedAt: tDateTime,
    );

    final tChatThreadModelList = [tChatThreadModel];
    final tChatThreadEntityList = [tChatThreadEntity];

    group('getChatThreads', () {
      test(
        'should return list of ChatThread entities when remote data source call is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.fetchChatThreads(),
          ).thenAnswer((_) async => tChatThreadModelList);

          // Act
          final result = await repository.getChatThreads();

          // Assert
          verify(mockRemoteDataSource.fetchChatThreads());
          expect(result, equals(tChatThreadEntityList));
        },
      );

      test(
        'should return empty list when remote data source returns empty list',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.fetchChatThreads(),
          ).thenAnswer((_) async => []);

          // Act
          final result = await repository.getChatThreads();

          // Assert
          verify(mockRemoteDataSource.fetchChatThreads());
          expect(result, equals([]));
        },
      );

      test('should convert multiple models to entities correctly', () async {
        // Arrange
        final secondModel = ChatThreadModel(
          id: '2',
          name: 'Jane Smith',
          lastMessage: 'How are you?',
          lastMessageTime: tDateTime,
          avatarUrl: 'https://example.com/jane.png',
          members: const ['user1', 'jane_id'],
          isGroup: false,
          unreadCount: 3,
          createdAt: tCreatedAt,
          updatedAt: tDateTime,
        );

        final multipleModels = [tChatThreadModel, secondModel];
        when(
          mockRemoteDataSource.fetchChatThreads(),
        ).thenAnswer((_) async => multipleModels);

        // Act
        final result = await repository.getChatThreads();

        // Assert
        verify(mockRemoteDataSource.fetchChatThreads());
        expect(result.length, 2);
        expect(result[0].id, '1');
        expect(result[1].id, '2');
      });

      test('should propagate exceptions from remote data source', () async {
        // Arrange
        when(
          mockRemoteDataSource.fetchChatThreads(),
        ).thenThrow(Exception('Server error'));

        // Act & Assert
        expect(() => repository.getChatThreads(), throwsException);
      });
    });

    group('addChatThread', () {
      test('should call remote data source with correct model', () async {
        // Arrange
        when(
          mockRemoteDataSource.addChatThread(any),
        ).thenAnswer((_) async => {});

        // Act
        await repository.addChatThread(tChatThreadEntity);

        // Assert
        final captured = verify(
          mockRemoteDataSource.addChatThread(captureAny),
        ).captured;
        final capturedModel = captured.first as ChatThreadModel;
        expect(capturedModel.id, tChatThreadEntity.id);
        expect(capturedModel.name, tChatThreadEntity.name);
        expect(capturedModel.lastMessage, tChatThreadEntity.lastMessage);
        expect(capturedModel.isGroup, tChatThreadEntity.isGroup);
      });

      test('should handle group chat creation correctly', () async {
        // Arrange
        final groupEntity = ChatThread(
          id: 'group_1',
          name: 'Team Chat',
          lastMessage: 'Welcome to the team!',
          lastMessageTime: tDateTime,
          avatarUrl: 'https://example.com/group_avatar.png',
          members: const ['user1', 'user2', 'user3', 'user4'],
          isGroup: true,
          unreadCount: 0,
          createdAt: tCreatedAt,
          updatedAt: tDateTime,
        );

        when(
          mockRemoteDataSource.addChatThread(any),
        ).thenAnswer((_) async => {});

        // Act
        await repository.addChatThread(groupEntity);

        // Assert
        final captured = verify(
          mockRemoteDataSource.addChatThread(captureAny),
        ).captured;
        final capturedModel = captured.first as ChatThreadModel;
        expect(capturedModel.isGroup, true);
        expect(capturedModel.members.length, 4);
        expect(capturedModel.name, 'Team Chat');
      });

      test('should propagate exceptions from remote data source', () async {
        // Arrange
        when(
          mockRemoteDataSource.addChatThread(any),
        ).thenThrow(Exception('Creation failed'));

        // Act & Assert
        expect(
          () => repository.addChatThread(tChatThreadEntity),
          throwsException,
        );
      });
    });

    group('entity to model conversion', () {
      test('should convert entity to model preserving all fields', () async {
        // Arrange
        when(
          mockRemoteDataSource.addChatThread(any),
        ).thenAnswer((_) async => {});

        // Act
        await repository.addChatThread(tChatThreadEntity);

        // Assert
        final captured = verify(
          mockRemoteDataSource.addChatThread(captureAny),
        ).captured;
        final capturedModel = captured.first as ChatThreadModel;

        expect(capturedModel.id, tChatThreadEntity.id);
        expect(capturedModel.name, tChatThreadEntity.name);
        expect(capturedModel.lastMessage, tChatThreadEntity.lastMessage);
        expect(
          capturedModel.lastMessageTime,
          tChatThreadEntity.lastMessageTime,
        );
        expect(capturedModel.avatarUrl, tChatThreadEntity.avatarUrl);
        expect(capturedModel.members, tChatThreadEntity.members);
        expect(capturedModel.isGroup, tChatThreadEntity.isGroup);
        expect(capturedModel.unreadCount, tChatThreadEntity.unreadCount);
        expect(capturedModel.createdAt, tChatThreadEntity.createdAt);
        expect(capturedModel.updatedAt, tChatThreadEntity.updatedAt);
      });
    });

    group('model to entity conversion', () {
      test('should convert model to entity preserving all fields', () async {
        // Arrange
        when(
          mockRemoteDataSource.fetchChatThreads(),
        ).thenAnswer((_) async => [tChatThreadModel]);

        // Act
        final result = await repository.getChatThreads();

        // Assert
        final entity = result.first;
        expect(entity.id, tChatThreadModel.id);
        expect(entity.name, tChatThreadModel.name);
        expect(entity.lastMessage, tChatThreadModel.lastMessage);
        expect(entity.lastMessageTime, tChatThreadModel.lastMessageTime);
        expect(entity.avatarUrl, tChatThreadModel.avatarUrl);
        expect(entity.members, tChatThreadModel.members);
        expect(entity.isGroup, tChatThreadModel.isGroup);
        expect(entity.unreadCount, tChatThreadModel.unreadCount);
        expect(entity.createdAt, tChatThreadModel.createdAt);
        expect(entity.updatedAt, tChatThreadModel.updatedAt);
      });
    });
  });
}
