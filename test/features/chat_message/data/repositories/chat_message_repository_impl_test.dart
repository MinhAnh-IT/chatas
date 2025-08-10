import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chatas/features/chat_message/data/repositories/chat_message_repository_impl.dart';
import 'package:chatas/features/chat_message/data/datasources/chat_message_remote_data_source.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/data/models/chat_message_model.dart';

import 'chat_message_repository_impl_test.mocks.dart';

@GenerateMocks([ChatMessageRemoteDataSource])
void main() {
  group('ChatMessageRepositoryImpl', () {
    late ChatMessageRepositoryImpl repository;
    late MockChatMessageRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockChatMessageRemoteDataSource();
      repository = ChatMessageRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    final tDateTime = DateTime(2024, 1, 1, 12, 0);
    final tChatMessageModel = ChatMessageModel(
      id: 'msg_123',
      chatThreadId: 'thread_456',
      senderId: 'user_789',
      senderName: 'Test User',
      senderAvatarUrl: 'https://example.com/avatar.jpg',
      content: 'Hello world!',
      type: 'text',
      status: 'sent',
      sentAt: tDateTime,
      isDeleted: false,
      reactions: const {},
      replyToMessageId: null,
      createdAt: tDateTime,
      updatedAt: tDateTime,
    );

    final tChatMessage = tChatMessageModel.toEntity();

    group('getMessages', () {
      test(
        'should return list of ChatMessage when remote data source is successful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.fetchMessages('thread_456', 'user_123'),
          ).thenAnswer((_) async => [tChatMessageModel]);

          // act
          final result = await repository.getMessages('thread_456', 'user_123');

          // assert
          expect(result, [tChatMessage]);
          verify(
            mockRemoteDataSource.fetchMessages('thread_456', 'user_123'),
          ).called(1);
        },
      );

      test('should throw exception when remote data source fails', () async {
        // arrange
        when(
          mockRemoteDataSource.fetchMessages('thread_456', 'user_123'),
        ).thenThrow(Exception('Failed to fetch messages'));

        // act & assert
        expect(
          () => repository.getMessages('thread_456', 'user_123'),
          throwsA(isA<Exception>()),
        );
        verify(
          mockRemoteDataSource.fetchMessages('thread_456', 'user_123'),
        ).called(1);
      });
    });

    group('messagesStream', () {
      test(
        'should return stream of ChatMessage when remote data source is successful',
        () async {
          // arrange
          when(
            mockRemoteDataSource.messagesStream('thread_456', 'user_123'),
          ).thenAnswer((_) => Stream.value([tChatMessageModel]));

          // act
          final result = repository.messagesStream('thread_456', 'user_123');

          // assert
          expect(result, emits([tChatMessage]));
          verify(
            mockRemoteDataSource.messagesStream('thread_456', 'user_123'),
          ).called(1);
        },
      );

      test('should throw exception when remote data source fails', () async {
        // arrange
        when(
          mockRemoteDataSource.messagesStream('thread_456', 'user_123'),
        ).thenThrow(Exception('Failed to get messages stream'));

        // act & assert
        expect(
          () => repository.messagesStream('thread_456', 'user_123'),
          throwsA(isA<Exception>()),
        );
        verify(
          mockRemoteDataSource.messagesStream('thread_456', 'user_123'),
        ).called(1);
      });
    });

    group('sendMessage', () {
      test('should call remote data source successfully', () async {
        // arrange
        when(
          mockRemoteDataSource.addMessage(tChatMessageModel),
        ).thenAnswer((_) async {});

        // act
        await repository.sendMessage(tChatMessage);

        // assert
        verify(mockRemoteDataSource.addMessage(tChatMessageModel)).called(1);
      });

      test('should throw exception when remote data source fails', () async {
        // arrange
        when(
          mockRemoteDataSource.addMessage(tChatMessageModel),
        ).thenThrow(Exception('Failed to send message'));

        // act & assert
        expect(
          () => repository.sendMessage(tChatMessage),
          throwsA(isA<Exception>()),
        );
        verify(mockRemoteDataSource.addMessage(tChatMessageModel)).called(1);
      });
    });

    group('updateMessage', () {
      test('should call remote data source successfully', () async {
        // arrange
        when(
          mockRemoteDataSource.updateMessage('msg_123', tChatMessageModel),
        ).thenAnswer((_) async {});

        // act
        await repository.updateMessage(tChatMessage);

        // assert
        verify(
          mockRemoteDataSource.updateMessage('msg_123', tChatMessageModel),
        ).called(1);
      });

      test('should throw exception when remote data source fails', () async {
        // arrange
        when(
          mockRemoteDataSource.updateMessage('msg_123', tChatMessageModel),
        ).thenThrow(Exception('Failed to update message'));

        // act & assert
        expect(
          () => repository.updateMessage(tChatMessage),
          throwsA(isA<Exception>()),
        );
        verify(
          mockRemoteDataSource.updateMessage('msg_123', tChatMessageModel),
        ).called(1);
      });
    });

    group('deleteMessage', () {
      test('should call remote data source successfully', () async {
        // arrange
        when(
          mockRemoteDataSource.deleteMessage('msg_123'),
        ).thenAnswer((_) async {});

        // act
        await repository.deleteMessage('msg_123');

        // assert
        verify(mockRemoteDataSource.deleteMessage('msg_123')).called(1);
      });

      test('should throw exception when remote data source fails', () async {
        // arrange
        when(
          mockRemoteDataSource.deleteMessage('msg_123'),
        ).thenThrow(Exception('Failed to delete message'));

        // act & assert
        expect(
          () => repository.deleteMessage('msg_123'),
          throwsA(isA<Exception>()),
        );
        verify(mockRemoteDataSource.deleteMessage('msg_123')).called(1);
      });
    });

    group('addReaction', () {
      test('should call remote data source successfully', () async {
        // arrange
        when(
          mockRemoteDataSource.addReaction('msg_123', 'user_789', 'like'),
        ).thenAnswer((_) async {});

        // act
        await repository.addReaction('msg_123', 'user_789', ReactionType.like);

        // assert
        verify(
          mockRemoteDataSource.addReaction('msg_123', 'user_789', 'like'),
        ).called(1);
      });

      test('should throw exception when remote data source fails', () async {
        // arrange
        when(
          mockRemoteDataSource.addReaction('msg_123', 'user_789', 'like'),
        ).thenThrow(Exception('Failed to add reaction'));

        // act & assert
        expect(
          () =>
              repository.addReaction('msg_123', 'user_789', ReactionType.like),
          throwsA(isA<Exception>()),
        );
        verify(
          mockRemoteDataSource.addReaction('msg_123', 'user_789', 'like'),
        ).called(1);
      });
    });

    group('removeReaction', () {
      test('should call remote data source successfully', () async {
        // arrange
        when(
          mockRemoteDataSource.removeReaction('msg_123', 'user_789'),
        ).thenAnswer((_) async {});

        // act
        await repository.removeReaction('msg_123', 'user_789');

        // assert
        verify(
          mockRemoteDataSource.removeReaction('msg_123', 'user_789'),
        ).called(1);
      });

      test('should throw exception when remote data source fails', () async {
        // arrange
        when(
          mockRemoteDataSource.removeReaction('msg_123', 'user_789'),
        ).thenThrow(Exception('Failed to remove reaction'));

        // act & assert
        expect(
          () => repository.removeReaction('msg_123', 'user_789'),
          throwsA(isA<Exception>()),
        );
        verify(
          mockRemoteDataSource.removeReaction('msg_123', 'user_789'),
        ).called(1);
      });
    });

    group('markMessagesAsRead', () {
      test('should call remote data source successfully', () async {
        // arrange
        when(
          mockRemoteDataSource.markMessagesAsRead('thread_456', 'user_789'),
        ).thenAnswer((_) async {});

        // act
        await repository.markMessagesAsRead('thread_456', 'user_789');

        // assert
        verify(
          mockRemoteDataSource.markMessagesAsRead('thread_456', 'user_789'),
        ).called(1);
      });

      test('should throw exception when remote data source fails', () async {
        // arrange
        when(
          mockRemoteDataSource.markMessagesAsRead('thread_456', 'user_789'),
        ).thenThrow(Exception('Failed to mark messages as read'));

        // act & assert
        expect(
          () => repository.markMessagesAsRead('thread_456', 'user_789'),
          throwsA(isA<Exception>()),
        );
        verify(
          mockRemoteDataSource.markMessagesAsRead('thread_456', 'user_789'),
        ).called(1);
      });
    });

    group('editMessage', () {
      test('should call remote data source successfully', () async {
        // arrange
        when(
          mockRemoteDataSource.editMessage(
            messageId: 'msg_123',
            newContent: 'Updated content',
            userId: 'user_789',
          ),
        ).thenAnswer((_) async {});

        // act
        await repository.editMessage(
          messageId: 'msg_123',
          newContent: 'Updated content',
          userId: 'user_789',
        );

        // assert
        verify(
          mockRemoteDataSource.editMessage(
            messageId: 'msg_123',
            newContent: 'Updated content',
            userId: 'user_789',
          ),
        ).called(1);
      });

      test('should throw exception when remote data source fails', () async {
        // arrange
        when(
          mockRemoteDataSource.editMessage(
            messageId: 'msg_123',
            newContent: 'Updated content',
            userId: 'user_789',
          ),
        ).thenThrow(Exception('Failed to edit message'));

        // act & assert
        expect(
          () => repository.editMessage(
            messageId: 'msg_123',
            newContent: 'Updated content',
            userId: 'user_789',
          ),
          throwsA(isA<Exception>()),
        );
        verify(
          mockRemoteDataSource.editMessage(
            messageId: 'msg_123',
            newContent: 'Updated content',
            userId: 'user_789',
          ),
        ).called(1);
      });
    });

    test('should get all messages without filtering by deletedFor', () async {
      // arrange
      final messages = [
        ChatMessageModel(
          id: 'msg1',
          chatThreadId: 'thread1',
          senderId: 'user1',
          senderName: 'User1',
          senderAvatarUrl: 'avatar1.jpg',
          content: 'Hello',
          type: 'text',
          status: 'sent',
          isDeleted: false,
          reactions: const {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          sentAt: DateTime.now(),
          deletedFor: ['user2'], // Deleted for user2 but not user1
        ),
        ChatMessageModel(
          id: 'msg2',
          chatThreadId: 'thread1',
          senderId: 'user2',
          senderName: 'User2',
          senderAvatarUrl: 'avatar2.jpg',
          content: 'Hi',
          type: 'text',
          status: 'sent',
          isDeleted: false,
          reactions: const {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          sentAt: DateTime.now(),
          deletedFor: [], // Not deleted for anyone
        ),
      ];

      when(
        mockRemoteDataSource.fetchAllMessages('thread1'),
      ).thenAnswer((_) async => messages);

      // act
      final result = await repository.getAllMessages('thread1');

      // assert
      expect(result.length, 2); // Should return both messages
      verify(mockRemoteDataSource.fetchAllMessages('thread1')).called(1);
    });

    test('should handle exceptions in getAllMessages', () async {
      // arrange
      when(
        mockRemoteDataSource.fetchAllMessages('thread1'),
      ).thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => repository.getAllMessages('thread1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
