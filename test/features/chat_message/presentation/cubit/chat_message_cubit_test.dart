import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
import 'package:chatas/features/chat_message/constants/chat_message_page_constants.dart';

/// Mock implementations for testing.
class MockGetMessagesStreamUseCase extends Mock
    implements GetMessagesStreamUseCase {}

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}

class MockAddReactionUseCase extends Mock implements AddReactionUseCase {}

class MockRemoveReactionUseCase extends Mock implements RemoveReactionUseCase {}

class MockEditMessageUseCase extends Mock implements EditMessageUseCase {}

class MockDeleteMessageUseCase extends Mock implements DeleteMessageUseCase {}

class MockSendFirstMessageUseCase extends Mock
    implements SendFirstMessageUseCase {}

void main() {
  setUpAll(() {
    // Register fallback values for enums
    registerFallbackValue(ReactionType.like);
    registerFallbackValue(MessageType.text);
  });
  group('ChatMessageCubit Tests', () {
    late ChatMessageCubit cubit;
    late MockGetMessagesStreamUseCase mockGetMessagesStreamUseCase;
    late MockSendMessageUseCase mockSendMessageUseCase;
    late MockAddReactionUseCase mockAddReactionUseCase;
    late MockRemoveReactionUseCase mockRemoveReactionUseCase;
    late MockEditMessageUseCase mockEditMessageUseCase;
    late MockDeleteMessageUseCase mockDeleteMessageUseCase;
    late MockSendFirstMessageUseCase mockSendFirstMessageUseCase;
    late StreamController<List<ChatMessage>> messagesStreamController;

    setUp(() {
      mockGetMessagesStreamUseCase = MockGetMessagesStreamUseCase();
      mockSendMessageUseCase = MockSendMessageUseCase();
      mockAddReactionUseCase = MockAddReactionUseCase();
      mockRemoveReactionUseCase = MockRemoveReactionUseCase();
      mockEditMessageUseCase = MockEditMessageUseCase();
      mockDeleteMessageUseCase = MockDeleteMessageUseCase();
      mockSendFirstMessageUseCase = MockSendFirstMessageUseCase();
      messagesStreamController = StreamController<List<ChatMessage>>();

      cubit = ChatMessageCubit(
        getMessagesStreamUseCase: mockGetMessagesStreamUseCase,
        sendMessageUseCase: mockSendMessageUseCase,
        addReactionUseCase: mockAddReactionUseCase,
        removeReactionUseCase: mockRemoveReactionUseCase,
        editMessageUseCase: mockEditMessageUseCase,
        deleteMessageUseCase: mockDeleteMessageUseCase,
        sendFirstMessageUseCase: mockSendFirstMessageUseCase,
      );

      // Set current user for testing
      cubit.setCurrentUser(userId: 'test_user', userName: 'Test User');
    });

    tearDown(() {
      messagesStreamController.close();
      cubit.close();
    });

    test('initial state is ChatMessageInitial', () {
      expect(cubit.state, const ChatMessageInitial());
    });

    group('loadMessages', () {
      final testMessages = [
        ChatMessage(
          id: 'msg1',
          chatThreadId: 'thread1',
          senderId: 'user1',
          senderName: 'User 1',
          senderAvatarUrl: '',
          content: 'Hello',
          sentAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ChatMessage(
          id: 'msg2',
          chatThreadId: 'thread1',
          senderId: 'user2',
          senderName: 'User 2',
          senderAvatarUrl: '',
          content: 'Hi',
          sentAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      blocTest<ChatMessageCubit, ChatMessageState>(
        'emits [Loading, Loaded] when messages are loaded successfully',
        build: () {
          when(
            () => mockGetMessagesStreamUseCase.call(any()),
          ).thenAnswer((_) => messagesStreamController.stream);
          return cubit;
        },
        act: (cubit) {
          cubit.loadMessages('thread1');
          messagesStreamController.add(testMessages);
        },
        expect: () => [
          const ChatMessageLoading(),
          ChatMessageLoaded(messages: testMessages),
        ],
        verify: (_) {
          verify(() => mockGetMessagesStreamUseCase.call('thread1')).called(1);
        },
      );

      blocTest<ChatMessageCubit, ChatMessageState>(
        'emits [Loading, Error] when stream throws error',
        build: () {
          when(
            () => mockGetMessagesStreamUseCase.call(any()),
          ).thenAnswer((_) => messagesStreamController.stream);
          return cubit;
        },
        act: (cubit) {
          cubit.loadMessages('thread1');
          messagesStreamController.addError(Exception('Stream error'));
        },
        expect: () => [
          const ChatMessageLoading(),
          const ChatMessageError(message: 'Exception: Stream error'),
        ],
      );

      blocTest<ChatMessageCubit, ChatMessageState>(
        'cancels previous subscription when loading new messages',
        build: () {
          when(
            () => mockGetMessagesStreamUseCase.call(any()),
          ).thenAnswer((_) => messagesStreamController.stream);
          return cubit;
        },
        act: (cubit) async {
          cubit.loadMessages('thread1');
          await Future.delayed(const Duration(milliseconds: 10));
          cubit.loadMessages('thread2');
        },
        verify: (_) {
          verify(() => mockGetMessagesStreamUseCase.call('thread1')).called(1);
          verify(() => mockGetMessagesStreamUseCase.call('thread2')).called(1);
        },
      );
    });

    group('sendMessage', () {
      const testContent = 'Test message content';
      const testThreadId = 'thread1';

      setUp(() {
        // Set up cubit with loaded state
        when(
          () => mockGetMessagesStreamUseCase.call(any()),
        ).thenAnswer((_) => messagesStreamController.stream);
        cubit.loadMessages(testThreadId);
        messagesStreamController.add([]);
      });

      blocTest<ChatMessageCubit, ChatMessageState>(
        'emits [Sending] when sending message successfully',
        build: () {
          when(
            () => mockSendMessageUseCase.call(
              chatThreadId: any(named: 'chatThreadId'),
              content: any(named: 'content'),
              senderId: any(named: 'senderId'),
              senderName: any(named: 'senderName'),
            ),
          ).thenAnswer((_) async {});
          return cubit;
        },
        seed: () => const ChatMessageLoaded(messages: []),
        act: (cubit) => cubit.sendMessage(testContent),
        expect: () => [
          isA<ChatMessageSending>()
              .having(
                (state) => state.pendingMessage.content,
                'content',
                testContent,
              )
              .having(
                (state) => state.pendingMessage.status,
                'status',
                MessageStatus.sending,
              ),
        ],
        verify: (_) {
          verify(
            () => mockSendMessageUseCase.call(
              chatThreadId: testThreadId,
              content: testContent,
              senderId: any(named: 'senderId'),
              senderName: any(named: 'senderName'),
            ),
          ).called(1);
        },
      );

      blocTest<ChatMessageCubit, ChatMessageState>(
        'does not send message when currentChatThreadId is null',
        build: () {
          // Reset mocks to ensure no interference
          reset(mockSendMessageUseCase);
          final cubit = ChatMessageCubit(
            getMessagesStreamUseCase: mockGetMessagesStreamUseCase,
            sendMessageUseCase: mockSendMessageUseCase,
            addReactionUseCase: mockAddReactionUseCase,
            removeReactionUseCase: mockRemoveReactionUseCase,
            editMessageUseCase: mockEditMessageUseCase,
            deleteMessageUseCase: mockDeleteMessageUseCase,
            sendFirstMessageUseCase: mockSendFirstMessageUseCase,
          );
          cubit.setCurrentUser(userId: 'test_user', userName: 'Test User');
          return cubit;
        },
        seed: () => const ChatMessageLoaded(messages: []),
        act: (cubit) => cubit.sendMessage(testContent),
        expect: () => [],
        verify: (_) {
          verifyNever(
            () => mockSendMessageUseCase.call(
              chatThreadId: any(named: 'chatThreadId'),
              content: any(named: 'content'),
              senderId: any(named: 'senderId'),
              senderName: any(named: 'senderName'),
            ),
          );
        },
      );

      blocTest<ChatMessageCubit, ChatMessageState>(
        'does not send empty message',
        build: () {
          when(
            () => mockGetMessagesStreamUseCase.call(any()),
          ).thenAnswer((_) => messagesStreamController.stream);
          return cubit;
        },
        seed: () => const ChatMessageLoaded(messages: []),
        act: (cubit) {
          cubit.loadMessages(testThreadId);
          cubit.sendMessage('');
        },
        verify: (_) {
          verifyNever(
            () => mockSendMessageUseCase.call(
              chatThreadId: any(named: 'chatThreadId'),
              content: any(named: 'content'),
              senderId: any(named: 'senderId'),
              senderName: any(named: 'senderName'),
            ),
          );
        },
      );

      blocTest<ChatMessageCubit, ChatMessageState>(
        'emits Error when send message fails',
        build: () {
          when(
            () => mockSendMessageUseCase.call(
              chatThreadId: any(named: 'chatThreadId'),
              content: any(named: 'content'),
              senderId: any(named: 'senderId'),
              senderName: any(named: 'senderName'),
            ),
          ).thenThrow(Exception('Send failed'));
          when(
            () => mockGetMessagesStreamUseCase.call(any()),
          ).thenAnswer((_) => Stream.value(<ChatMessage>[]));
          return cubit;
        },
        act: (cubit) async {
          await cubit.loadMessages(testThreadId);
          // Wait for stream to emit to ensure state is ChatMessageLoaded
          await Future.delayed(const Duration(milliseconds: 50));
          await cubit.sendMessage(testContent);
        },
        expect: () => [
          const ChatMessageLoading(),
          const ChatMessageLoaded(messages: []),
          isA<ChatMessageSending>(),
          const ChatMessageError(message: 'Exception: Send failed'),
        ],
        wait: const Duration(milliseconds: 200),
      );
    });

    group('addReaction', () {
      const testMessageId = 'msg1';
      const testReaction = ReactionType.like;
      final testMessages = [
        ChatMessage(
          id: testMessageId,
          chatThreadId: 'thread1',
          senderId: 'user1',
          senderName: 'User 1',
          senderAvatarUrl: '',
          content: 'Hello',
          sentAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      blocTest<ChatMessageCubit, ChatMessageState>(
        'emits [ReactionAdding] when adding reaction successfully',
        build: () {
          when(
            () => mockAddReactionUseCase.call(
              messageId: any(named: 'messageId'),
              reaction: any(named: 'reaction'),
              userId: any(named: 'userId'),
            ),
          ).thenAnswer((_) async {});
          return cubit;
        },
        seed: () => ChatMessageLoaded(messages: testMessages),
        act: (cubit) => cubit.addReaction(testMessageId, testReaction),
        expect: () => [
          ChatMessageReactionAdding(
            messages: testMessages,
            messageId: testMessageId,
            reaction: testReaction,
          ),
        ],
        verify: (_) {
          verify(
            () => mockAddReactionUseCase.call(
              messageId: testMessageId,
              reaction: testReaction,
              userId: any(named: 'userId'),
            ),
          ).called(1);
        },
      );

      blocTest<ChatMessageCubit, ChatMessageState>(
        'emits Error when add reaction fails',
        build: () {
          when(
            () => mockAddReactionUseCase.call(
              messageId: any(named: 'messageId'),
              reaction: any(named: 'reaction'),
              userId: any(named: 'userId'),
            ),
          ).thenThrow(Exception('Add reaction failed'));
          return cubit;
        },
        seed: () => ChatMessageLoaded(messages: testMessages),
        act: (cubit) => cubit.addReaction(testMessageId, testReaction),
        expect: () => [
          ChatMessageReactionAdding(
            messages: testMessages,
            messageId: testMessageId,
            reaction: testReaction,
          ),
          const ChatMessageError(message: 'Exception: Add reaction failed'),
        ],
      );
    });

    group('removeReaction', () {
      const testMessageId = 'msg1';
      const testUserId = 'user1';

      blocTest<ChatMessageCubit, ChatMessageState>(
        'calls removeReactionUseCase when state is loaded',
        build: () {
          when(
            () => mockRemoveReactionUseCase.call(
              messageId: any(named: 'messageId'),
              userId: any(named: 'userId'),
            ),
          ).thenAnswer((_) async {});
          return cubit;
        },
        seed: () => const ChatMessageLoaded(messages: []),
        act: (cubit) => cubit.removeReaction(testMessageId),
        verify: (_) {
          verify(
            () => mockRemoveReactionUseCase.call(
              messageId: testMessageId,
              userId: 'test_user',
            ),
          ).called(1);
        },
      );

      blocTest<ChatMessageCubit, ChatMessageState>(
        'emits Error when remove reaction fails',
        build: () {
          when(
            () => mockRemoveReactionUseCase.call(
              messageId: any(named: 'messageId'),
              userId: any(named: 'userId'),
            ),
          ).thenThrow(Exception('Remove reaction failed'));
          return cubit;
        },
        seed: () => const ChatMessageLoaded(messages: []),
        act: (cubit) => cubit.removeReaction(testMessageId),
        expect: () => [
          const ChatMessageError(message: 'Exception: Remove reaction failed'),
        ],
      );
    });

    group('refreshMessages', () {
      const testThreadId = 'thread1';

      blocTest<ChatMessageCubit, ChatMessageState>(
        'reloads messages when currentChatThreadId is available',
        build: () {
          when(
            () => mockGetMessagesStreamUseCase.call(any()),
          ).thenAnswer((_) => messagesStreamController.stream);
          return cubit;
        },
        act: (cubit) {
          cubit.loadMessages(testThreadId);
          cubit.refreshMessages();
        },
        verify: (_) {
          // loadMessages called twice - once for initial load, once for refresh
          verify(
            () => mockGetMessagesStreamUseCase.call(testThreadId),
          ).called(2);
        },
      );

      blocTest<ChatMessageCubit, ChatMessageState>(
        'does nothing when currentChatThreadId is null',
        build: () => cubit,
        act: (cubit) => cubit.refreshMessages(),
        verify: (_) {
          verifyNever(() => mockGetMessagesStreamUseCase.call(any()));
        },
      );
    });

    group('currentMessages getter', () {
      test('returns empty list when state is initial', () {
        expect(cubit.currentMessages, isEmpty);
      });

      test('returns messages from loaded state', () {
        final testMessages = [
          ChatMessage(
            id: 'msg1',
            chatThreadId: 'thread1',
            senderId: 'user1',
            senderName: 'User 1',
            senderAvatarUrl: '',
            content: 'Hello',
            sentAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        cubit.emit(ChatMessageLoaded(messages: testMessages));
        expect(cubit.currentMessages, equals(testMessages));
      });

      test('returns messages with pending message from sending state', () {
        final testMessages = [
          ChatMessage(
            id: 'msg1',
            chatThreadId: 'thread1',
            senderId: 'user1',
            senderName: 'User 1',
            senderAvatarUrl: '',
            content: 'Hello',
            sentAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final pendingMessage = ChatMessage(
          id: 'pending_msg',
          chatThreadId: 'thread1',
          senderId: 'test_user',
          senderName: 'Test User',
          senderAvatarUrl: ChatMessagePageConstants.temporaryAvatarUrl,
          content: 'Pending message',
          status: MessageStatus.sending,
          sentAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        cubit.emit(
          ChatMessageSending(
            messages: testMessages,
            pendingMessage: pendingMessage,
          ),
        );

        expect(cubit.currentMessages.length, equals(2));
        expect(cubit.currentMessages, contains(pendingMessage));
        expect(cubit.currentMessages, containsAll(testMessages));
      });
    });

    group('isMessageSelected', () {
      const testMessageId = 'msg1';

      test('returns false when state is not loaded', () {
        expect(cubit.isMessageSelected(testMessageId), isFalse);
      });

      test('returns true when message is selected in loaded state', () {
        cubit.emit(
          const ChatMessageLoaded(
            messages: [],
            selectedMessageId: testMessageId,
          ),
        );

        expect(cubit.isMessageSelected(testMessageId), isTrue);
      });

      test('returns false when different message is selected', () {
        cubit.emit(
          const ChatMessageLoaded(messages: [], selectedMessageId: 'other_msg'),
        );

        expect(cubit.isMessageSelected(testMessageId), isFalse);
      });
    });
  });
}
