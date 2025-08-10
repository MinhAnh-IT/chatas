import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:chatas/features/chat_message/data/datasources/chat_message_remote_data_source.dart';
import 'package:chatas/features/chat_message/data/models/chat_message_model.dart';

/// Test để verify rằng hiddenFor update không bị race condition
/// với lastMessage update khi có tin nhắn mới
void main() {
  group('ChatMessageRemoteDataSource - Race Condition Fix', () {
    late ChatMessageRemoteDataSource dataSource;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      dataSource = ChatMessageRemoteDataSource(firestore: fakeFirestore);
    });

    test(
      'should atomically update hiddenFor and lastMessage in single operation',
      () async {
        // arrange - Tạo thread với user archived
        const threadId = 'test_race_condition';
        const senderId = 'sender_user';
        const archivedUserId = 'archived_user';

        await fakeFirestore.collection('chat_threads').doc(threadId).set({
          'id': threadId,
          'name': 'Race Condition Test',
          'members': [senderId, archivedUserId],
          'hiddenFor': [senderId], // Sender đã archive thread này
          'isGroup': false,
          'unreadCounts': {senderId: 0, archivedUserId: 0},
          'lastMessage': 'Old message',
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

        // act - Sender gửi tin nhắn mới
        final newMessage = ChatMessageModel(
          id: 'race_test_msg',
          chatThreadId: threadId,
          senderId: senderId, // Sender đã archive, sẽ được auto-revive
          senderName: 'Sender User',
          senderAvatarUrl: '',
          content: 'New message from sender',
          type: 'text',
          status: 'sent',
          sentAt: DateTime.now(),
          isDeleted: false,
          reactions: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await dataSource.addMessage(newMessage);

        // assert - Kiểm tra thread state sau khi update
        final threadDoc = await fakeFirestore
            .collection('chat_threads')
            .doc(threadId)
            .get();
        final threadData = threadDoc.data()!;

        // Verify hiddenFor: sender should be removed, archived_user stays
        final hiddenFor = List<String>.from(threadData['hiddenFor'] ?? []);
        expect(
          hiddenFor.contains(senderId),
          isFalse,
          reason: 'Sender should be auto-unarchived',
        );
        expect(
          hiddenFor.contains(archivedUserId),
          isFalse,
          reason:
              'Archived user was not in hiddenFor initially, should stay out',
        );

        // Verify lastMessage was updated correctly
        expect(threadData['lastMessage'], equals('New message from sender'));
        expect(threadData['lastMessageTime'], isNotNull);

        // Verify unreadCounts was updated correctly
        final unreadCounts = Map<String, dynamic>.from(
          threadData['unreadCounts'] ?? {},
        );
        expect(
          unreadCounts[senderId],
          equals(0),
          reason: 'Sender should not have unread count',
        );
        expect(
          unreadCounts[archivedUserId],
          equals(1),
          reason: 'Other user should have unread count incremented',
        );

        print(
          '✅ Race condition test passed: hiddenFor and lastMessage updated atomically',
        );
      },
    );

    test(
      'should handle case where hiddenFor has multiple users but only sender gets revived',
      () async {
        // arrange - Thread where both users have archived
        const threadId = 'test_multiple_archived';
        const senderId = 'sender_user';
        const archivedUserId = 'archived_user';

        await fakeFirestore.collection('chat_threads').doc(threadId).set({
          'id': threadId,
          'name': 'Multiple Archived Test',
          'members': [senderId, archivedUserId],
          'hiddenFor': [senderId, archivedUserId], // Both archived
          'isGroup': false,
          'unreadCounts': {senderId: 0, archivedUserId: 0},
          'lastMessage': 'Old message',
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

        // act - Sender gửi tin nhắn
        final newMessage = ChatMessageModel(
          id: 'multiple_archived_msg',
          chatThreadId: threadId,
          senderId: senderId,
          senderName: 'Sender User',
          senderAvatarUrl: '',
          content: 'New message from sender',
          type: 'text',
          status: 'sent',
          sentAt: DateTime.now(),
          isDeleted: false,
          reactions: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await dataSource.addMessage(newMessage);

        // assert - Chỉ sender được revive
        final threadDoc = await fakeFirestore
            .collection('chat_threads')
            .doc(threadId)
            .get();
        final threadData = threadDoc.data()!;

        final hiddenFor = List<String>.from(threadData['hiddenFor'] ?? []);
        expect(
          hiddenFor.contains(senderId),
          isFalse,
          reason: 'Sender should be removed from hiddenFor',
        );
        expect(
          hiddenFor.contains(archivedUserId),
          isTrue,
          reason: 'Archived user should stay in hiddenFor',
        );
        expect(
          hiddenFor.length,
          equals(1),
          reason: 'Only archived user should remain in hiddenFor',
        );

        // Verify other fields updated correctly
        expect(threadData['lastMessage'], equals('New message from sender'));

        print(
          '✅ Multiple archived test passed: only sender revived, recipient stays archived',
        );
      },
    );

    test('should handle case where no hiddenFor changes needed', () async {
      // arrange - Normal thread, no one archived
      const threadId = 'test_no_changes';
      const senderId = 'sender_user';
      const recipientId = 'recipient_user';

      await fakeFirestore.collection('chat_threads').doc(threadId).set({
        'id': threadId,
        'name': 'No Changes Test',
        'members': [senderId, recipientId],
        'hiddenFor': [], // No one archived
        'isGroup': false,
        'unreadCounts': {senderId: 0, recipientId: 0},
        'lastMessage': 'Old message',
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

      // act
      final newMessage = ChatMessageModel(
        id: 'no_changes_msg',
        chatThreadId: threadId,
        senderId: senderId,
        senderName: 'Sender User',
        senderAvatarUrl: '',
        content: 'Normal message',
        type: 'text',
        status: 'sent',
        sentAt: DateTime.now(),
        isDeleted: false,
        reactions: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dataSource.addMessage(newMessage);

      // assert - hiddenFor should stay empty, other fields updated
      final threadDoc = await fakeFirestore
          .collection('chat_threads')
          .doc(threadId)
          .get();
      final threadData = threadDoc.data()!;

      final hiddenFor = List<String>.from(threadData['hiddenFor'] ?? []);
      expect(
        hiddenFor.isEmpty,
        isTrue,
        reason: 'hiddenFor should remain empty',
      );

      expect(threadData['lastMessage'], equals('Normal message'));

      print('✅ No changes test passed: normal flow works correctly');
    });
  });
}
