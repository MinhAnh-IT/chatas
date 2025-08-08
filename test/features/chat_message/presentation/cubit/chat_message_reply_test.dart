import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/domain/usecases/get_messages_stream_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/send_message_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/add_reaction_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/remove_reaction_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/edit_message_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/delete_message_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/send_first_message_usecase.dart';
import 'package:chatas/features/chat_message/presentation/cubit/chat_message_cubit.dart';
import 'package:chatas/features/chat_message/presentation/cubit/chat_message_state.dart';

import 'chat_message_reply_test.mocks.dart';

@GenerateMocks([
  GetMessagesStreamUseCase,
  SendMessageUseCase,
  AddReactionUseCase,
  RemoveReactionUseCase,
  EditMessageUseCase,
  DeleteMessageUseCase,
  SendFirstMessageUseCase,
])
void main() {
  group('ChatMessageCubit Reply Functionality', () {
    late ChatMessageCubit cubit;
    late MockGetMessagesStreamUseCase mockGetMessagesStreamUseCase;
    late MockSendMessageUseCase mockSendMessageUseCase;
    late MockAddReactionUseCase mockAddReactionUseCase;
    late MockRemoveReactionUseCase mockRemoveReactionUseCase;
    late MockEditMessageUseCase mockEditMessageUseCase;
    late MockDeleteMessageUseCase mockDeleteMessageUseCase;
    late MockSendFirstMessageUseCase mockSendFirstMessageUseCase;

    setUp(() {
      mockGetMessagesStreamUseCase = MockGetMessagesStreamUseCase();
      mockSendMessageUseCase = MockSendMessageUseCase();
      mockAddReactionUseCase = MockAddReactionUseCase();
      mockRemoveReactionUseCase = MockRemoveReactionUseCase();
      mockEditMessageUseCase = MockEditMessageUseCase();
      mockDeleteMessageUseCase = MockDeleteMessageUseCase();
      mockSendFirstMessageUseCase = MockSendFirstMessageUseCase();

      cubit = ChatMessageCubit(
        getMessagesStreamUseCase: mockGetMessagesStreamUseCase,
        sendMessageUseCase: mockSendMessageUseCase,
        addReactionUseCase: mockAddReactionUseCase,
        removeReactionUseCase: mockRemoveReactionUseCase,
        editMessageUseCase: mockEditMessageUseCase,
        deleteMessageUseCase: mockDeleteMessageUseCase,
        sendFirstMessageUseCase: mockSendFirstMessageUseCase,
      );

      // Set up current user
      cubit.setCurrentUser(userId: 'test_user', userName: 'Test User');
    });

    tearDown(() {
      cubit.close();
    });

    group('setReplyToMessage', () {
      test('should set reply message ID', () {
        // act
        cubit.setReplyToMessage('message_123');

        // assert
        expect(cubit.replyToMessageId, equals('message_123'));
      });

      test('should clear reply message ID when set to null', () {
        // arrange
        cubit.setReplyToMessage('message_123');

        // act
        cubit.setReplyToMessage(null);

        // assert
        expect(cubit.replyToMessageId, isNull);
      });

      test('should emit current state when setting reply message in loaded state', () {
        // arrange - manually set a loaded state
        final testMessages = [
          ChatMessage(
            id: 'msg1',
            chatThreadId: 'thread1',
            senderId: 'user1',
            senderName: 'User 1',
            senderAvatarUrl: '',
            content: 'Test message',
            sentAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        
        cubit.emit(ChatMessageLoaded(messages: testMessages));
        
        // act
        cubit.setReplyToMessage('message_123');
        
        // assert
        expect(cubit.state, isA<ChatMessageLoaded>());
        expect(cubit.replyToMessageId, equals('message_123'));
      });
    });

    group('clearReply', () {
      test('should clear reply message ID', () {
        // arrange
        cubit.setReplyToMessage('message_123');

        // act
        cubit.clearReply();

        // assert
        expect(cubit.replyToMessageId, isNull);
      });

      test('should emit current state when clearing reply in loaded state', () {
        // arrange
        final testMessages = [
          ChatMessage(
            id: 'msg1',
            chatThreadId: 'thread1',
            senderId: 'user1',
            senderName: 'User 1',
            senderAvatarUrl: '',
            content: 'Test message',
            sentAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        
        cubit.emit(ChatMessageLoaded(messages: testMessages));
        cubit.setReplyToMessage('message_123');
        
        // act
        cubit.clearReply();
        
        // assert
        expect(cubit.state, isA<ChatMessageLoaded>());
        expect(cubit.replyToMessageId, isNull);
      });
    });

    group('reply state management', () {
      test('should maintain reply ID across different operations', () {
        // arrange
        const replyId = 'reply_123';
        
        // act
        cubit.setReplyToMessage(replyId);
        
        // assert - verify state persists
        expect(cubit.replyToMessageId, equals(replyId));
        
        // act - clear reply
        cubit.clearReply();
        
        // assert - verify state is cleared
        expect(cubit.replyToMessageId, isNull);
      });

      test('should handle multiple reply ID changes', () {
        // arrange & act
        cubit.setReplyToMessage('first_reply');
        expect(cubit.replyToMessageId, equals('first_reply'));
        
        cubit.setReplyToMessage('second_reply');
        expect(cubit.replyToMessageId, equals('second_reply'));
        
        cubit.setReplyToMessage(null);
        expect(cubit.replyToMessageId, isNull);
      });
    });
  });
}
