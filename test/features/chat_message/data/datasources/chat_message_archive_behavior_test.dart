import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:chatas/features/chat_message/data/datasources/chat_message_remote_data_source.dart';
import 'package:chatas/features/chat_message/data/models/chat_message_model.dart';

void main() {
  group('ChatMessageRemoteDataSource - Archive Behavior', () {
    late ChatMessageRemoteDataSource dataSource;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      dataSource = ChatMessageRemoteDataSource(firestore: fakeFirestore);
    });

    test(
      'should NOT auto-unarchive thread for recipient when sender sends new message',
      () async {
        // arrange - Create a thread where user2 has archived it
        const threadId = 'thread123';
        const senderId = 'user1';
        const recipientId = 'user2';

        // Setup thread in Firestore with user2 having archived it
        await fakeFirestore.collection('chat_threads').doc(threadId).set({
          'id': threadId,
          'name': 'Test Thread',
          'members': [senderId, recipientId],
          'hiddenFor': [recipientId], // user2 has archived this thread
          'isGroup': false,
          'unreadCounts': {senderId: 0, recipientId: 0},
          'lastMessage': 'Previous message',
          'lastMessageTime': DateTime.now()
              .subtract(Duration(hours: 1))
              .toIso8601String(),
          'createdAt': DateTime.now()
              .subtract(Duration(days: 1))
              .toIso8601String(),
          'updatedAt': DateTime.now()
              .subtract(Duration(hours: 1))
              .toIso8601String(),
        });

        // Create a new message from user1
        final newMessage = ChatMessageModel(
          id: 'msg123',
          chatThreadId: threadId,
          senderId: senderId,
          senderName: 'User 1',
          senderAvatarUrl: '',
          content: 'New message from user1',
          type: 'text',
          status: 'sent',
          sentAt: DateTime.now(),
          isDeleted: false,
          reactions: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act - Add the message (this should trigger auto-revive logic)
        await dataSource.addMessage(newMessage);

        // assert - Check thread state after message
        final threadDoc = await fakeFirestore
            .collection('chat_threads')
            .doc(threadId)
            .get();
        final threadData = threadDoc.data()!;
        final hiddenFor = List<String>.from(threadData['hiddenFor'] ?? []);

        // user2 should STILL be in hiddenFor (thread remains archived for them)
        expect(
          hiddenFor.contains(recipientId),
          isTrue,
          reason: 'Recipient should remain archived even after new message',
        );

        // user1 (sender) should NOT be in hiddenFor if they were there before
        expect(
          hiddenFor.contains(senderId),
          isFalse,
          reason: 'Sender should see their own message',
        );

        print('✅ Test passed: Archived thread stayed archived for recipient');
      },
    );

    test(
      'should auto-unarchive thread for sender if they had archived it',
      () async {
        // arrange - Create a thread where user1 (sender) has archived it
        const threadId = 'thread456';
        const senderId = 'user1';
        const recipientId = 'user2';

        // Setup thread in Firestore with user1 having archived it
        await fakeFirestore.collection('chat_threads').doc(threadId).set({
          'id': threadId,
          'name': 'Test Thread',
          'members': [senderId, recipientId],
          'hiddenFor': [senderId], // user1 (sender) has archived this thread
          'isGroup': false,
          'unreadCounts': {senderId: 0, recipientId: 0},
          'lastMessage': 'Previous message',
          'lastMessageTime': DateTime.now()
              .subtract(Duration(hours: 1))
              .toIso8601String(),
          'createdAt': DateTime.now()
              .subtract(Duration(days: 1))
              .toIso8601String(),
          'updatedAt': DateTime.now()
              .subtract(Duration(hours: 1))
              .toIso8601String(),
        });

        // Create a new message from user1
        final newMessage = ChatMessageModel(
          id: 'msg456',
          chatThreadId: threadId,
          senderId: senderId,
          senderName: 'User 1',
          senderAvatarUrl: '',
          content: 'New message from user1',
          type: 'text',
          status: 'sent',
          sentAt: DateTime.now(),
          isDeleted: false,
          reactions: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act - Add the message
        await dataSource.addMessage(newMessage);

        // assert - Check thread state after message
        final threadDoc = await fakeFirestore
            .collection('chat_threads')
            .doc(threadId)
            .get();
        final threadData = threadDoc.data()!;
        final hiddenFor = List<String>.from(threadData['hiddenFor'] ?? []);

        // user1 (sender) should NO LONGER be in hiddenFor (auto-unarchived for themselves)
        expect(
          hiddenFor.contains(senderId),
          isFalse,
          reason: 'Sender should auto-unarchive thread for themselves',
        );

        print('✅ Test passed: Sender auto-unarchived their own thread');
      },
    );

    test(
      'should keep archived group chat hidden even when sender sends new message (no auto-unarchive for groups)',
      () async {
        // arrange - Create a group thread where user2 has archived it
        const threadId = 'group789';
        const senderId = 'user1';
        const recipientId = 'user2';
        const user3Id = 'user3';

        // Setup group thread in Firestore with user2 having archived it
        await fakeFirestore.collection('chat_threads').doc(threadId).set({
          'id': threadId,
          'name': 'Test Group',
          'members': [senderId, recipientId, user3Id],
          'hiddenFor': [recipientId], // user2 has archived this group
          'isGroup': true,
          'joinedAt': {
            senderId: DateTime.now()
                .subtract(Duration(days: 2))
                .toIso8601String(),
            recipientId: DateTime.now()
                .subtract(Duration(days: 2))
                .toIso8601String(),
            user3Id: DateTime.now()
                .subtract(Duration(days: 2))
                .toIso8601String(),
          },
          'unreadCounts': {senderId: 0, recipientId: 0, user3Id: 0},
          'lastMessage': 'Previous group message',
          'lastMessageTime': DateTime.now()
              .subtract(Duration(hours: 1))
              .toIso8601String(),
          'createdAt': DateTime.now()
              .subtract(Duration(days: 2))
              .toIso8601String(),
          'updatedAt': DateTime.now()
              .subtract(Duration(hours: 1))
              .toIso8601String(),
        });

        // Create a new message from user1 in the group
        final newMessage = ChatMessageModel(
          id: 'msg789',
          chatThreadId: threadId,
          senderId: senderId,
          senderName: 'User 1',
          senderAvatarUrl: '',
          content: 'New group message from user1',
          type: 'text',
          status: 'sent',
          sentAt: DateTime.now(),
          isDeleted: false,
          reactions: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act - Add the message
        await dataSource.addMessage(newMessage);

        // assert - Check thread state after message
        final threadDoc = await fakeFirestore
            .collection('chat_threads')
            .doc(threadId)
            .get();
        final threadData = threadDoc.data()!;
        final hiddenFor = List<String>.from(threadData['hiddenFor'] ?? []);

        // user2 should STILL be in hiddenFor (group remains archived for them)
        expect(
          hiddenFor.contains(recipientId),
          isTrue,
          reason:
              'User who archived group should remain archived even after new message',
        );

        // Sender was not archived in this scenario; ensure we didn't alter it
        expect(
          hiddenFor.contains(senderId),
          isFalse,
          reason:
              'Sender was not archived; hiddenFor should remain unchanged for sender',
        );

        print('✅ Test passed: Group chat archiving behavior correct');
      },
    );

    test(
      'should handle case where multiple users have archived the thread',
      () async {
        // arrange - Create a thread where both users have archived it
        const threadId = 'thread999';
        const senderId = 'user1';
        const recipientId = 'user2';

        // Setup thread in Firestore with both users having archived it
        await fakeFirestore.collection('chat_threads').doc(threadId).set({
          'id': threadId,
          'name': 'Test Thread',
          'members': [senderId, recipientId],
          'hiddenFor': [senderId, recipientId], // Both users archived it
          'isGroup': false,
          'unreadCounts': {senderId: 0, recipientId: 0},
          'lastMessage': 'Previous message',
          'lastMessageTime': DateTime.now()
              .subtract(Duration(hours: 1))
              .toIso8601String(),
          'createdAt': DateTime.now()
              .subtract(Duration(days: 1))
              .toIso8601String(),
          'updatedAt': DateTime.now()
              .subtract(Duration(hours: 1))
              .toIso8601String(),
        });

        // Create a new message from user1
        final newMessage = ChatMessageModel(
          id: 'msg999',
          chatThreadId: threadId,
          senderId: senderId,
          senderName: 'User 1',
          senderAvatarUrl: '',
          content: 'New message from user1',
          type: 'text',
          status: 'sent',
          sentAt: DateTime.now(),
          isDeleted: false,
          reactions: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // act - Add the message
        await dataSource.addMessage(newMessage);

        // assert - Check thread state after message
        final threadDoc = await fakeFirestore
            .collection('chat_threads')
            .doc(threadId)
            .get();
        final threadData = threadDoc.data()!;
        final hiddenFor = List<String>.from(threadData['hiddenFor'] ?? []);

        // Only sender should be removed from hiddenFor
        expect(
          hiddenFor.contains(senderId),
          isFalse,
          reason: 'Sender should auto-unarchive for themselves',
        );
        expect(
          hiddenFor.contains(recipientId),
          isTrue,
          reason: 'Recipient should remain archived',
        );
        expect(
          hiddenFor.length,
          equals(1),
          reason: 'Only recipient should remain in hiddenFor',
        );

        print('✅ Test passed: Multiple archived users handled correctly');
      },
    );
  });
}
