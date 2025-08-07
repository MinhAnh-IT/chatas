import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/constants/chat_message_page_constants.dart';

void main() {
  group('ChatMessage Entity Tests', () {
    late ChatMessage testMessage;
    late DateTime testDateTime;

    setUp(() {
      testDateTime = DateTime(2024, 1, 1, 12, 0, 0);
      testMessage = ChatMessage(
        id: 'test_id',
        chatThreadId: 'thread_123',
        senderId: 'user_123',
        senderName: 'Test User',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        content: 'Test message content',
        type: MessageType.text,
        status: MessageStatus.sent,
        sentAt: testDateTime,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );
    });

    group('Constructor and Properties', () {
      test('creates ChatMessage with required properties', () {
        expect(testMessage.id, equals('test_id'));
        expect(testMessage.chatThreadId, equals('thread_123'));
        expect(testMessage.senderId, equals('user_123'));
        expect(testMessage.senderName, equals('Test User'));
        expect(testMessage.content, equals('Test message content'));
        expect(testMessage.type, equals(MessageType.text));
        expect(testMessage.status, equals(MessageStatus.sent));
        expect(testMessage.sentAt, equals(testDateTime));
      });

      test('has correct default values', () {
        final messageWithDefaults = ChatMessage(
          id: 'test_id',
          chatThreadId: 'thread_123',
          senderId: 'user_123',
          senderName: 'Test User',
          senderAvatarUrl: '',
          content: 'Test content',
          sentAt: testDateTime,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        expect(messageWithDefaults.type, equals(MessageType.text));
        expect(messageWithDefaults.status, equals(MessageStatus.sending));
        expect(messageWithDefaults.isDeleted, isFalse);
        expect(messageWithDefaults.reactions, isEmpty);
        expect(messageWithDefaults.editedAt, isNull);
        expect(messageWithDefaults.replyToMessageId, isNull);
      });
    });

    group('isFromCurrentUser getter', () {
      test('returns true when senderId matches temporaryUserId', () {
        final currentUserMessage = testMessage.copyWith(
          senderId: ChatMessagePageConstants.temporaryUserId,
        );

        expect(currentUserMessage.isFromCurrentUser, isTrue);
      });

      test('returns false when senderId does not match temporaryUserId', () {
        final otherUserMessage = testMessage.copyWith(
          senderId: 'other_user_id',
        );

        expect(otherUserMessage.isFromCurrentUser, isFalse);
      });
    });

    group('hasReactions getter', () {
      test('returns false when reactions map is empty', () {
        expect(testMessage.hasReactions, isFalse);
      });

      test('returns true when reactions map has items', () {
        final messageWithReactions = testMessage.copyWith(
          reactions: {'user1': ReactionType.like},
        );

        expect(messageWithReactions.hasReactions, isTrue);
      });
    });

    group('getReactionCount method', () {
      test('returns 0 when no reactions of specified type', () {
        final messageWithReactions = testMessage.copyWith(
          reactions: {'user1': ReactionType.love, 'user2': ReactionType.sad},
        );

        expect(
          messageWithReactions.getReactionCount(ReactionType.like),
          equals(0),
        );
      });

      test('returns correct count for specific reaction type', () {
        final messageWithReactions = testMessage.copyWith(
          reactions: {
            'user1': ReactionType.like,
            'user2': ReactionType.like,
            'user3': ReactionType.love,
            'user4': ReactionType.like,
          },
        );

        expect(
          messageWithReactions.getReactionCount(ReactionType.like),
          equals(3),
        );
        expect(
          messageWithReactions.getReactionCount(ReactionType.love),
          equals(1),
        );
        expect(
          messageWithReactions.getReactionCount(ReactionType.sad),
          equals(0),
        );
      });
    });

    group('hasUserReacted method', () {
      test('returns false when user has not reacted', () {
        final messageWithReactions = testMessage.copyWith(
          reactions: {'user1': ReactionType.like},
        );

        expect(messageWithReactions.hasUserReacted('user2'), isFalse);
      });

      test('returns true when user has reacted', () {
        final messageWithReactions = testMessage.copyWith(
          reactions: {'user1': ReactionType.like, 'user2': ReactionType.love},
        );

        expect(messageWithReactions.hasUserReacted('user1'), isTrue);
        expect(messageWithReactions.hasUserReacted('user2'), isTrue);
      });
    });

    group('getUserReaction method', () {
      test('returns null when user has not reacted', () {
        final messageWithReactions = testMessage.copyWith(
          reactions: {'user1': ReactionType.like},
        );

        expect(messageWithReactions.getUserReaction('user2'), isNull);
      });

      test('returns correct reaction type for user', () {
        final messageWithReactions = testMessage.copyWith(
          reactions: {
            'user1': ReactionType.like,
            'user2': ReactionType.love,
            'user3': ReactionType.sad,
          },
        );

        expect(
          messageWithReactions.getUserReaction('user1'),
          equals(ReactionType.like),
        );
        expect(
          messageWithReactions.getUserReaction('user2'),
          equals(ReactionType.love),
        );
        expect(
          messageWithReactions.getUserReaction('user3'),
          equals(ReactionType.sad),
        );
      });
    });

    group('copyWith method', () {
      test('creates new instance with updated fields', () {
        final updatedMessage = testMessage.copyWith(
          content: 'Updated content',
          status: MessageStatus.read,
          editedAt: testDateTime.add(const Duration(hours: 1)),
        );

        expect(updatedMessage.content, equals('Updated content'));
        expect(updatedMessage.status, equals(MessageStatus.read));
        expect(
          updatedMessage.editedAt,
          equals(testDateTime.add(const Duration(hours: 1))),
        );

        // Other fields should remain unchanged
        expect(updatedMessage.id, equals(testMessage.id));
        expect(updatedMessage.senderId, equals(testMessage.senderId));
        expect(updatedMessage.sentAt, equals(testMessage.sentAt));
      });

      test('preserves original values when null is passed', () {
        final copiedMessage = testMessage.copyWith();

        expect(copiedMessage.id, equals(testMessage.id));
        expect(copiedMessage.content, equals(testMessage.content));
        expect(copiedMessage.status, equals(testMessage.status));
        expect(copiedMessage.sentAt, equals(testMessage.sentAt));
      });

      test('can update reactions map', () {
        final originalReactions = {'user1': ReactionType.like};
        final messageWithReactions = testMessage.copyWith(
          reactions: originalReactions,
        );

        final updatedReactions = {
          'user1': ReactionType.like,
          'user2': ReactionType.love,
        };
        final updatedMessage = messageWithReactions.copyWith(
          reactions: updatedReactions,
        );

        expect(updatedMessage.reactions, equals(updatedReactions));
        expect(updatedMessage.reactions.length, equals(2));
      });
    });

    group('Equatable implementation', () {
      test('returns true for messages with same properties', () {
        final message1 = ChatMessage(
          id: 'test_id',
          chatThreadId: 'thread_123',
          senderId: 'user_123',
          senderName: 'Test User',
          senderAvatarUrl: 'https://example.com/avatar.jpg',
          content: 'Test content',
          sentAt: testDateTime,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        final message2 = ChatMessage(
          id: 'test_id',
          chatThreadId: 'thread_123',
          senderId: 'user_123',
          senderName: 'Test User',
          senderAvatarUrl: 'https://example.com/avatar.jpg',
          content: 'Test content',
          sentAt: testDateTime,
          createdAt: testDateTime,
          updatedAt: testDateTime,
        );

        expect(message1, equals(message2));
        expect(message1.hashCode, equals(message2.hashCode));
      });

      test('returns false for messages with different properties', () {
        final message1 = testMessage;
        final message2 = testMessage.copyWith(content: 'Different content');

        expect(message1, isNot(equals(message2)));
        expect(message1.hashCode, isNot(equals(message2.hashCode)));
      });
    });

    group('Message Types', () {
      test('supports all message types', () {
        expect(MessageType.values, contains(MessageType.text));
        expect(MessageType.values, contains(MessageType.image));
        expect(MessageType.values, contains(MessageType.file));
        expect(MessageType.values, contains(MessageType.system));
      });
    });

    group('Message Status', () {
      test('supports all status types', () {
        expect(MessageStatus.values, contains(MessageStatus.sending));
        expect(MessageStatus.values, contains(MessageStatus.sent));
        expect(MessageStatus.values, contains(MessageStatus.delivered));
        expect(MessageStatus.values, contains(MessageStatus.read));
        expect(MessageStatus.values, contains(MessageStatus.failed));
      });
    });

    group('Reaction Types', () {
      test('supports all reaction types', () {
        expect(ReactionType.values, contains(ReactionType.like));
        expect(ReactionType.values, contains(ReactionType.love));
        expect(ReactionType.values, contains(ReactionType.sad));
        expect(ReactionType.values, contains(ReactionType.angry));
        expect(ReactionType.values, contains(ReactionType.laugh));
        expect(ReactionType.values, contains(ReactionType.wow));
      });
    });
  });
}
